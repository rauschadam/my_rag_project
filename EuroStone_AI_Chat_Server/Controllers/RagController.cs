using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EuroStone_AI_Chat_Server.Config;
using EuroStone_AI_Chat_Server.Data;
using EuroStone_AI_Chat_Server.Models;
using EuroStone_AI_Chat_Server.Services;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace EuroStone_AI_Chat_Server.Controllers
{
    // Ez a Controller kezeli a RAG (Retrieval-Augmented Generation) funkciókat.
    // Itt történik a chat munkamenetek létrehozása és a kérdések megválaszolása.
    [ApiController]
    [Route("[controller]")]
    public class RagController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly OllamaService _ollamaService;

        // Konstruktor: megkapjuk az adatbázis kontextust és az AI szolgáltatást.
        public RagController(AppDbContext context, OllamaService ollamaService)
        {
            _context = context;
            _ollamaService = ollamaService;
        }

        // Új chat munkamenet létrehozása.
        // POST: /rag/createSession
        [HttpPost("createSession")]
        public async Task<ActionResult<ChatSession>> CreateSession()
        {
            var session = new ChatSession
            {
                KeyToken = GenerateRandomString(16), // Egyedi azonosító generálása
                CreatedAt = DateTime.UtcNow
            };

            _context.ChatSessions.Add(session);
            await _context.SaveChangesAsync();

            return Ok(session);
        }

        // Kérés objektum a kérdés feltevéséhez.
        public class AskRequest
        {
            public int ChatSessionId { get; set; } // Melyik munkamenethez tartozik
            public string Question { get; set; } = string.Empty; // A felhasználó kérdése
            public bool SearchListPanels { get; set; } // Keressünk-e az adatbázisban (Schema RAG)?
        }

        // Kérdés megválaszolása STREAMING módban.
        // POST: /rag/ask
        // Nem adunk vissza ActionResult-ot, hanem közvetlenül írunk a Response stream-re.
        [HttpPost("ask")]
        public async Task Ask([FromBody] AskRequest request)
        {
            // Beállítjuk a válasz típusát NDJSON-re (Newline Delimited JSON) vagy sima text-re, amit streamelünk.
            Response.ContentType = "application/x-ndjson";
            
            // Segédfüggvény a stream íráshoz
            async Task SendStatus(string status)
            {
                var json = JsonSerializer.Serialize(new { type = "status", content = status });
                await Response.WriteAsync(json + "\n");
                await Response.Body.FlushAsync();
            }

            async Task SendResult(string result)
            {
                var json = JsonSerializer.Serialize(new { type = "result", content = result });
                await Response.WriteAsync(json + "\n");
                await Response.Body.FlushAsync();
            }

            async Task SendError(string error)
            {
                var json = JsonSerializer.Serialize(new { type = "error", content = error });
                await Response.WriteAsync(json + "\n");
                await Response.Body.FlushAsync();
            }

            try 
            {
                // 1. Munkamenet ellenőrzése
                await SendStatus("Munkamenet ellenőrzése...");
                var chatSession = await _context.ChatSessions.FindAsync(request.ChatSessionId);
                if (chatSession == null)
                {
                    await SendError($"Chat session not found (ID: {request.ChatSessionId})");
                    return;
                }

                // 3. Felhasználói kérdés mentése az adatbázisba
                var userMsg = new ChatMessage
                {
                    ChatSessionId = request.ChatSessionId,
                    Message = request.Question,
                    Type = ChatMessageType.User,
                    CreatedAt = DateTime.UtcNow
                };
                _context.ChatMessages.Add(userMsg);
                await _context.SaveChangesAsync();

                if (request.SearchListPanels)
                {
                    // --- Schema Search Mode (Adatbázis alapú keresés) ---

                    await SendStatus("Adatbázis séma betöltése...");
                    // Lekérjük az elérhető táblák leírását (egyszerűsítés: mindet lekérjük)
                    var panels = await _context.ListPanelTableDescriptions.ToListAsync();
                    
                    // Összeállítjuk a táblák leírását a prompt számára
                    var panelDescBuilder = new StringBuilder();
                    foreach (var p in panels)
                    {
                        string tableName = "unknown_table";
                        // Itt rendeljük hozzá a fizikai táblaneveket a DistributionId alapján
                        if (p.DistributionId == 125) tableName = "list_panel_suplier_data";
                        if (p.DistributionId == 15) tableName = "mock_country_data";
                        panelDescBuilder.AppendLine($"ID: {p.DistributionId}, SQL Tábla: {tableName}, Név: {p.NameHun}\n   Leírás: {p.DescriptionHun}");
                        panelDescBuilder.AppendLine();
                    }

                    var currentDate = DateTime.UtcNow.ToString("yyyy-MM-dd");
                    // Létrehozzuk a promptot, ami arra kéri az AI-t, hogy készítsen egy lekérdezési tervet (JSON).
                    var prompt = Prompts.GetQueryPlanPrompt(request.Question, panelDescBuilder.ToString(), currentDate);

                    await SendStatus("Lekérdezési terv készítése (AI)...");
                    // AI hívása a terv elkészítéséhez
                    var planJsonRaw = await _ollamaService.GeneratePlanAsync(prompt);
                    
                    // JSON tisztítása (néha az AI extra szöveget is fűz hozzá)
                    var cleanJson = planJsonRaw;
                    var firstBrace = cleanJson.IndexOf('{');
                    var lastBrace = cleanJson.LastIndexOf('}');
                    
                    if (firstBrace >= 0 && lastBrace > firstBrace)
                    {
                        cleanJson = cleanJson.Substring(firstBrace, lastBrace - firstBrace + 1);
                    }
                    
                    // Console.WriteLine($"DEBUG: Clean JSON: {cleanJson}");

                    try 
                    {
                        // JSON parse-olása
                        var plan = JsonNode.Parse(cleanJson, null, new JsonDocumentOptions { CommentHandling = JsonCommentHandling.Skip });
                        if (plan == null) throw new Exception("Failed to parse JSON plan");

                        // Kezeljük azt az esetet, ha az AI tömböt ad vissza objektum helyett
                        if (plan is JsonArray jsonArray && jsonArray.Count > 0)
                        {
                            plan = jsonArray[0];
                        }

                        if (plan is not JsonObject)
                        {
                            throw new Exception($"JSON is not an object. Type: {plan.GetType().Name}");
                        }

                        await SendStatus("SQL lekérdezés futtatása...");
                        // Dinamikus SQL lekérdezés végrehajtása a terv alapján
                        var results = await ExecuteDynamicQueryAsync(plan);

                        if (results.Count == 0)
                        {
                            var noDataMsg = "Sajnos nem találtam adatot a megadott feltételekkel az adatbázisban.";
                            await SaveModelMessage(request.ChatSessionId, noDataMsg);
                            await SendResult(noDataMsg);
                            return;
                        }

                        // Eredmények formázása szöveges formátumba az AI számára
                        var displayFields = plan["displayFields"]?.AsArray();
                        var aiLabelMap = new Dictionary<string, string>();
                        if (displayFields != null)
                        {
                            foreach (var field in displayFields)
                            {
                                if (field == null) continue;
                                var col = field["column"]?.ToString();
                                var label = field["label"]?.ToString();
                                if (col != null && label != null) aiLabelMap[col] = label;
                            }
                        }

                        var rawContextBuffer = new StringBuilder();
                        foreach (var row in results)
                        {
                            rawContextBuffer.AppendLine("--- Adatsor ---");
                            var rowDict = (IDictionary<string, object>)row;
                            foreach (var kvp in rowDict)
                            {
                                var valStr = kvp.Value?.ToString() ?? "";
                                if (kvp.Value is DateTime dt) valStr = dt.ToString("yyyy-MM-dd");
                                
                                // Használjuk a címkéket, ha vannak, különben az oszlopnevet
                                var label = aiLabelMap.ContainsKey(kvp.Key) ? aiLabelMap[kvp.Key] : kvp.Key;
                                rawContextBuffer.AppendLine($"{label}: {valStr}");
                            }
                        }

                        await SendStatus("Válasz megfogalmazása (AI)...");
                        // Végső válasz generálása az AI-val az adatok alapján
                        var finalResponse = await _ollamaService.GenerateResponseAsync("", Prompts.GetOllamaPrompt(request.Question, rawContextBuffer.ToString()));

                        await SaveModelMessage(request.ChatSessionId, finalResponse);
                        await SendResult(finalResponse);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error: {ex}");
                        var errorMsg = "Hiba történt a lekérdezés feldolgozása közben.";
                        await SaveModelMessage(request.ChatSessionId, errorMsg);
                        await SendError(errorMsg);
                    }
                }
                else
                {
                    // Dokumentum alapú keresés (még nincs implementálva)
                    var msg = "A dokumentum alapú keresés jelenleg nem elérhető.";
                    await SaveModelMessage(request.ChatSessionId, msg);
                    await SendResult(msg);
                }
            }
            catch (Exception ex)
            {
                 Console.WriteLine($"Critical Error: {ex}");
                 await SendError("Kritikus szerver hiba történt.");
            }
        }

        // Segédfüggvény az AI válaszának mentéséhez
        private async Task SaveModelMessage(int sessionId, string message)
        {
            _context.ChatMessages.Add(new ChatMessage
            {
                ChatSessionId = sessionId,
                Message = message,
                Type = ChatMessageType.Model,
                CreatedAt = DateTime.UtcNow
            });
            await _context.SaveChangesAsync();
        }

        // Dinamikus SQL lekérdezés végrehajtása a JSON terv alapján
        private async Task<List<dynamic>> ExecuteDynamicQueryAsync(JsonNode plan)
        {
            var tableName = plan["tableName"]?.ToString();
            var displayFields = plan["displayFields"]?.AsArray();
            var filters = plan["filters"]?.AsArray();
            var orderBy = plan["orderBy"];
            var limit = plan["limit"]?.GetValue<int>() ?? 10;

            // Táblanév validálása (biztonsági okokból)
            if (string.IsNullOrEmpty(tableName) || !IsAlphaNumeric(tableName)) throw new Exception("Invalid table name");

            // SELECT rész összeállítása
            var selectClause = "*";
            if (displayFields != null && displayFields.Count > 0)
            {
                var cols = new List<string>();
                foreach (var f in displayFields)
                {
                    if (f == null) continue;
                    var col = f["column"]?.ToString();
                    if (col != null && IsAlphaNumeric(col)) cols.Add($"\"{col}\"");
                }
                if (cols.Count > 0) selectClause = string.Join(", ", cols);
            }

            var sql = $"SELECT {selectClause} FROM \"{tableName}\" WHERE 1=1";
            var parameters = new DynamicParameters();

            // WHERE feltételek összeállítása
            if (filters != null)
            {
                int i = 0;
                foreach (var f in filters)
                {
                    if (f == null) continue;
                    var col = f["column"]?.ToString();
                    var op = f["operator"]?.ToString();
                    var val = f["value"]?.ToString();

                    if (col != null && IsAlphaNumeric(col) && IsValidOperator(op))
                    {
                        sql += $" AND \"{col}\" {op} @p{i}";
                        
                        // Dátum típus kezelése PostgreSQL számára
                        if (DateTime.TryParse(val, out DateTime dateVal))
                        {
                            parameters.Add($"p{i}", dateVal);
                        }
                        else
                        {
                            parameters.Add($"p{i}", val);
                        }
                        
                        i++;
                    }
                }
            }

            // ORDER BY rendezés
            if (orderBy != null && orderBy is JsonObject)
            {
                var orderCol = orderBy["column"]?.ToString();
                var direction = orderBy["direction"]?.ToString() == "DESC" ? "DESC" : "ASC";
                if (orderCol != null && IsAlphaNumeric(orderCol))
                {
                    sql += $" ORDER BY \"{orderCol}\" {direction}";
                }
            }

            // LIMIT korlátozás
            if (limit > 50) limit = 50;
            sql += $" LIMIT {limit}";

            // Kapcsolat lekérése az EF Core-tól (nem használunk 'using'-ot, mert a context kezeli)
            var connection = _context.Database.GetDbConnection();
            
            Console.WriteLine($"DEBUG: Executing SQL: {sql}");
            foreach (var p in parameters.ParameterNames)
            {
                Console.WriteLine($"DEBUG: Param {p}: {parameters.Get<dynamic>(p)}");
            }

            // Dapper használata a lekérdezés futtatásához
            var result = await connection.QueryAsync(sql, parameters);
            return result.ToList();
        }

        // Biztonsági ellenőrzések (SQL Injection ellen)
        private bool IsAlphaNumeric(string s) => s.All(c => char.IsLetterOrDigit(c) || c == '_');
        private bool IsValidOperator(string? op) => new[] { "=", "!=", ">", "<", ">=", "<=", "ILIKE" }.Contains(op?.ToUpper());

        private string GenerateRandomString(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            var random = new Random();
            return new string(Enumerable.Repeat(chars, length).Select(s => s[random.Next(s.Length)]).ToArray());
        }
    }
}
