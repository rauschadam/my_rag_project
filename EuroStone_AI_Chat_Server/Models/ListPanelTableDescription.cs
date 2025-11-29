using System.ComponentModel.DataAnnotations.Schema;

namespace EuroStone_AI_Chat_Server.Models
{
    // Ez az osztály írja le az adatbázisban elérhető táblák metaadatait.
    // Ezt használjuk arra, hogy az AI tudja, milyen táblákban kereshet.
    [Table("list_panel_table_description")] // Az adatbázis tábla neve
    public class ListPanelTableDescription
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("distributionId")]
        public int DistributionId { get; set; } // Egyedi azonosító a rendszerben

        [Column("nameHun")]
        public string NameHun { get; set; } = string.Empty; // A tábla magyar neve

        [Column("descriptionHun")]
        public string DescriptionHun { get; set; } = string.Empty; // A tábla magyar leírása (AI számára fontos)

        [Column("businessDescriptionHun")]
        public string BusinessDescriptionHun { get; set; } = string.Empty; // Üzleti leírás
    }
}
