// Provider Streaming Realtime Berbasis LokLok API (*LokLok Stream Provider Adapter*)
// Mengadopsi arsitektur dari repositori fork-filmhot untuk mengambil katalog, detail, dan stream video langsung.

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'api_contracts.dart';
import 'mock_provider.dart';
import 'models.dart';

class LoklokStreamProvider implements StreamProvider {
  final String baseUrl;
  final StreamProvider fallbackProvider;
  final int timeoutSeconds;
  final String language;

  const LoklokStreamProvider({
    this.baseUrl = 'https://ga-mobile-api.loklok.tv/cms/app',
    this.fallbackProvider = const MockStreamProvider(),
    this.timeoutSeconds = 8,
    this.language = 'en',
  });

  /// Header wajib agar permintaan diizinkan oleh gateway LokLok
  Map<String, String> _buildHeaders() {
    final randomId = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(8, '0');
    return {
      'Content-Type': 'application/json',
      'lang': language,
      'versioncode': '11',
      'clienttype': 'ios_jike_default',
      'deviceid': 'cineflow_$randomId',
    };
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getFeaturedMedia() async {
    try {
      final uri = Uri.parse('$baseUrl/homePage/getHome?page=0');
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;
        final recommendItems = (data?['recommendItems'] as List<dynamic>?) ?? [];

        final List<MediaItem> items = [];
        for (final section in recommendItems) {
          final contentList = (section['recommendContentVOList'] as List<dynamic>?) ?? [];
          for (final item in contentList) {
            final id = item['id']?.toString() ?? '';
            final title = item['title']?.toString() ?? '';
            final img = item['imageUrl']?.toString() ?? '';
            if (id.isNotEmpty && title.isNotEmpty && img.isNotEmpty) {
              items.add(
                MediaItem(
                  id: id,
                  title: title,
                  posterUrl: img,
                  backdropUrl: img,
                  rating: 8.8,
                  releaseYear: DateTime.now().year,
                  type: item['contentType']?.toString().toLowerCase() == 'movie'
                      ? MediaType.movie
                      : MediaType.series,
                  genres: ['Populer', 'Trending'],
                ),
              );
            }
          }
        }

        if (items.isNotEmpty) {
          return ApiResponse.success(items.take(6).toList());
        }
      }
    } catch (_) {
      // Fallback transparan jika koneksi ke server LokLok mengalami timeout atau terblokir
    }

    return fallbackProvider.getFeaturedMedia();
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getTrending({int page = 1}) async {
    try {
      final uri = Uri.parse('$baseUrl/homePage/getHome?page=${page - 1}');
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;
        final recommendItems = (data?['recommendItems'] as List<dynamic>?) ?? [];

        final List<MediaItem> items = [];
        for (final section in recommendItems) {
          final contentList = (section['recommendContentVOList'] as List<dynamic>?) ?? [];
          for (final item in contentList) {
            final id = item['id']?.toString() ?? '';
            final title = item['title']?.toString() ?? '';
            final img = item['imageUrl']?.toString() ?? '';
            if (id.isNotEmpty && title.isNotEmpty && img.isNotEmpty) {
              items.add(
                MediaItem(
                  id: id,
                  title: title,
                  posterUrl: img,
                  backdropUrl: img,
                  rating: 8.5,
                  releaseYear: DateTime.now().year,
                  type: item['contentType']?.toString().toLowerCase() == 'movie'
                      ? MediaType.movie
                      : MediaType.series,
                  genres: ['Trending'],
                ),
              );
            }
          }
        }

        if (items.isNotEmpty) {
          return ApiResponse.success(items);
        }
      }
    } catch (_) {
      // Fallback otomatis
    }

    return fallbackProvider.getTrending(page: page);
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getByCategory(String categoryId, {int page = 1}) async {
    try {
      final trendingRes = await getTrending(page: page);
      if (trendingRes.isSuccess && trendingRes.data != null && trendingRes.data!.isNotEmpty) {
        if (categoryId == 'tv_series') {
          final filtered = trendingRes.data!.where((m) => m.type == MediaType.series).toList();
          if (filtered.isNotEmpty) return ApiResponse.success(filtered);
        } else if (categoryId == 'popular_movies') {
          final filtered = trendingRes.data!.where((m) => m.type == MediaType.movie).toList();
          if (filtered.isNotEmpty) return ApiResponse.success(filtered);
        }
      }
    } catch (_) {
      // Abaikan dan lanjut ke fallback
    }

    return fallbackProvider.getByCategory(categoryId, page: page);
  }

  @override
  Future<ApiResponse<List<MediaItem>>> searchMedia(String query, {MediaType? type}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const ApiResponse.success([]);

    try {
      final uri = Uri.parse('$baseUrl/search/v1/searchWithKeyWord');
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(),
            body: jsonEncode({
              'searchKeyWord': cleanQuery,
              'size': 30,
              'sort': '',
              'searchType': '',
            }),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;
        final searchResults = (data?['searchResults'] as List<dynamic>?) ?? [];

        final List<MediaItem> results = [];
        for (final item in searchResults) {
          final id = item['id']?.toString() ?? '';
          final title = item['name']?.toString() ?? '';
          final poster = item['coverVerticalUrl']?.toString() ?? '';
          final backdrop = item['coverHorizontalUrl']?.toString() ?? poster;
          final domainType = item['domainType'] as int? ?? 0;
          final score = (item['score'] as num?)?.toDouble() ?? 8.0;

          if (id.isNotEmpty && title.isNotEmpty) {
            results.add(
              MediaItem(
                id: id,
                title: title,
                posterUrl: poster,
                backdropUrl: backdrop,
                rating: score,
                releaseYear: item['year'] as int? ?? DateTime.now().year,
                type: domainType == 1 ? MediaType.series : MediaType.movie,
                genres: ['LokLok'],
              ),
            );
          }
        }

        if (results.isNotEmpty) {
          final filtered = type == null ? results : results.where((m) => m.type == type).toList();
          return ApiResponse.success(filtered);
        }
      }
    } catch (_) {
      // Fallback
    }

    return fallbackProvider.searchMedia(query, type: type);
  }

