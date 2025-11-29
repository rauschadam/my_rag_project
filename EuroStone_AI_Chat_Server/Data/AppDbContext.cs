using Microsoft.EntityFrameworkCore;
using EuroStone_AI_Chat_Server.Models;

namespace EuroStone_AI_Chat_Server.Data
{
    // Ez az osztály reprezentálja az adatbázis kapcsolatot és a táblákat.
    // Az Entity Framework Core (EF Core) ezt használja az SQL műveletek végrehajtásához.
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        // Ezek a tulajdonságok (DbSet) felelnek meg az adatbázis tábláinak.
        public DbSet<ChatSession> ChatSessions { get; set; } // Chat munkamenetek tábla
        public DbSet<ChatMessage> ChatMessages { get; set; } // Chat üzenetek tábla
        public DbSet<ListPanelTableDescription> ListPanelTableDescriptions { get; set; } // Tábla leírások (metaadatok)

        // Itt konfigurálhatjuk a modellek viselkedését (pl. típuskonverziók).
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // A ChatMessage.Type enum-ot stringként tároljuk az adatbázisban (pl. "User", "Model").
            modelBuilder.Entity<ChatMessage>()
                .Property(m => m.Type)
                .HasConversion<string>();
        }
    }
}
