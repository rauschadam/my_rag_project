using System;
using System.ComponentModel.DataAnnotations;

namespace EuroStone_AI_Chat_Server.Models
{
    // Enum az üzenet típusának meghatározására (Felhasználó vagy Modell).
    public enum ChatMessageType
    {
        User,  // Felhasználó üzenete
        Model  // AI válasza
    }

    // Ez az osztály reprezentál egy chat üzenetet az adatbázisban.
    public class ChatMessage
    {
        public int Id { get; set; } // Elsődleges kulcs

        public int ChatSessionId { get; set; } // Külső kulcs a ChatSession táblához
        public ChatSession? ChatSession { get; set; } // Navigációs tulajdonság

        [Required]
        public string Message { get; set; } = string.Empty; // Az üzenet szövege

        public ChatMessageType Type { get; set; } // Az üzenet típusa

        public DateTime CreatedAt { get; set; } // Létrehozás ideje
    }
}
