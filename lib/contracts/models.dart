// Model Kontrak Data Tunggal (Single Source of Truth - SSOT)
// Digunakan di seluruh lapisan aplikasi CineFlow (UI, State, Repository, & Adapter).

/// Tipe media yang didukung dalam aplikasi
enum MediaType {
  movie,
  series,
  anime,
}

/// Kategori katalog konten
class MediaCategory {
  final String id;
  final String title;

  const MediaCategory({
    required this.id,
    required this.title,
  });

  static const MediaCategory trending = MediaCategory(id: 'trending', title: 'Sedang Tren');
  static const MediaCategory drakor = MediaCategory(id: 'drakor', title: 'Drama Korea (Drakor)');
  static const MediaCategory anime = MediaCategory(id: 'anime', title: 'Anime Pilihan');
  static const MediaCategory westernSeries = MediaCategory(id: 'western_series', title: 'Series Barat');
  static const MediaCategory hollywood = MediaCategory(id: 'hollywood', title: 'Film Barat & Box Office');
  static const MediaCategory indonesian = MediaCategory(id: 'indonesian', title: 'Film Indonesia');
  static const MediaCategory popularMovies = MediaCategory(id: 'popular_movies', title: 'Film Populer');
  static const MediaCategory tvSeries = MediaCategory(id: 'tv_series', title: 'Serial TV');
  static const MediaCategory topRated = MediaCategory(id: 'top_rated', title: 'Rating Tertinggi');
}

/// Representasi ringkas media untuk tampilan grid dan carousel
class MediaItem {
  final String id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final double rating;
  final int releaseYear;
  final MediaType type;
  final List<String> genres;

  const MediaItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.releaseYear,
    required this.type,
    required this.genres,
  });

  /// Factory untuk deserialisasi JSON aman dengan proteksi null-safety
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Tanpa Judul',
      posterUrl: json['poster_url'] as String? ?? '',
      backdropUrl: json['backdrop_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      releaseYear: json['release_year'] as int? ?? DateTime.now().year,
      type: _parseMediaType(json['type'] as String?),
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  /// Serialisasi ke Map untuk persistensi lokal
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'rating': rating,
      'release_year': releaseYear,
      'type': type.name,
      'genres': genres,
    };
  }

  static MediaType _parseMediaType(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'series':
      case 'tv':
        return MediaType.series;
      case 'anime':
        return MediaType.anime;
      default:
        return MediaType.movie;
    }
  }
}

/// Representasi detail lengkap sebuah film atau serial
class MediaDetail {
  final String id;
  final String title;
  final String overview;
  final String posterUrl;
  final String backdropUrl;
  final double rating;
  final int releaseYear;
  final int durationMinutes;
  final MediaType type;
  final List<String> genres;
  final List<String> casts;
  final List<String> directors;
  final List<SeasonItem> seasons;
  final String? trailerUrl;

  const MediaDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.releaseYear,
    required this.durationMinutes,
    required this.type,
    required this.genres,
    required this.casts,
    required this.directors,
    this.seasons = const [],
    this.trailerUrl,
  });

  bool get isSeries => type == MediaType.series || type == MediaType.anime;
}

/// Representasi data musim (*season*) pada serial
class SeasonItem {
  final int seasonNumber;
  final String title;
  final List<EpisodeItem> episodes;

  const SeasonItem({
    required this.seasonNumber,
    required this.title,
    required this.episodes,
  });
}

/// Representasi episode tunggal serial
class EpisodeItem {
  final String id;
  final int episodeNumber;
  final String title;
  final int durationMinutes;
  final String thumbnailUrl;
  final String overview;

  const EpisodeItem({
    required this.id,
    required this.episodeNumber,
    required this.title,
    required this.durationMinutes,
    required this.thumbnailUrl,
    required this.overview,
  });
}

/// Format stream video yang tersedia
enum VideoQuality {
  q360p('360p'),
  q480p('480p'),
  q720p('720p HD'),
  q1080p('1080p FHD'),
  auto('Auto');

  final String label;
  const VideoQuality(this.label);
}

/// Sumber stream video yang siap diputar oleh pemutar media
class StreamSource {
  final String url;
  final VideoQuality quality;
  final bool isHls;
  final Map<String, String>? httpHeaders;

  const StreamSource({
    required this.url,
    required this.quality,
    this.isHls = false,
    this.httpHeaders,
  });
}

/// Format trek subtitle eksternal
class SubtitleTrack {
  final String id;
  final String language;
  final String label;
  final String url;

  const SubtitleTrack({
    required this.id,
    required this.language,
    required this.label,
    required this.url,
  });
}

