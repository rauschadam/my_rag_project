import 'package:serverpod/serverpod.dart';
import 'package:my_rag_project_server/src/generated/protocol.dart';
import 'package:my_rag_project_server/src/generative_ai/generative_ai.dart';

/// Handles the import of database schema metadata (ListPanels and Fields) into the vector store.
class SchemaImporter {
  /// Imports example metadata based on the EuroStone specification.
  /// In production, this would fetch data from your actual MySQL 'Sys_ListPanels' table.
  static Future<void> importSchemaData(Session session) async {
    final genAi = GenerativeAi();
    session.log('Starting schema import...', level: LogLevel.info);

    // Fake data for the 125 list panel
    final oldData = await ListPanelSupplierData.db
        .find(session, where: (_) => Constant.bool(true));
    for (var d in oldData) {
      await ListPanelSupplierData.db.deleteRow(session, d);
    }

    final mockRows = [
      ListPanelSupplierData(
        vendorName: 'TÜV NORD Czech s.r.o.',
        countryCode: 'CZ',
        category: 'Szolgáltatás',
        amount: '1500 EUR',
        lastActivity: DateTime.now().subtract(Duration(days: 20)),
      ),
      ListPanelSupplierData(
        vendorName: "Lloyd's Register EMEA",
        countryCode: 'CZ',
        category: 'Szolgáltatás',
        amount: '2300 EUR',
        lastActivity: DateTime.now().subtract(Duration(days: 45)),
      ),
      ListPanelSupplierData(
        vendorName: 'FleetCor UK International Management Ltd. CZ',
        countryCode: 'CZ',
        category: 'Szolgáltatás',
        amount: '500 EUR',
        lastActivity: DateTime.now().subtract(Duration(days: 10)),
      ),
      ListPanelSupplierData(
        vendorName: 'Apple Distribution International Ltd.',
        countryCode: 'CZ',
        category: 'Termék',
        amount: '12000 EUR',
        lastActivity: DateTime.now().subtract(Duration(days: 5)),
      ),
      ListPanelSupplierData(
        vendorName: 'VITKOVICE STEEL, a.s.',
        countryCode: 'CZ',
        category: 'Vegyes',
        amount: '5000 EUR',
        lastActivity: DateTime.now().subtract(Duration(days: 100)),
      ),
      ListPanelSupplierData(
        vendorName: 'Öveges Acél Kft.',
        countryCode: 'HU',
        category: 'Termék',
        amount: '300000 HUF',
        lastActivity: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];

    for (var row in mockRows) {
      await ListPanelSupplierData.db.insertRow(session, row);
    }
    session.log('Mock Supplier Data imported: ${mockRows.length} rows');

    // --- 1. IMPORT LIST PANELS (Tables) ---
    // Example data from spec: DistributionId 15 and 125
    final panels = [
      {
        'id': 15,
        'name': 'Föld országai',
        'desc':
            'Tartalmazza minden ország magyar nevét, EU tagságát, Nato tagságát, kétbetűs iso kódját.',
        'bus':
            'Magyar, EU-s és 3. országbeli partnerek is lehetnek a vevők, szállítók csak Magyar cégek lehetnek.',
      },
      {
        'id': 125,
        'name': 'P14B NAV szállítók fej',
        'desc':
            'Szállítók utolsó 6 havi adatainak összesítése szállítói számlák alapján NAVI modul paraméterezéséhez.',
        'bus':
            'Szállítói analitika, partner forgalom, országkód szerinti bontás.',
      },
    ];

    for (final p in panels) {
      // Create a rich description for the AI to embed
      final textToEmbed =
          'Listapanel: ${p['name']}\nLeírás: ${p['desc']}\nÜgyvitel: ${p['bus']}';
      final embedding = await genAi.generateEmbedding(textToEmbed);

      // Check if exists to avoid duplicates
      final existing = await ListPanelTableDescription.db.findFirstRow(
        session,
        where: (t) => t.distributionId.equals(p['id'] as int),
      );

      final row = ListPanelTableDescription(
        distributionId: p['id'] as int,
        nameHun: p['name'] as String,
        descriptionHun: p['desc'] as String,
        businessDescriptionHun: p['bus'] as String,
        embedding: embedding,
      );

      if (existing != null) {
        row.id = existing.id;
        await ListPanelTableDescription.db.updateRow(session, row);
      } else {
        await ListPanelTableDescription.db.insertRow(session, row);
      }
      session.log('Imported Panel: ${p['name']}');
    }

    // --- 2. IMPORT FIELDS (Columns) ---
    // Example fields for Panel 15 & 125
    final fields = [
      {
        'panelId': 15,
        'eng': 'CountryCode',
        'hun': 'Ország kód',
        'desc':
            'Az ISO 3166-1 alpha-2, a legelterjedtebb, kétbetűs kódokat tartalmazza.',
        'bus': 'Vevő országkódja bármi lehet, szállító csak HU.',
      },
      {
        'panelId': 125,
        'eng': 'FromPartnerSortname',
        'hun': 'Szállító neve',
        'desc': 'A partner rövidített neve.',
        'bus': 'Erre lehet szűrni a cégnevet.',
      },
      {
        'panelId': 125,
        'eng': 'Sys_Country',
        'hun': 'Országkód',
        'desc': 'A partner országának kódja.',
        'bus':
            'Ez alapján döntjük el, hogy belföldi vagy külföldi (pl. CZ, DE).',
      },
    ];

    for (final f in fields) {
      final textToEmbed =
          'Mező: ${f['hun']} (${f['eng']})\nLeírás: ${f['desc']}\nÜgyvitel: ${f['bus']}';
      final embedding = await genAi.generateEmbedding(textToEmbed);

      // We assume simpler insert here for demo
      await ListPanelColumnDescription.db.insertRow(
          session,
          ListPanelColumnDescription(
            distributionId: f['panelId'] as int,
            fieldNameEng: f['eng'] as String,
            fieldNameHun: f['hun'] as String,
            descriptionHun: f['desc'] as String,
            businessDescriptionHun: f['bus'] as String,
            embedding: embedding,
          ));
      session.log('Imported Field: ${f['hun']}');
    }
  }
}
