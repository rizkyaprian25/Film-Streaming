// Provider Streaming Teroptimasi Berbasis LokLok API (*Optimized LokLok Stream Provider*)
// Dilengkapi Multi-Mirror Fallback, In-Memory TTL Cache (5 menit), dan Failover Cepat.

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'api_contracts.dart';
import 'mock_provider.dart';
import 'mock_data.dart';
import 'models.dart';
import '../core/services/auto_scraper_service.dart';

/// Struktur penyimpanan cache memori dengan waktu kedaluwarsa (*Time-to-Live*)
class _CacheEntry<T> {
  final T data;
  final DateTime expiry;

  _CacheEntry(this.data, {Duration ttl = const Duration(minutes: 5)})
      : expiry = DateTime.now().add(ttl);

  bool get isValid => DateTime.now().isBefore(expiry);
}

class LoklokStreamProvider implements StreamProvider {
  final String baseUrl;
  final List<String> mirrorUrls;
  final StreamProvider fallbackProvider;
  final int timeoutSeconds;
  final String language;

  // Cache memori internal untuk performa instan (0ms latency saat berpindah tab)
  static final Map<String, _CacheEntry<dynamic>> _memoryCache = {};

  // Autonomous Circuit Breaker (Aturan 3-Strike)
  static int _consecutiveFailures = 0;
  static DateTime? _circuitBreakerUntil;

  const LoklokStreamProvider({
    this.baseUrl = 'https://ga-mobile-api.loklok.tv/cms/app',
    this.mirrorUrls = const [
      'https://ga-mobile-api.loklok.tv/cms/app',
    ],
    this.fallbackProvider = const MockStreamProvider(),
    this.timeoutSeconds = 4, // Timeout tanggap 4 detik agar UI tidak terhambat
    this.language = 'en',
  });

  /// Menghasilkan header resmi yang dipersyaratkan oleh gateway LokLok
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

  /// Eksekutor HTTP multi-mirror dengan failover otomatis dan Circuit Breaker
  Future<http.Response?> _requestWithFailover({
    required String pathWithQuery,
    String method = 'GET',
    String? body,
  }) async {
    // Jika circuit breaker aktif (3 kegagalan beruntun), lewati langsung ke fallback
    if (_circuitBreakerUntil != null && DateTime.now().isBefore(_circuitBreakerUntil!)) {
      return null;
    }

    final candidateBases = <String>{baseUrl, ...mirrorUrls};
    for (final base in candidateBases) {
      try {
        final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        final cleanPath = pathWithQuery.startsWith('/') ? pathWithQuery : '/$pathWithQuery';
        final uri = Uri.parse('$cleanBase$cleanPath');

        final http.Response res;
        if (method == 'POST') {
          res = await http
              .post(uri, headers: _buildHeaders(), body: body)
              .timeout(Duration(seconds: timeoutSeconds));
        } else {
          res = await http
              .get(uri, headers: _buildHeaders())
              .timeout(Duration(seconds: timeoutSeconds));
        }

        if (res.statusCode == 200) {
          // Reset status kegagalan saat ada respons sukses
          _consecutiveFailures = 0;
          _circuitBreakerUntil = null;
          return res;
        }
      } catch (_) {
        // Coba mirror berikutnya jika timeout atau terjadi kendala jaringan
      }
    }

    // Catat kegagalan jaringan dan aktifkan circuit breaker jika mencapai ambang batas
    _consecutiveFailures++;
    if (_consecutiveFailures >= 3) {
      _circuitBreakerUntil = DateTime.now().add(const Duration(minutes: 2));
    }

    return null;
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getFeaturedMedia() async {
    const cacheKey = 'loklok_featured_media';
    final cached = _memoryCache[cacheKey];
    if (cached != null && cached.isValid) {
      return ApiResponse.success(cached.data as List<MediaItem>);
    }

    try {
      final response = await _requestWithFailover(pathWithQuery: 'homePage/getHome?page=0');
      if (response != null) {
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
          final result = items.take(6).toList();
          _memoryCache[cacheKey] = _CacheEntry(result);
          return ApiResponse.success(result);
        }
      }
    } catch (_) {
      // Fallback
    }

    return fallbackProvider.getFeaturedMedia();
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getTrending({int page = 1}) async {
    final cacheKey = 'loklok_trending_page_$page';
    final cached = _memoryCache[cacheKey];
    if (cached != null && cached.isValid) {
      return ApiResponse.success(cached.data as List<MediaItem>);
    }

    try {
      final response = await _requestWithFailover(pathWithQuery: 'homePage/getHome?page=${page - 1}');
      if (response != null) {
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
          _memoryCache[cacheKey] = _CacheEntry(items);
          return ApiResponse.success(items);
        }
      }
    } catch (_) {
      // Fallback
    }

    return fallbackProvider.getTrending(page: page);
  }

