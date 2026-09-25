// Implementasi Mock Stream Provider Mandiri
// Digunakan untuk pengujian cepat, mode offline, dan pengembangan antarmuka paralel.

import 'api_contracts.dart';
import 'mock_data.dart';
import 'models.dart';
import '../core/services/auto_scraper_service.dart';

class MockStreamProvider implements StreamProvider {
  final int simulatedDelayMs;

  const MockStreamProvider({this.simulatedDelayMs = 250});

  Future<void> _simulateLatency() async {
    if (simulatedDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: simulatedDelayMs));
    }
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getFeaturedMedia() async {
    await _simulateLatency();
    final scraped = AutoScraperService.instance.scrapedMediaNotifier.value;
    if (scraped.isNotEmpty) {
      final combined = <MediaItem>[
        ...scraped.take(3),
        ...MockData.featuredList,
      ];
      return ApiResponse.success(combined);
    }
    return const ApiResponse.success(MockData.featuredList);
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getTrending({int page = 1}) async {
    await _simulateLatency();
    final scraped = AutoScraperService.instance.scrapedMediaNotifier.value;
    if (scraped.isNotEmpty) {
      final combined = <MediaItem>[
        ...scraped,
        ...MockData.trendingList,
      ];
      return ApiResponse.success(combined);
    }
    return ApiResponse.success(MockData.trendingList);
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getByCategory(String categoryId, {int page = 1}) async {
    await _simulateLatency();
    final scraped = AutoScraperService.instance.getScrapedMediaByCategory(categoryId);
    switch (categoryId) {
      case 'scraped_2026':
        return ApiResponse.success(AutoScraperService.instance.scrapedMediaNotifier.value);
      case 'drakor':
        return ApiResponse.success([...scraped, ...MockData.drakorList]);
      case 'anime':
        return ApiResponse.success([...scraped, ...MockData.animeList]);
      case 'western_series':
        return ApiResponse.success([...scraped, ...MockData.westernSeriesList]);
      case 'hollywood':
        return ApiResponse.success([...scraped, ...MockData.hollywoodList]);
      case 'indonesian':
        return const ApiResponse.success(MockData.indonesianList);
      case 'tv_series':
        return ApiResponse.success([
          ...scraped.where((m) => m.type == MediaType.series),
          ...MockData.drakorList,
          ...MockData.westernSeriesList,
          ...MockData.indonesianList.where((m) => m.type == MediaType.series),
        ]);
      case 'popular_movies':
        return ApiResponse.success([
          ...scraped.where((m) => m.type == MediaType.movie),
          ...MockData.hollywoodList,
          ...MockData.indonesianList.where((m) => m.type == MediaType.movie),
        ]);
      case 'top_rated':
        final sorted = List<MediaItem>.from([...scraped, ...MockData.trendingList])
          ..sort((a, b) => b.rating.compareTo(a.rating));
        return ApiResponse.success(sorted);
      default:
        return ApiResponse.success([...scraped, ...MockData.trendingList]);
    }
  }

  @override
  Future<ApiResponse<List<MediaItem>>> searchMedia(String query, {MediaType? type}) async {
    await _simulateLatency();
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) {
      return const ApiResponse.success([]);
    }

    final allItems = <MediaItem>{
      ...AutoScraperService.instance.scrapedMediaNotifier.value,
      ...MockData.featuredList,
      ...MockData.drakorList,
      ...MockData.animeList,
      ...MockData.westernSeriesList,
      ...MockData.hollywoodList,
      ...MockData.indonesianList,
    }.toList();

    final matches = allItems.where((item) {
      final matchesQuery = item.title.toLowerCase().contains(lowerQuery) ||
          item.genres.any((g) => g.toLowerCase().contains(lowerQuery));
      final matchesType = type == null || item.type == type;
      return matchesQuery && matchesType;
    }).toList();

    return ApiResponse.success(matches);
  }

  @override
  Future<ApiResponse<MediaDetail>> getMediaDetail(String id) async {
    await _simulateLatency();

    // 1. Cek detail dari MockData resmi
    final detail = MockData.mediaDetails[id];
    if (detail != null) {
      return ApiResponse.success(detail);
    }

    // 2. Cek detail dari sumber pengikis otomatis
    final scrapedDetail = await AutoScraperService.instance.findScrapedDetail(id);
    if (scrapedDetail != null) {
      return ApiResponse.success(scrapedDetail);
    }

    // 3. Fallback: Bangun detail representatif dari MediaItem
    final allItems = <MediaItem>[
      ...AutoScraperService.instance.scrapedMediaNotifier.value,
      ...MockData.featuredList,
      ...MockData.drakorList,
      ...MockData.animeList,
      ...MockData.westernSeriesList,
      ...MockData.hollywoodList,
      ...MockData.indonesianList,
    ];
    final match = allItems.firstWhere(
      (m) => m.id == id,
      orElse: () => MockData.drakorList.first,
    );

    final isSeries = match.type == MediaType.series || match.type == MediaType.anime;
    final generatedDetail = MediaDetail(
      id: match.id,
      title: match.title,
      overview: 'Sinopsis film ${match.title}. Nikmati petualangan sinematik berkualitas tinggi dengan efek visual memukau dan alur cerita yang mendebarkan.',
      posterUrl: match.posterUrl,
      backdropUrl: match.backdropUrl,
      rating: match.rating,
      releaseYear: match.releaseYear,
      durationMinutes: isSeries ? 45 : 120,
      type: match.type,
      genres: match.genres,
      casts: const ['Aktor Utama', 'Aktris Pendukung'],
      directors: const ['Sutradara Handal'],
      seasons: isSeries
          ? [
              SeasonItem(
                seasonNumber: 1,
                title: 'Musim 1',
                episodes: [
                  EpisodeItem(
                    id: '${match.id}_e1',
                    episodeNumber: 1,
                    title: 'Episode 1',
                    durationMinutes: 45,
                    thumbnailUrl: match.backdropUrl,
                    overview: 'Episode pertama dari ${match.title}.',
                  ),
                  EpisodeItem(
                    id: '${match.id}_e2',
                    episodeNumber: 2,
                    title: 'Episode 2',
                    durationMinutes: 48,
                    thumbnailUrl: match.backdropUrl,
                    overview: 'Episode kedua dari ${match.title}.',
                  ),
                ],
              )
            ]
          : const [],
      trailerUrl: MockData.sampleStreamSources.first.url,
    );

    return ApiResponse.success(generatedDetail);
  }

  @override
  Future<ApiResponse<List<StreamSource>>> getStreamSources({
    required String mediaId,
    String? episodeId,
  }) async {
    await _simulateLatency();
    return const ApiResponse.success(MockData.sampleStreamSources);
  }

  @override
  Future<ApiResponse<List<SubtitleTrack>>> getSubtitles({
    required String mediaId,
    String? episodeId,
  }) async {
    await _simulateLatency();
    return const ApiResponse.success(MockData.sampleSubtitles);
  }
}