/// Model riwayat tontonan untuk fitur "Lanjutkan Menonton" (*Continue Watching*)
class WatchHistoryItem {
  final String mediaId;
  final String title;
  final String posterUrl;
  final String? episodeId;
  final String? episodeTitle;
  final int positionSeconds;
  final int durationSeconds;
  final DateTime updatedAt;

  const WatchHistoryItem({
    required this.mediaId,
    required this.title,
    required this.posterUrl,
    this.episodeId,
    this.episodeTitle,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.updatedAt,
  });

  /// Rasio progres menonton (0.0 sampai 1.0)
  double get progressRatio => durationSeconds > 0
      ? (positionSeconds / durationSeconds).clamp(0.0, 1.0)
      : 0.0;

  Map<String, dynamic> toJson() => {
        'media_id': mediaId,
        'title': title,
        'poster_url': posterUrl,
        'episode_id': episodeId,
        'episode_title': episodeTitle,
        'position_seconds': positionSeconds,
        'duration_seconds': durationSeconds,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) => WatchHistoryItem(
        mediaId: json['media_id'] as String,
        title: json['title'] as String,
        posterUrl: json['poster_url'] as String,
        episodeId: json['episode_id'] as String?,
        episodeTitle: json['episode_title'] as String?,
        positionSeconds: json['position_seconds'] as int? ?? 0,
        durationSeconds: json['duration_seconds'] as int? ?? 0,
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Model koleksi daftar tontonan tersimpan (*Watchlist*)
class WatchlistItem {
  final String mediaId;
  final String title;
  final String posterUrl;
  final double rating;
  final int releaseYear;
  final MediaType type;
  final DateTime addedAt;

  const WatchlistItem({
    required this.mediaId,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.releaseYear,
    required this.type,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'media_id': mediaId,
        'title': title,
        'poster_url': posterUrl,
        'rating': rating,
        'release_year': releaseYear,
        'type': type.name,
        'added_at': addedAt.toIso8601String(),
      };

  factory WatchlistItem.fromJson(Map<String, dynamic> json) => WatchlistItem(
        mediaId: json['media_id'] as String,
        title: json['title'] as String,
        posterUrl: json['poster_url'] as String,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        releaseYear: json['release_year'] as int? ?? DateTime.now().year,
        type: MediaType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MediaType.movie,
        ),
        addedAt: DateTime.tryParse(json['added_at'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Model jadwal rilis mingguan dan update episode otomatis gaya LokLok
class SeriesUpdateItem {
  final String id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final int latestEpisode;
  final int totalEpisodes;
  final String releaseDay; // 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  final String releaseTime; // '21:00 WIB'
  final String updateTag; // 'EPISODE BARU', 'HARI INI', 'BESOK', 'ONGOING'
  final MediaType type;
  final List<String> genres;
  final double rating;
  final String latestEpisodeTitle;
  final bool isNewToday;

  const SeriesUpdateItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.latestEpisode,
    required this.totalEpisodes,
    required this.releaseDay,
    required this.releaseTime,
    required this.updateTag,
    required this.type,
    required this.genres,
    required this.rating,
    required this.latestEpisodeTitle,
    this.isNewToday = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_url': posterUrl,
        'backdrop_url': backdropUrl,
        'latest_episode': latestEpisode,
        'total_episodes': totalEpisodes,
        'release_day': releaseDay,
        'release_time': releaseTime,
        'update_tag': updateTag,
        'type': type.name,
        'genres': genres,
        'rating': rating,
        'latest_episode_title': latestEpisodeTitle,
        'is_new_today': isNewToday,
      };

  factory SeriesUpdateItem.fromJson(Map<String, dynamic> json) => SeriesUpdateItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Tanpa Judul',
        posterUrl: json['poster_url'] as String? ?? '',
        backdropUrl: json['backdrop_url'] as String? ?? '',
        latestEpisode: json['latest_episode'] as int? ?? 1,
        totalEpisodes: json['total_episodes'] as int? ?? 16,
        releaseDay: json['release_day'] as String? ?? 'Senin',
        releaseTime: json['release_time'] as String? ?? '21:00 WIB',
        updateTag: json['update_tag'] as String? ?? 'ONGOING',
        type: MediaType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MediaType.series,
        ),
        genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        rating: (json['rating'] as num?)?.toDouble() ?? 8.5,
        latestEpisodeTitle: json['latest_episode_title'] as String? ?? 'Episode Terbaru',
        isNewToday: json['is_new_today'] as bool? ?? false,
      );

  /// Konversi ke MediaItem standar agar kompatibel dengan MediaCard dan katalog utama
  MediaItem toMediaItem() => MediaItem(
        id: id,
        title: title,
        posterUrl: posterUrl,
        backdropUrl: backdropUrl,
        rating: rating,
        releaseYear: DateTime.now().year,
        type: type,
        genres: genres,
      );
}
