// Pengujian Kualitas Layanan Penyimpanan Lokal (*Local Storage Quality Gate*)
// Menguji persistensi riwayat tontonan, watchlist, dan kemampuan self-healing data korup.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cineflow/contracts/models.dart';
import 'package:cineflow/core/storage/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService Unit Tests', () {
    test('Simpan dan baca riwayat tontonan (Continue Watching)', () async {
      final storage = LocalStorageService.instance;

      final item1 = WatchHistoryItem(
        mediaId: 'film_1',
        title: 'Film Satu',
        posterUrl: 'https://example.com/poster1.jpg',
        positionSeconds: 120,
        durationSeconds: 3600,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final item2 = WatchHistoryItem(
        mediaId: 'film_2',
        title: 'Film Dua',
        posterUrl: 'https://example.com/poster2.jpg',
        positionSeconds: 300,
        durationSeconds: 7200,
        updatedAt: DateTime.now(),
      );

      await storage.saveWatchProgress(item1);
      await storage.saveWatchProgress(item2);

      final history = await storage.getWatchHistory();

      expect(history.length, equals(2));
      // Pastikan item yang lebih baru ditonton (item2) berada di posisi pertama
      expect(history.first.mediaId, equals('film_2'));
      expect(history.first.progressRatio, closeTo(300 / 7200, 0.001));

      // Hapus item
      await storage.removeWatchHistory('film_1');
      final updatedHistory = await storage.getWatchHistory();
      expect(updatedHistory.length, equals(1));
      expect(updatedHistory.first.mediaId, equals('film_2'));
    });

    test('Toggle dan cek status Watchlist', () async {
      final storage = LocalStorageService.instance;

      final watchItem = WatchlistItem(
        mediaId: 'film_anime_1',
        title: 'Anime Populer',
        posterUrl: 'https://example.com/anime.jpg',
        type: MediaType.anime,
        rating: 9.0,
        releaseYear: 2024,
        addedAt: DateTime.now(),
      );

      // Tambah ke watchlist
      final added = await storage.toggleWatchlist(watchItem);
      expect(added, isTrue);

      final isInList = await storage.isInWatchlist('film_anime_1');
      expect(isInList, isTrue);

      final list = await storage.getWatchlist();
      expect(list.length, equals(1));
      expect(list.first.title, equals('Anime Populer'));

      // Toggle kembali untuk menghapus dari watchlist
      final removed = await storage.toggleWatchlist(watchItem);
      expect(removed, isFalse);

      final isInListAfter = await storage.isInWatchlist('film_anime_1');
      expect(isInListAfter, isFalse);
    });

    test('Self-healing: Kebal terhadap data korup di local storage', () async {
      // Simulasikan data korup dalam SharedPreferences
      SharedPreferences.setMockInitialValues({
        'cineflow_watch_history_v1': ['{invalid json string}'],
        'cineflow_watchlist_v1': ['{corrupt: true'],
      });

      final storage = LocalStorageService.instance;

      // Memastikan getWatchHistory dan getWatchlist tidak crash dan mengembalikan list kosong
      final history = await storage.getWatchHistory();
      expect(history, isEmpty);

      final watchlist = await storage.getWatchlist();
      expect(watchlist, isEmpty);
    });
  });
}
