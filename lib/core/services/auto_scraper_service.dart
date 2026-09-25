// Layanan Orkestrasi Pengikis Otomatis In-App Bergaya Tachiyomi/Aniyomi (*Auto-Scraper Engine Service*)
// Mengatur pengikisan katalog rilis 2026 secara otomatis di latar belakang saat aplikasi dibuka,
// saat pull-to-refresh, atau secara periodik tanpa memerlukan proses scrap manual dari luar.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../contracts/models.dart';
import '../../contracts/mock_data.dart';
import '../storage/local_storage.dart';
import '../scraper/scraper_source.dart';
import '../scraper/sources/seasonal_anime_scraper.dart';
import '../scraper/sources/drakor_scraper.dart';
import '../scraper/sources/western_series_scraper.dart';
import '../scraper/sources/loklok_catalog_scraper.dart';
import 'auto_update_service.dart';

class AutoScraperService {
  static AutoScraperService? _instance;
  static AutoScraperService get instance => _instance ??= AutoScraperService._();

  AutoScraperService._() {
    _registerDefaultSources();
  }

  // Daftar sumber pengikis yang terdaftar secara modular
  final List<ScraperSource> _registeredSources = [];
  List<ScraperSource> get sources => List.unmodifiable(_registeredSources);

  // State reaktif untuk antarmuka pengguna Apple HIG
  final ValueNotifier<bool> isScrapingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<List<MediaItem>> scrapedMediaNotifier = ValueNotifier<List<MediaItem>>([]);
  final ValueNotifier<List<SeriesUpdateItem>> scrapedUpdatesNotifier = ValueNotifier<List<SeriesUpdateItem>>([]);
  final ValueNotifier<int> totalScrapedCountNotifier = ValueNotifier<int>(0);

  // Aliran pesan pemberitahuan banner in-app
  final StreamController<String> _bannerController = StreamController<String>.broadcast();
  Stream<String> get onScrapeNotification => _bannerController.stream;

  Timer? _periodicTimer;

  void _registerDefaultSources() {
    _registeredSources.addAll([
      SeasonalAnimeScraperSource(),
      DrakorScraperSource(),
      WesternSeriesScraperSource(),
      LoklokCatalogScraperSource(),
    ]);
  }

