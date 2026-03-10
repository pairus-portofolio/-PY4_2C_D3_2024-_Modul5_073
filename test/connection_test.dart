import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_073/helper/log_helper.dart';
import 'package:logbook_app_073/services/mongo_service.dart';

void main() {
  const String sourceFile = "connection_test.dart";

  setUpAll(() async {
    // Load ENV sekali sebelum semua test
    await dotenv.load(fileName: ".env");
  });

  test(
    'Memastikan koneksi ke MongoDB Atlas berhasil via MongoService',
    () async {
      final mongoService = MongoService();

      await LogHelper.writeLog(
        "--- START CONNECTION TEST ---",
        source: sourceFile,
      );

      try {
        // Test koneksi
        await mongoService.connect();

        // Pastikan URI ada
        expect(dotenv.env['MONGODB_URI'], isNotNull);

        await LogHelper.writeLog(
          "SUCCESS: Koneksi Atlas Terverifikasi",
          source: sourceFile,
          level: 2, // INFO
        );
      } catch (e) {
        await LogHelper.writeLog(
          "ERROR: Kegagalan koneksi - $e",
          source: sourceFile,
          level: 1, // ERROR
        );

        fail("Koneksi gagal: $e");
      } finally {
        // Tutup koneksi supaya tidak menggantung
        await mongoService.close();

        await LogHelper.writeLog("--- END TEST ---", source: sourceFile);
      }
    },
  );
}
