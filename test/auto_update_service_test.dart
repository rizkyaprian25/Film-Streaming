// Pengujian Unit untuk AutoUpdateService dan Fitur Jadwal Rilis Mingguan
// Memastikan jadwal rilis mingguan dan update otomatis berjalan sesuai kontrak.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cineflow/core/services/auto_update_service.dart';
import 'package:cineflow/core/storage/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutoUpdateService Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Memeriksa nama hari ini dan menghasilkan jadwal mingguan lengkap', () async {
      final service = AutoUpdateService.instance;
      final today = service.getTodayDayName();

      expect(['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'], contains(today));

      final updates = await service.checkUpdates(force: false);
      expect(updates.isNotEmpty, isTrue);

      // Pastikan ada serial dari berbagai hari rilis
      final jumatItems = updates.where((e) => e.releaseDay == 'Jumat').toList();
      final sabtuItems = updates.where((e) => e.releaseDay == 'Sabtu').toList();
      final mingguItems = updates.where((e) => e.releaseDay == 'Minggu').toList();

      expect(jumatItems.isNotEmpty, isTrue);
      expect(sabtuItems.isNotEmpty, isTrue);
      expect(mingguItems.isNotEmpty, isTrue);
    });

    test('Mengaktifkan dan menonaktifkan pengingat rilis serial (Reminder)', () async {
      final storage = LocalStorageService.instance;
      const mediaId = 'k1'; // Queen of Tears

      // Awalnya belum ada pengingat
      expect(await storage.hasReminder(mediaId), isFalse);

      // Aktifkan pengingat
      final added = await storage.toggleReminder(mediaId);
      expect(added, isTrue);
      expect(await storage.hasReminder(mediaId), isTrue);

      // Matikan pengingat
      final removed = await storage.toggleReminder(mediaId);
      expect(removed, isFalse);
      expect(await storage.hasReminder(mediaId), isFalse);
    });

    test('Membuat playable episode baru dari SeriesUpdateItem', () {
      final service = AutoUpdateService.instance;
      final schedule = service.updatesNotifier.value;
      if (schedule.isNotEmpty) {
        final item = schedule.first;
        final episode = service.createPlayableEpisode(item);

        expect(episode.episodeNumber, equals(item.latestEpisode));
        expect(episode.title, equals(item.latestEpisodeTitle));
      }
    });
  });
}