  /// Inisialisasi awal saat aplikasi dijalankan (Auto-Scraping saat App Launch)
  Future<void> initAutoScrape() async {
    // 1. Muat data terkikis yang telah tersimpan di penyimpanan lokal
    final savedMedia = await LocalStorageService.instance.getScrapedMedia();
    final savedUpdates = await LocalStorageService.instance.getScrapedUpdates();

    if (savedMedia.isNotEmpty) {
      scrapedMediaNotifier.value = savedMedia;
      totalScrapedCountNotifier.value = savedMedia.length;
    }
    if (savedUpdates.isNotEmpty) {
      scrapedUpdatesNotifier.value = savedUpdates;
    }

    // 2. Periksa waktu scrap terakhir, jika belum pernah atau sudah lewat dari 15 menit, lakukan sinkronisasi otomatis
    final lastTime = await LocalStorageService.instance.getLastScrapeTime();
    final shouldScrape = lastTime == null || DateTime.now().difference(lastTime).inMinutes >= 15;

    if (shouldScrape || savedMedia.isEmpty) {
      // Jalankan di latar belakang secara asinkron tanpa memperlambat pembukaan layar beranda
      unawaited(refreshAllSources(silent: true));
    }

    // 3. Mulai sinkronisasi latar belakang periodik setiap 15 menit
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      refreshAllSources(silent: true);
    });
  }

  /// Mengeksekusi pengikisan dari seluruh sumber aktif (dipicu oleh Pull-to-Refresh atau tombol Sinkronisasi)
  Future<ScrapeResult> refreshAllSources({
    bool force = false,
    bool silent = false,
  }) async {
    if (isScrapingNotifier.value) {
      return ScrapeResult(
        totalScraped: scrapedMediaNotifier.value.length,
        newItemsCount: 0,
        sourceName: 'Semua Sumber',
        timestamp: DateTime.now(),
        message: 'Pengikisan otomatis sedang berjalan...',
      );
    }

    isScrapingNotifier.value = true;

    try {
      final allNewMedia = <MediaItem>[];
      final allNewUpdates = <SeriesUpdateItem>[];

      // Jalankan pengikisan seluruh sumber secara paralel untuk efisiensi waktu
      final futures = _registeredSources.map((src) async {
        try {
          final mediaList = await src.scrapeLatestMedia();
          final updatesList = await src.scrapeLatestUpdates();
          return (media: mediaList, updates: updatesList);
        } catch (_) {
          return (media: <MediaItem>[], updates: <SeriesUpdateItem>[]);
        }
      });

      final results = await Future.wait(futures);

      for (final res in results) {
        allNewMedia.addAll(res.media);
        allNewUpdates.addAll(res.updates);
      }

      // Gabungkan dengan data tersimpan sebelumnya dan hindari duplikasi berdasarkan ID
      final existingMedia = await LocalStorageService.instance.getScrapedMedia();
      final mediaMap = <String, MediaItem>{};
      for (final m in existingMedia) {
        mediaMap[m.id] = m;
      }
      int newMediaCount = 0;
      for (final m in allNewMedia) {
        if (!mediaMap.containsKey(m.id)) {
          newMediaCount++;
        }
        mediaMap[m.id] = m;
      }

      final mergedMedia = mediaMap.values.toList();
      await LocalStorageService.instance.saveScrapedMedia(mergedMedia);
      scrapedMediaNotifier.value = mergedMedia;
      totalScrapedCountNotifier.value = mergedMedia.length;

      // Gabungkan jadwal update episode
      final existingUpdates = await LocalStorageService.instance.getScrapedUpdates();
      final updatesMap = <String, SeriesUpdateItem>{};
      for (final u in existingUpdates) {
        updatesMap[u.id] = u;
      }
      for (final u in allNewUpdates) {
        updatesMap[u.id] = u;
      }
      final mergedUpdates = updatesMap.values.toList();
      await LocalStorageService.instance.saveScrapedUpdates(mergedUpdates);
      scrapedUpdatesNotifier.value = mergedUpdates;

      // Perbarui waktu scrap
      await LocalStorageService.instance.setLastScrapeTime(DateTime.now());

      // Sinkronkan juga ke AutoUpdateService agar tab Jadwal & Rilis Baru terupdate
      AutoUpdateService.instance.updatesNotifier.value = [
        ...mergedUpdates,
        ...AutoUpdateService.instance.updatesNotifier.value.where((old) => !updatesMap.containsKey(old.id)),
      ];

      final successMsg =
          '⚡ Scrap Otomatis Selesai: Berhasil menyinkronkan ${mergedMedia.length} judul 2026 ($newMediaCount baru)!';

      if (!silent) {
        _bannerController.add(successMsg);
      }

      return ScrapeResult(
        totalScraped: mergedMedia.length,
        newItemsCount: newMediaCount,
        sourceName: 'Seluruh Sumber Real-Time',
        timestamp: DateTime.now(),
        message: successMsg,
      );
    } finally {
      isScrapingNotifier.value = false;
    }
  }

  /// Mengambil daftar media terkikis berdasarkan tipe atau kategori
  List<MediaItem> getScrapedMediaByCategory(String categoryId) {
    final all = scrapedMediaNotifier.value;
    switch (categoryId.toLowerCase()) {
      case 'anime':
        return all.where((e) => e.type == MediaType.anime).toList();
      case 'drakor':
        return all.where((e) => e.genres.any((g) => g.toLowerCase().contains('drakor'))).toList();
      case 'western_series':
        return all
            .where((e) => e.genres.any((g) => g.toLowerCase().contains('series barat') || g.toLowerCase().contains('drama')))
            .toList();
      case 'hollywood':
        return all.where((e) => e.genres.any((g) => g.toLowerCase().contains('film barat'))).toList();
      case 'scraped_2026':
      case 'trending':
        return all;
      default:
        return all;
    }
  }

  /// Mencari detail media hasil scrap
  Future<MediaDetail?> findScrapedDetail(String id) async {
    for (final source in _registeredSources) {
      try {
        final detail = await source.scrapeMediaDetail(id);
        if (detail != null) return detail;
      } catch (_) {}
    }
    return null;
  }

  /// Mengambil tautan pemutar video untuk media hasil scrap
  Future<List<StreamSource>> findScrapedStreams(String id, {String? episodeId}) async {
    for (final source in _registeredSources) {
      try {
        final streams = await source.scrapeStreamSources(id, episodeId: episodeId);
        if (streams.isNotEmpty) return streams;
      } catch (_) {}
    }
    return MockData.sampleStreamSources;
  }

  void dispose() {
    _periodicTimer?.cancel();
    _bannerController.close();
  }
}
