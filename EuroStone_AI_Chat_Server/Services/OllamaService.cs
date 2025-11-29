using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;

namespace EuroStone_AI_Chat_Server.Services
{
    // Ez az osztály felelős az AI-val (Ollama) való kommunikációért.
    public class OllamaService
    {
        // A Semantic Kernel chat szolgáltatása.
        private readonly IChatCompletionService _chatCompletionService;

        // Konstruktor: Itt kapjuk meg a szükséges szolgáltatásokat (Dependency Injection).
        public OllamaService(IChatCompletionService chatCompletionService)
        {
            _chatCompletionService = chatCompletionService;
        }

        // Általános válasz generálása (pl. a végső válasz a felhasználónak).
        public async Task<string> GenerateResponseAsync(string systemPrompt, string userPrompt)
        {
            var history = new ChatHistory();
            
            // Ha van rendszerüzenet (utasítás az AI-nak), hozzáadjuk.
            if (!string.IsNullOrWhiteSpace(systemPrompt))
            {
                history.AddSystemMessage(systemPrompt);
            }
            
            // Hozzáadjuk a felhasználó üzenetét.
            history.AddUserMessage(userPrompt);

            // Elküldjük a kérést az AI-nak és várjuk a választ.
            var result = await _chatCompletionService.GetChatMessageContentAsync(history);
            return result.Content ?? string.Empty;
        }

        // Terv (SQL lekérdezés terve) generálása.
        // Ez a metódus JSON formátumú választ vár el az AI-tól.
        public async Task<string> GeneratePlanAsync(string prompt)
        {
            var history = new ChatHistory();
            history.AddUserMessage(prompt);

            // JSON mód kényszerítése az Ollama-nál (hogy biztosan strukturált adatot kapjunk).
            var settings = new OpenAIPromptExecutionSettings { ResponseFormat = "json_object" };
            
            // Elküldjük a kérést a speciális beállításokkal.
            var result = await _chatCompletionService.GetChatMessageContentAsync(history, settings);
            return result.Content ?? string.Empty;
        }
    }
}
