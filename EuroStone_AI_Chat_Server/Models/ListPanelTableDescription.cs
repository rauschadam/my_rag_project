using System.ComponentModel.DataAnnotations.Schema;

namespace EuroStone_AI_Chat_Server.Models
{
    [Table("list_panel_table_description")]
    public class ListPanelTableDescription
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("distributionId")]
        public int DistributionId { get; set; }

        [Column("nameHun")]
        public string NameHun { get; set; } = string.Empty;

        [Column("descriptionHun")]
        public string DescriptionHun { get; set; } = string.Empty;

        [Column("businessDescriptionHun")]
        public string BusinessDescriptionHun { get; set; } = string.Empty;
    }
}
