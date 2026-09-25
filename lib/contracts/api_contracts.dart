// Kontrak Antarmuka Layanan Data (*API & Provider Contracts*)
// Menjamin pemisahan murni antara lapisan antarmuka dan penyedia data eksternal.

import 'models.dart';

/// Hasil pembungkus respons standar API dengan proteksi kegagalan
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  const ApiResponse.success(this.data)
      : isSuccess = true,
        errorMessage = null,
        statusCode = 200;

  const ApiResponse.failure(this.errorMessage, {this.statusCode})
      : isSuccess = false,
        data = null;
}

/// Antarmuka tunggal penyedia konten media (*Single Source of Truth Provider*)
/// Seluruh provider (Mock lokal maupun HTTP client pihak ketiga) wajib mengimplementasikan interface ini.
abstract class StreamProvider {
  /// Mengambil daftar media unggulan untuk banner carousel utama
  Future<ApiResponse<List<MediaItem>>> getFeaturedMedia();

  /// Mengambil daftar media yang sedang tren
  Future<ApiResponse<List<MediaItem>>> getTrending({int page = 1});

  /// Mengambil daftar media berdasarkan kategori tertentu
  Future<ApiResponse<List<MediaItem>>> getByCategory(String categoryId, {int page = 1});

  /// Melakukan pencarian media berdasarkan kata kunci dan tipe opsional
  Future<ApiResponse<List<MediaItem>>> searchMedia(String query, {MediaType? type});

  /// Mengambil informasi detail lengkap sebuah film atau serial
  Future<ApiResponse<MediaDetail>> getMediaDetail(String id);

  /// Mengambil tautan stream video yang dapat diputar
  Future<ApiResponse<List<StreamSource>>> getStreamSources({
    required String mediaId,
    String? episodeId,
  });

  /// Mengambil daftar subtitle multibahasa untuk media atau episode terkait
  Future<ApiResponse<List<SubtitleTrack>>> getSubtitles({
    required String mediaId,
    String? episodeId,
  });
}
