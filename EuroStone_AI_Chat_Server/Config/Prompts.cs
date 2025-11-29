namespace EuroStone_AI_Chat_Server.Config
{
    public static class Prompts
    {
        public static string GetQueryPlanPrompt(string question, string panelDesc, string currentDate)
        {
            return $@"
A felhasználó kérdése: ""{question}""

Elérhető táblák definíciója:
{panelDesc}

A 'list_panel_suplier_data' (Szállítók) tábla fontosabb mezői (CSAK ezeket használd, NE találj ki újakat!):
A ""displayFields"" tömbben sorold fel a szükséges mezőket. Minden elemnél add meg:
 - ""column"": az SQL mező neve (pl. vendorName, amount, countryCode, category, lastActivity)
 - ""label"": a mező magyar neve (a séma alapján)
A ""filters"" tömbben sorold fel a feltételeket.
Az operátor lehet: ""="", ""!="", "">"", ""<"", ""ILIKE"" (szöveges keresésnél).


Szabályok:
1. **Dátumok:** Ha a kérdés időtartamra vonatkozik (pl. ""elmúlt 6 hónap""), számold ki a pontos kezdő dátumot a Mai dátumhoz ({currentDate}) képest! Használd a "">="" operátort a 'lastActivity' mezőn.
2. **Rendezés:** Ha a kérdés ""legnagyobb"", ""legkisebb"" vagy sorrendet kér, használd az ""orderBy"" mezőt.

Kimeneti formátum (Csak a nyers JSON):
{{
  ""tableName"": ""list_panel_suplier_data"", // VAGY ""mock_country_data""
  ""displayFields"": [
     {{""column"": ""vendorName"", ""label"": ""Szállító""}},
     {{""column"": ""amount"", ""label"": ""Összeg""}}
  ], // Csak a lényeges mezőket (column) add vissza a hozzá tartozó magyar megnevezéssel
  ""filters"": [
    {{""column"": ""countryCode"", ""operator"": ""="", ""value"": ""CZ""}}
  ],
  ""limit"": 10
}}
";
        }
        

        public static string GetOllamaPrompt(string userQuestion, string rawDataContext)
        {
            return $@"
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
Te egy segítőkész, udvarias és precíz magyar üzleti asszisztens vagy.
A feladatod: Az alább megadott ADATBÁZIS EREDMÉNYEK alapján válaszolj a felhasználó kérdésére.
Fogalmazz természetes, helyes magyarsággal. Kerüld a bonyolult, magyartalan körmondatokat.
Ha felsorolást adsz, csak egy rövid bevezetőt írj (pl. ""Íme a kért adatok:"" vagy ""A keresett partnerek:""), majd sorold fel az eredményeket.
Ne használj technikai kifejezéseket (pl. ""JSON"", ""array"").
Használj Markdown formázást (félkövér, felsorolás) az áttekinthetőségért.

<|eot_id|><|start_header_id|>user<|end_header_id|>
FELHASZNÁLÓ KÉRDÉSE: ""{userQuestion}""

ADATBÁZIS EREDMÉNYEK (Ezek a tények, amiből dolgoznod kell):
{rawDataContext}

<|eot_id|><|start_header_id|>assistant<|end_header_id|>
";
        }
    }
}
