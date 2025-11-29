using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.ChatCompletion;
using Microsoft.SemanticKernel.Connectors.OpenAI;

namespace EuroStone_AI_Chat_Server.Services
{
    public class OllamaService
    {
        private readonly IChatCompletionService _chatCompletionService;

        public OllamaService(IChatCompletionService chatCompletionService)
        {
            _chatCompletionService = chatCompletionService;
        }

        public async Task<string> GenerateResponseAsync(string systemPrompt, string userPrompt)
        {
            var history = new ChatHistory();
            if (!string.IsNullOrWhiteSpace(systemPrompt))
            {
                history.AddSystemMessage(systemPrompt);
            }
            history.AddUserMessage(userPrompt);

            var result = await _chatCompletionService.GetChatMessageContentAsync(history);
            return result.Content ?? string.Empty;
        }

        public async Task<string> GeneratePlanAsync(string prompt)
        {
            var history = new ChatHistory();
            history.AddUserMessage(prompt);

            // Enforce JSON mode for Ollama
            var settings = new OpenAIPromptExecutionSettings { ResponseFormat = "json_object" };
            var result = await _chatCompletionService.GetChatMessageContentAsync(history, settings);
            return result.Content ?? string.Empty;
        }
    }
}
