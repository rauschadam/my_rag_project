using Microsoft.EntityFrameworkCore;
using EuroStone_AI_Chat_Server.Models;

namespace EuroStone_AI_Chat_Server.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<ChatSession> ChatSessions { get; set; }
        public DbSet<ChatMessage> ChatMessages { get; set; }
        public DbSet<ListPanelTableDescription> ListPanelTableDescriptions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<ChatMessage>()
                .Property(m => m.Type)
                .HasConversion<string>();
        }
    }
}
