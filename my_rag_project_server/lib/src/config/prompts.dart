class Prompts {
  /// HUNGARIAN PROMPT: Ask the AI to plan the SQL query in JSON format.
  /// 
  /// Requires the following variables to be interpolated:
  /// - ${question}: The user's question
  /// - ${panelDesc}: Description of available tables
  /// - ${currentDate}: The current date (YYYY-MM-DD)
  static String getQueryPlanPrompt(String question, String panelDesc, String currentDate) {
    return '''
A felhasználó kérdése: "$question"

Elérhető táblák definíciója:
$panelDesc

A 'list_panel_suplier_data' (Szállítók) tábla fontosabb mezői (PONTOSAN ezeket használd):
- vendorName (Szállító neve, szöveg)
- countryCode (Országkód, pl. HU, CZ, DE, szöveg)
- category (Kategória, pl. Szolgáltatás, Termék, szöveg)
- amount (Összeg, szöveg)
- lastActivity (Utolsó aktivitás dátuma, pl. "2025-10-01", Dátum típus)

A 'mock_country_data' (Országok - Panel 15):
   - countryName (Ország neve, pl. "Magyarország")
   - isoCode (Kétbetűs kód, pl. HU)
   - isEuMember (EU tag? true/false)
   - isNatoMember (NATO tag? true/false)

FELADAT: 
Döntsd el, melyik tábla releváns a kérdéshez (Szállítók VAGY Országok).
Elemzed a kérdést és készíts egy SQL-szerű lekérdezési tervet JSON formátumban.

A "tableName" -be kerül a tábla neve, ahonnan lekérdezést hajtjuk végre
A "displayFields" tömbben sorold fel a szükséges mezőket. Minden elemnél add meg:
 - "column": az SQL mező neve
 - "label": a mező magyar neve (a séma alapján)
A "filters" tömbben sorold fel a feltételeket.
Az operátor lehet: "=", "!=", ">", "<", "ILIKE" (szöveges keresésnél).


Szabályok:
1. **Dátumok:** Ha a kérdés időtartamra vonatkozik (pl. "elmúlt 6 hónap"), számold ki a pontos kezdő dátumot a Mai dátumhoz ($currentDate) képest! Használd a ">=" operátort a 'lastActivity' mezőn.
2. **Rendezés:** Ha a kérdés "legnagyobb", "legkisebb" vagy sorrendet kér, használd az "orderBy" mezőt.

Kimeneti formátum (Csak a nyers JSON):
{
  "tableName": "list_panel_suplier_data", // VAGY "mock_country_data"
  "displayFields": [
     {"column": "vendorName", "label": "Szállító"},
     {"column": "amount", "label": "Összeg"}
  ], // Csak a lényeges mezőket (column) add vissza a hozzá tartozó magyar megnevezéssel
  "filters": [
    {"column": "countryCode", "operator": "=", "value": "CZ"},
    {"column": "vendorName", "operator": "ILIKE", "value": "%Szolgáltatás%"}
  ],
  "limit": 10
}
''';
  }

  /// HUNGARIAN PROMPT: General assistant prompt for document search.
  static const String systemPromptDocuments =
      'Te egy segítőkész AI asszisztens vagy. Válaszolj a kérdésre KIZÁRÓLAG a megadott dokumentumok alapján. Ha a válasz nincs benne a dokumentumokban, mondd azt: "A megadott kontextus alapján nem tudok válaszolni".';

  /// HUNGARIAN PROMPT: Refine the SQL result into a natural language response.
  /// 
  /// Requires:
  /// - ${userQuestion}: The user's original question
  /// - ${rawDataContext}: The raw data returned from the database
  static String getOllamaPrompt(String userQuestion, String rawDataContext) {
    return '''
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
Te egy segítőkész, udvarias és precíz magyar üzleti asszisztens vagy.
A feladatod: Az alább megadott ADATBÁZIS EREDMÉNYEK alapján válaszolj a felhasználó kérdésére.
Fogalmazz természetes, kerek mondatokban magyarul. A válaszod legyen lényegre törő.
Ne használj technikai kifejezéseket (pl. "JSON", "array"), hanem úgy beszélj, mint egy elemző.
Használj Markdown formázást (félkövér, felsorolás) az áttekinthetőségért.

<|eot_id|><|start_header_id|>user<|end_header_id|>
FELHASZNÁLÓ KÉRDÉSE: "$userQuestion"

ADATBÁZIS EREDMÉNYEK (Ezek a tények, amiből dolgoznod kell):
$rawDataContext

<|eot_id|><|start_header_id|>assistant<|end_header_id|>
''';
  }
}