  @override
  Future<ApiResponse<MediaDetail>> getMediaDetail(String id) async {
    try {
      // Coba category 0 (film) terlebih dahulu
      for (final cat in [0, 1]) {
        final uri = Uri.parse('$baseUrl/movieDrama/get?id=$id&category=$cat');
        final response = await http
            .get(uri, headers: _buildHeaders())
            .timeout(Duration(seconds: timeoutSeconds));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final data = json['data'] as Map<String, dynamic>?;

          if (data != null && data['name'] != null) {
            final title = data['name'].toString();
            final overview = data['introduction']?.toString() ?? 'Sinopsis tidak tersedia.';
            final poster = data['coverVerticalUrl']?.toString() ?? '';
            final backdrop = data['coverHorizontalUrl']?.toString() ?? poster;
            final score = (data['score'] as num?)?.toDouble() ?? 8.0;
            final year = data['year'] as int? ?? DateTime.now().year;

            // Parsing tags / genres
            final tagList = (data['tagList'] as List<dynamic>?) ?? [];
            final genres = tagList.map((t) => t['name'].toString()).toList();

            // Parsing episodes jika serial
            final episodeVo = (data['episodeVo'] as List<dynamic>?) ?? [];
            final List<EpisodeItem> episodes = [];
            for (final ep in episodeVo) {
              episodes.add(
                EpisodeItem(
                  id: ep['id']?.toString() ?? '',
                  episodeNumber: ep['seriesNo'] as int? ?? 1,
                  title: ep['name']?.toString() ?? 'Episode ${ep['seriesNo']}',
                  durationMinutes: 45,
                  thumbnailUrl: backdrop,
                  overview: 'Episode ${ep['seriesNo']} dari $title.',
                ),
              );
            }

            final seasons = episodes.isNotEmpty
                ? [
                    SeasonItem(
                      seasonNumber: 1,
                      title: 'Musim 1',
                      episodes: episodes,
                    )
                  ]
                : <SeasonItem>[];

            return ApiResponse.success(
              MediaDetail(
                id: id,
                title: title,
                overview: overview,
                posterUrl: poster,
                backdropUrl: backdrop,
                rating: score,
                releaseYear: year,
                durationMinutes: cat == 0 ? 120 : 45,
                type: cat == 1 ? MediaType.series : MediaType.movie,
                genres: genres.isNotEmpty ? genres : ['Film'],
                casts: ['Pemeran Utama'],
                directors: ['Sutradara'],
                seasons: seasons,
              ),
            );
          }
        }
      }
    } catch (_) {
      // Fallback
    }

    return fallbackProvider.getMediaDetail(id);
  }

  @override
  Future<ApiResponse<List<StreamSource>>> getStreamSources({
    required String mediaId,
    String? episodeId,
  }) async {
    try {
      // Panggil media/previewInfo untuk mendapatkan tautan streaming langsung
      for (final cat in [0, 1]) {
        for (final def in ['GROOT_HD', 'GROOT_SD', 'GROOT_LD']) {
          final uri = Uri.parse(
            '$baseUrl/media/previewInfo?category=$cat&contentId=$mediaId&episodeId=${episodeId ?? ''}&definition=$def',
          );
          final response = await http
              .get(uri, headers: _buildHeaders())
              .timeout(Duration(seconds: timeoutSeconds));

          if (response.statusCode == 200) {
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            final mediaUrl = json['data']?['mediaUrl']?.toString();
            if (mediaUrl != null && mediaUrl.isNotEmpty) {
              return ApiResponse.success([
                StreamSource(
                  url: mediaUrl,
                  quality: def.contains('HD')
                      ? VideoQuality.q1080p
                      : def.contains('SD')
                          ? VideoQuality.q720p
                          : VideoQuality.q480p,
                  isHls: mediaUrl.contains('.m3u8'),
                ),
              ]);
            }
          }
        }
      }
    } catch (_) {
      // Fallback
    }

    return fallbackProvider.getStreamSources(mediaId: mediaId, episodeId: episodeId);
  }

  @override
  Future<ApiResponse<List<SubtitleTrack>>> getSubtitles({
    required String mediaId,
    String? episodeId,
  }) async {
    return fallbackProvider.getSubtitles(mediaId: mediaId, episodeId: episodeId);
  }
}
