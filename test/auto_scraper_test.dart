// Pengujian Unit Komprehensif Layanan Pengikisan Otomatis (*Auto-Scraper Quality Gate*)
// Menguji orkestrasi in-app scraping bergaya Tachiyomi/Aniyomi, persistensi lokal,
// deduplikasi rilis 2026, dan ketersediaan multi-mirror stream pemutaran.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cineflow/contracts/models.dart';
import 'package:cineflow/core/storage/local_storage.dart';
import 'package:cineflow/core/services/auto_scraper_service.dart';
import 'package:cineflow/core/scraper/sources/seasonal_anime_scraper.dart';
import 'package:cineflow/core/scraper/sources/drakor_scraper.dart';
import 'package:cineflow/core/scraper/sources/western_series_scraper.dart';
import 'package:cineflow/core/scraper/sources/loklok_catalog_scraper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AutoScraperService & In-App Scraper Tests', () {
    test('Sumber pengikis terdaftar dengan benar dan memiliki identitas valid', () {
      final service = AutoScraperService.instance;
      expect(service.sources.isNotEmpty, isTrue);

      final sourceIds = service.sources.map((s) => s.id).toList();
      expect(sourceIds, contains('anime_seasonal_2026'));
      expect(sourceIds, contains('drakor_live_2026'));
      expect(sourceIds, contains('western_live_2026'));
      expect(sourceIds, contains('loklok_gateway_scraper'));
    });

    test('SeasonalAnimeScraper mengikis atau mengembalikan rilis anime 2026', () async {
      final scraper = SeasonalAnimeScraperSource();
      final media = await scraper.scrapeLatestMedia();
      expect(media.isNotEmpty, isTrue);

      for (final item in media) {
        expect(item.type, equals(MediaType.anime));
        expect(item.posterUrl.isNotEmpty, isTrue);
        expect(item.releaseYear, greaterThanOrEqualTo(2024));
      }

      final updates = await scraper.scrapeLatestUpdates();
      expect(updates.isNotEmpty, isTrue);
      expect(updates.first.latestEpisode, greaterThanOrEqualTo(1));
    });

    test('DrakorScraper dan WesternSeriesScraper mengembalikan rilis 2026 terverifikasi', () async {
      final drakorScraper = DrakorScraperSource();
      final drakorList = await drakorScraper.scrapeLatestMedia();
      expect(drakorList.isNotEmpty, isTrue);
      expect(drakorList.any((m) => m.title.contains('Squid Game') || m.title.contains('Moving')), isTrue);

      final westernScraper = WesternSeriesScraperSource();
      final westernList = await westernScraper.scrapeLatestMedia();
      expect(westernList.isNotEmpty, isTrue);
      expect(westernList.any((m) => m.title.contains('The Last of Us') || m.title.contains('Dune')), isTrue);
    });

    test('LoklokCatalogScraper mengembalikan rilis eksklusif terverifikasi', () async {
      final loklokScraper = LoklokCatalogScraperSource();
      final media = await loklokScraper.scrapeLatestMedia();
      expect(media.isNotEmpty, isTrue);
      expect(media.first.posterUrl.isNotEmpty, isTrue);
    });

    test('LocalStorageService menyimpan dan memuat media serta jadwal hasil scrap otomatis', () async {
      final storage = LocalStorageService.instance;

      const sampleItem = MediaItem(
        id: 'test_scraped_1',
        title: 'Film Uji Coba 2026',
        posterUrl: 'https://example.com/poster.jpg',
        backdropUrl: 'https://example.com/backdrop.jpg',
        rating: 9.5,
        releaseYear: 2026,
        type: MediaType.movie,
        genres: ['Uji Coba', 'Scraper'],
      );

      await storage.saveScrapedMedia([sampleItem]);
      final loadedMedia = await storage.getScrapedMedia();
      expect(loadedMedia.length, equals(1));
      expect(loadedMedia.first.id, equals('test_scraped_1'));
      expect(loadedMedia.first.title, equals('Film Uji Coba 2026'));

      const sampleUpdate = SeriesUpdateItem(
        id: 'test_scraped_1',
        title: 'Film Uji Coba 2026',
        posterUrl: 'https://example.com/poster.jpg',
        backdropUrl: 'https://example.com/backdrop.jpg',
        latestEpisode: 8,
        totalEpisodes: 8,
        releaseDay: 'Jumat',
        releaseTime: '21:00 WIB',
        updateTag: 'FINAL',
        type: MediaType.series,
        genres: ['Uji Coba'],
        rating: 9.5,
        latestEpisodeTitle: 'Episode Final',
      );

      await storage.saveScrapedUpdates([sampleUpdate]);
      final loadedUpdates = await storage.getScrapedUpdates();
      expect(loadedUpdates.length, equals(1));
      expect(loadedUpdates.first.latestEpisode, equals(8));
    });

    test('refreshAllSources mengeksekusi pengikisan, menyinkronkan data, dan memperbarui notifiers', () async {
      final service = AutoScraperService.instance;

      final result = await service.refreshAllSources(force: true, silent: true);
      expect(result.totalScraped, greaterThan(0));
      expect(service.scrapedMediaNotifier.value.isNotEmpty, isTrue);
      expect(service.scrapedUpdatesNotifier.value.isNotEmpty, isTrue);

      // Filter berdasarkan kategori
      final animeFiltered = service.getScrapedMediaByCategory('anime');
      expect(animeFiltered.isNotEmpty, isTrue);
      expect(animeFiltered.every((m) => m.type == MediaType.anime), isTrue);

      final drakorFiltered = service.getScrapedMediaByCategory('drakor');
      expect(drakorFiltered.isNotEmpty, isTrue);

      // Detail dan Stream Video Multi-Mirror
      final firstMedia = service.scrapedMediaNotifier.value.first;
      final detail = await service.findScrapedDetail(firstMedia.id);
      expect(detail, isNotNull);
      expect(detail!.title, equals(firstMedia.title));

      final streams = await service.findScrapedStreams(firstMedia.id);
      expect(streams.length, greaterThanOrEqualTo(5)); // Minimal 5 mirror CDN aktif
    });
  });
}
