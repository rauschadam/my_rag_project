using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EuroStone_AI_Chat_Server.Models
{
    // Ez az osztály reprezentál egy chat munkamenetet (beszélgetést).
    public class ChatSession
    {
        public int Id { get; set; } // Elsődleges kulcs

        [Required]
        public string KeyToken { get; set; } = string.Empty; // Egyedi azonosító token (kliens oldali azonosításhoz)

        public DateTime CreatedAt { get; set; } // Létrehozás ideje

        // A beszélgetéshez tartozó üzenetek listája.
        public List<ChatMessage> Messages { get; set; } = new();
    }
}
