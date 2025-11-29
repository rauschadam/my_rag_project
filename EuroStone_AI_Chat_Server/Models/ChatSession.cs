using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EuroStone_AI_Chat_Server.Models
{
    public class ChatSession
    {
        public int Id { get; set; }

        [Required]
        public string KeyToken { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; }

        public List<ChatMessage> Messages { get; set; } = new();
    }
}
