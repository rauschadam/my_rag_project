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
    [ApiController]
    [Route("[controller]")]
    public class RagController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly OllamaService _ollamaService;

        public RagController(AppDbContext context, OllamaService ollamaService)
        {
            _context = context;
            _ollamaService = ollamaService;
        }

        [HttpPost("createSession")]
        public async Task<ActionResult<ChatSession>> CreateSession()
        {
            var session = new ChatSession
            {
                KeyToken = GenerateRandomString(16),
                CreatedAt = DateTime.UtcNow
            };

            _context.ChatSessions.Add(session);
            await _context.SaveChangesAsync();

            return Ok(session);
        }

        public class AskRequest
        {
            public int ChatSessionId { get; set; }
            public string Question { get; set; } = string.Empty;
            public bool SearchListPanels { get; set; }
        }

        [HttpPost("ask")]
        public async Task<ActionResult<string>> Ask([FromBody] AskRequest request)
        {
            // 1. Verify session
            var chatSession = await _context.ChatSessions.FindAsync(request.ChatSessionId);
            if (chatSession == null)
            {
                return NotFound($"Chat session not found (ID: {request.ChatSessionId})");
            }

            // 2. Load history (not used in prompt yet, but good to have)
            // var history = await _context.ChatMessages
            //     .Where(m => m.ChatSessionId == request.ChatSessionId)
            //     .OrderBy(m => m.CreatedAt)
            //     .ToListAsync();

            // 3. Save User Question
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
                // --- Schema Search Mode ---

                // Fetch all panels (simplification for now)
                var panels = await _context.ListPanelTableDescriptions.ToListAsync();
                
                var panelDescBuilder = new StringBuilder();
                foreach (var p in panels)
                {
                    string tableName = "unknown_table";
                    if (p.DistributionId == 125) tableName = "list_panel_suplier_data";
                    if (p.DistributionId == 15) tableName = "mock_country_data";
                    panelDescBuilder.AppendLine($"ID: {p.DistributionId}, SQL Tábla: {tableName}, Név: {p.NameHun}\n   Leírás: {p.DescriptionHun}");
                    panelDescBuilder.AppendLine();
                }

                var currentDate = DateTime.UtcNow.ToString("yyyy-MM-dd");
                var prompt = Prompts.GetQueryPlanPrompt(request.Question, panelDescBuilder.ToString(), currentDate);

                // Call AI for Plan
                var planJsonRaw = await _ollamaService.GeneratePlanAsync(prompt);
                
                // Clean JSON
                // Clean JSON - Robust extraction
                var cleanJson = planJsonRaw;
                var firstBrace = cleanJson.IndexOf('{');
                var lastBrace = cleanJson.LastIndexOf('}');
                
                if (firstBrace >= 0 && lastBrace > firstBrace)
                {
                    cleanJson = cleanJson.Substring(firstBrace, lastBrace - firstBrace + 1);
                }
                else 
                {
                     // Fallback or error if no JSON found
                     Console.WriteLine($"Warning: No JSON object found in AI response: {planJsonRaw}");
                }
                
                Console.WriteLine($"DEBUG: Clean JSON: {cleanJson}");

                try 
                {
                    var plan = JsonNode.Parse(cleanJson, null, new JsonDocumentOptions { CommentHandling = JsonCommentHandling.Skip });
                    if (plan == null) throw new Exception("Failed to parse JSON plan");

                    // Handle if AI returns an array instead of an object
                    if (plan is JsonArray jsonArray && jsonArray.Count > 0)
                    {
                        plan = jsonArray[0];
                    }

                    if (plan is not JsonObject)
                    {
                        throw new Exception($"JSON is not an object. Type: {plan.GetType().Name}");
                    }

                    // Execute Dynamic Query
                    var results = await ExecuteDynamicQueryAsync(plan);

                    if (results.Count == 0)
                    {
                        var noDataMsg = "Sajnos nem találtam adatot a megadott feltételekkel az adatbázisban.";
                        await SaveModelMessage(request.ChatSessionId, noDataMsg);
                        return Ok(noDataMsg);
                    }

                    // Format results
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
                            
                            var label = aiLabelMap.ContainsKey(kvp.Key) ? aiLabelMap[kvp.Key] : kvp.Key;
                            rawContextBuffer.AppendLine($"{label}: {valStr}");
                        }
                    }

                    // Generate Final Response
                    var finalResponse = await _ollamaService.GenerateResponseAsync("", Prompts.GetOllamaPrompt(request.Question, rawContextBuffer.ToString()));

                    await SaveModelMessage(request.ChatSessionId, finalResponse);
                    return Ok(finalResponse);

                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex}");
                    var errorMsg = "Hiba történt a lekérdezés feldolgozása közben.";
                    await SaveModelMessage(request.ChatSessionId, errorMsg);
                    return Ok(errorMsg);
                }
            }
            else
            {
                // Content Search - Skipped
                var msg = "A dokumentum alapú keresés jelenleg nem elérhető.";
                await SaveModelMessage(request.ChatSessionId, msg);
                return Ok(msg);
            }
        }

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

        private async Task<List<dynamic>> ExecuteDynamicQueryAsync(JsonNode plan)
        {
            var tableName = plan["tableName"]?.ToString();
            var displayFields = plan["displayFields"]?.AsArray();
            var filters = plan["filters"]?.AsArray();
            var orderBy = plan["orderBy"];
            var limit = plan["limit"]?.GetValue<int>() ?? 10;

            // Validate tableName
            if (string.IsNullOrEmpty(tableName) || !IsAlphaNumeric(tableName)) throw new Exception("Invalid table name");

            // Build SELECT
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

            // Build WHERE
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
                        
                        // Try to parse as DateTime to ensure correct parameter type for PostgreSQL
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

            // Build ORDER BY
            if (orderBy != null && orderBy is JsonObject)
            {
                var orderCol = orderBy["column"]?.ToString();
                var direction = orderBy["direction"]?.ToString() == "DESC" ? "DESC" : "ASC";
                if (orderCol != null && IsAlphaNumeric(orderCol))
                {
                    sql += $" ORDER BY \"{orderCol}\" {direction}";
                }
            }

            // LIMIT
            if (limit > 50) limit = 50;
            sql += $" LIMIT {limit}";

            // Do NOT use 'using' here because the connection is managed by EF Core context
            var connection = _context.Database.GetDbConnection();
            
            Console.WriteLine($"DEBUG: Executing SQL: {sql}");
            foreach (var p in parameters.ParameterNames)
            {
                Console.WriteLine($"DEBUG: Param {p}: {parameters.Get<dynamic>(p)}");
            }

            var result = await connection.QueryAsync(sql, parameters);
            return result.ToList();
        }

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
