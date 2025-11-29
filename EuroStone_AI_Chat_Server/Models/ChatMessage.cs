using System;
using System.ComponentModel.DataAnnotations;

namespace EuroStone_AI_Chat_Server.Models
{
    public enum ChatMessageType
    {
        User,
        Model
    }

    public class ChatMessage
    {
        public int Id { get; set; }

        public int ChatSessionId { get; set; }
        public ChatSession? ChatSession { get; set; }

        [Required]
        public string Message { get; set; } = string.Empty;

        public ChatMessageType Type { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