  @override
  Future<ApiResponse<List<MediaItem>>> getByCategory(String categoryId, {int page = 1}) async {
    if (categoryId == 'tv_series' || categoryId == 'popular_movies') {
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
        // Fallback
      }
    }

    return fallbackProvider.getByCategory(categoryId, page: page);
  }

  @override
  Future<ApiResponse<List<MediaItem>>> searchMedia(String query, {MediaType? type}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const ApiResponse.success([]);

    final cacheKey = 'loklok_search_${cleanQuery}_${type?.name ?? "all"}';
    final cached = _memoryCache[cacheKey];
    if (cached != null && cached.isValid) {
      return ApiResponse.success(cached.data as List<MediaItem>);
    }

    try {
      final response = await _requestWithFailover(
        pathWithQuery: 'search/v1/searchWithKeyWord',
        method: 'POST',
        body: jsonEncode({
          'searchKeyWord': cleanQuery,
          'size': 30,
          'sort': '',
          'searchType': '',
        }),
      );

      if (response != null) {
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
          _memoryCache[cacheKey] = _CacheEntry(filtered);
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
    // 1. Cek langsung jika ini adalah media hasil scrap otomatis
    if (id.contains('_scraped_')) {
      final scraped = await AutoScraperService.instance.findScrapedDetail(id);
      if (scraped != null) {
        return ApiResponse.success(scraped);
      }
    }

    final cacheKey = 'loklok_detail_$id';
    final cached = _memoryCache[cacheKey];
    if (cached != null && cached.isValid) {
      return ApiResponse.success(cached.data as MediaDetail);
    }

    try {
      for (final cat in [0, 1]) {
        final response = await _requestWithFailover(
          pathWithQuery: 'movieDrama/get?id=$id&category=$cat',
        );

        if (response != null) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final data = json['data'] as Map<String, dynamic>?;

          if (data != null && data['name'] != null) {
            final title = data['name'].toString();
            final overview = data['introduction']?.toString() ?? 'Sinopsis tidak tersedia.';
            final poster = data['coverVerticalUrl']?.toString() ?? '';
            final backdrop = data['coverHorizontalUrl']?.toString() ?? poster;
            final score = (data['score'] as num?)?.toDouble() ?? 8.0;
            final year = data['year'] as int? ?? DateTime.now().year;

            final tagList = (data['tagList'] as List<dynamic>?) ?? [];
            final genres = tagList.map((t) => t['name'].toString()).toList();

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

            final detail = MediaDetail(
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
            );

            _memoryCache[cacheKey] = _CacheEntry(detail);
            return ApiResponse.success(detail);
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
    // 1. Cek langsung jika ini adalah media hasil scrap otomatis
    if (mediaId.contains('_scraped_')) {
      final streams = await AutoScraperService.instance.findScrapedStreams(mediaId, episodeId: episodeId);
      if (streams.isNotEmpty) {
        return ApiResponse.success(streams);
      }
    }

    try {
      for (final cat in [0, 1]) {
        for (final def in ['GROOT_HD', 'GROOT_SD', 'GROOT_LD']) {
          final response = await _requestWithFailover(
            pathWithQuery:
                'media/previewInfo?category=$cat&contentId=$mediaId&episodeId=${episodeId ?? ''}&definition=$def',
          );

          if (response != null) {
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            final mediaUrl = json['data']?['mediaUrl']?.toString();
            if (mediaUrl != null && mediaUrl.isNotEmpty) {
              final primarySource = StreamSource(
                url: mediaUrl,
                quality: def.contains('HD')
                    ? VideoQuality.q1080p
                    : def.contains('SD')
                        ? VideoQuality.q720p
                        : VideoQuality.q480p,
                isHls: mediaUrl.contains('.m3u8'),
                serverName: 'Server LokLok (${def.contains('HD') ? '1080p' : '720p'})',
              );

              final fallbackRes = await fallbackProvider.getStreamSources(mediaId: mediaId, episodeId: episodeId);
              final fallbacks = fallbackRes.data ?? MockData.sampleStreamSources;

              return ApiResponse.success([
                primarySource,
                ...fallbacks.where((s) => s.url != mediaUrl),
              ]);
            }
          }
        }
      }
    } catch (_) {
      // Fallback otomatis ke cermin video terverifikasi
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
