// lib/src/endpoints/user_endpoint.dart
import 'package:serverpod/serverpod.dart';
// Importáljuk a generált modellt
import '../generated/protocol.dart';

class UserEndpoint extends Endpoint {
  // Teszteli a Supabase adatbázis kapcsolatot egy egyszerű lekérdezéssel
  Future<int> countTestRows(Session session) async {
    try {
      // 1. Megpróbálunk lekérdezni 1 sort a "test_model" táblából.
      // Ezzel teszteljük, hogy a Supabase kapcsolat működik, és a tábla létezik.
      final result = await session.db.find<TestModel>(
        // A 'where' feltétel nem kötelező, de kell a tábla reprezentáció.
        // A Serverpod generálja a TestModel.t objektumot, ami reprezentálja a táblát.
        // Csak a limit paramétert adjuk át a visszakapott List<T> kód használatával:
        limit: 1,
      );

      session.log(
          'Adatbázis teszt sikeres. Sorok száma a teszt táblában: ${result.length}',
          level: LogLevel.info);
      return result.length;
    } catch (e) {
      // Ha hiba van a Supabase csatlakozással, itt fog elkapódni.
      session.log('Supabase adatbázis hiba: $e', level: LogLevel.error);
      return -1; // Hiba esetén -1-et adunk vissza
    }
  }
}
