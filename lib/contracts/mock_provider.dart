// Implementasi Mock Stream Provider Mandiri
// Digunakan untuk pengujian cepat, mode offline, dan pengembangan antarmuka paralel.

import 'api_contracts.dart';
import 'mock_data.dart';
import 'models.dart';

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
    return const ApiResponse.success(MockData.featuredList);
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getTrending({int page = 1}) async {
    await _simulateLatency();
    return ApiResponse.success(MockData.trendingList);
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getByCategory(String categoryId, {int page = 1}) async {
    await _simulateLatency();
    switch (categoryId) {
      case 'drakor':
        return const ApiResponse.success(MockData.drakorList);
      case 'anime':
        return const ApiResponse.success(MockData.animeList);
      case 'western_series':
        return const ApiResponse.success(MockData.westernSeriesList);
      case 'hollywood':
        return const ApiResponse.success(MockData.hollywoodList);
      case 'indonesian':
        return const ApiResponse.success(MockData.indonesianList);
      case 'tv_series':
        return ApiResponse.success([
          ...MockData.drakorList,
          ...MockData.westernSeriesList,
          ...MockData.indonesianList.where((m) => m.type == MediaType.series),
        ]);
      case 'popular_movies':
        return ApiResponse.success([
          ...MockData.hollywoodList,
          ...MockData.indonesianList.where((m) => m.type == MediaType.movie),
        ]);
      case 'top_rated':
        final sorted = List<MediaItem>.from(MockData.trendingList)
          ..sort((a, b) => b.rating.compareTo(a.rating));
        return ApiResponse.success(sorted);
      default:
        return ApiResponse.success(MockData.trendingList);
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
    final detail = MockData.mediaDetails[id];
    if (detail != null) {
      return ApiResponse.success(detail);
    }

    // Fallback: Jika ID belum memiliki detail khusus, bangun detail representatif dari MediaItem
    final allItems = <MediaItem>[
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
