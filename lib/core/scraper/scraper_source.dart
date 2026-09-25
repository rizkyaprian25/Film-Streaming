// Kontrak Antarmuka Sumber Pengikis Otomatis (*Auto-Scraper Source Contract*)
// Mengadopsi arsitektur modular sumber Tachiyomi/Aniyomi/Mihon untuk CineFlow.
// Memungkinkan aplikasi mengikis dan memperbarui katalog film/serial 2026 secara otomatis tanpa intervensi manual.

import '../../contracts/models.dart';

/// Hasil ringkasan dari operasi pengikisan data otomatis
class ScrapeResult {
  final int totalScraped;
  final int newItemsCount;
  final String sourceName;
  final DateTime timestamp;
  final String message;

  const ScrapeResult({
    required this.totalScraped,
    required this.newItemsCount,
    required this.sourceName,
    required this.timestamp,
    required this.message,
  });
}

/// Kontrak dasar setiap sumber pengikis data (*Scraper Source*)
abstract class ScraperSource {
  /// Pengenal unik sumber (misal: 'anime_seasonal_2026', 'drakor_live_2026')
  String get id;

  /// Nama tampilan sumber yang ramah pengguna
  String get name;

  /// Deskripsi singkat tentang sumber
  String get description;

  /// Kategori media utama yang didukung sumber ini
  MediaType get supportedType;

  /// Mengikis rilis terbaru atau sedang tayang dari internet secara otomatis
  Future<List<MediaItem>> scrapeLatestMedia({int page = 1});

  /// Mengikis rilis episode mingguan terbaru untuk kalender update
  Future<List<SeriesUpdateItem>> scrapeLatestUpdates();

  /// Mengambil detail lengkap media berdasarkan ID yang dikikis
  Future<MediaDetail?> scrapeMediaDetail(String id);

  /// Mengambil tautan pemutar video multi-mirror untuk media/episode
  Future<List<StreamSource>> scrapeStreamSources(String id, {String? episodeId});
}
