// Layanan Penyimpanan Lokal SSOT Tanpa Login (*Local-First Storage*)
// Menyimpan riwayat tontonan (Continue Watching) dan Watchlist secara persisten di perangkat.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../contracts/models.dart';

class LocalStorageService {
  static const String _keyWatchHistory = 'cineflow_watch_history_v1';
  static const String _keyWatchlist = 'cineflow_watchlist_v1';

  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageService._();
  LocalStorageService._();

  /// Mengambil seluruh riwayat tontonan yang diurutkan dari yang paling baru ditonton
  Future<List<WatchHistoryItem>> getWatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_keyWatchHistory) ?? [];
      final items = rawList.map((str) {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return WatchHistoryItem.fromJson(map);
      }).toList();

      items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return items;
    } catch (_) {
      // Self-healing: jika data lokal korup, kembalikan daftar kosong secara aman
      return [];
    }
  }

  /// Menyimpan atau memperbarui progres tontonan film/episode
  Future<void> saveWatchProgress(WatchHistoryItem newItem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getWatchHistory();

      // Hapus entri lama dengan mediaId yang sama
      currentList.removeWhere((item) => item.mediaId == newItem.mediaId);
      currentList.insert(0, newItem);

      // Batasi riwayat maksimal 50 item agar tidak membebani memori
      final trimmed = currentList.take(50).toList();
      final stringList = trimmed.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_keyWatchHistory, stringList);
    } catch (_) {
      // Abaikan kegagalan non-kritis demi kelancaran pemutaran
    }
  }

  /// Menghapus item tertentu dari riwayat tontonan
  Future<void> removeWatchHistory(String mediaId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getWatchHistory();
    currentList.removeWhere((item) => item.mediaId == mediaId);
    final stringList = currentList.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_keyWatchHistory, stringList);
  }

  /// Mengambil seluruh daftar tontonan tersimpan (*Watchlist*)
  Future<List<WatchlistItem>> getWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_keyWatchlist) ?? [];
      final items = rawList.map((str) {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return WatchlistItem.fromJson(map);
      }).toList();

      items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return items;
    } catch (_) {
      return [];
    }
  }

  /// Memeriksa apakah media tertentu sudah ada di Watchlist
  Future<bool> isInWatchlist(String mediaId) async {
    final list = await getWatchlist();
    return list.any((item) => item.mediaId == mediaId);
  }

  /// Menambah atau menghapus media dari Watchlist (*Toggle*)
  Future<bool> toggleWatchlist(WatchlistItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getWatchlist();
    final exists = currentList.any((e) => e.mediaId == item.mediaId);

    if (exists) {
      currentList.removeWhere((e) => e.mediaId == item.mediaId);
    } else {
      currentList.insert(0, item);
    }

    final stringList = currentList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyWatchlist, stringList);
    return !exists; // Mengembalikan true jika ditambahkan, false jika dihapus
  }

  static const String _keySeriesReminders = 'cineflow_series_reminders_v1';
  static const String _keyLastUpdateCheck = 'cineflow_last_update_check_v1';

  /// Mengambil daftar mediaId yang dipasangi pengingat rilis episode
  Future<List<String>> getReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keySeriesReminders) ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Memeriksa apakah suatu series dipasangi pengingat
  Future<bool> hasReminder(String mediaId) async {
    final list = await getReminders();
    return list.contains(mediaId);
  }

  /// Mengaktifkan atau menonaktifkan pengingat rilis episode (*Toggle Reminder*)
  Future<bool> toggleReminder(String mediaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = await getReminders();
      final exists = list.contains(mediaId);

      if (exists) {
        list.remove(mediaId);
      } else {
        list.add(mediaId);
      }

      await prefs.setStringList(_keySeriesReminders, list);
      return !exists; // true jika diaktifkan, false jika dimatikan
    } catch (_) {
      return false;
    }
  }

  /// Mengambil waktu pemeriksaan pembaruan otomatis terakhir
  Future<DateTime?> getLastUpdateCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyLastUpdateCheck);
      return str != null ? DateTime.tryParse(str) : null;
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan waktu pemeriksaan pembaruan otomatis terakhir
  Future<void> setLastUpdateCheck(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastUpdateCheck, time.toIso8601String());
    } catch (_) {
      // Abaikan error non-kritis
    }
  }

  static const String _keyScrapedMedia = 'cineflow_scraped_media_v1';
  static const String _keyScrapedUpdates = 'cineflow_scraped_updates_v1';
  static const String _keyLastScrapeTime = 'cineflow_last_scrape_time_v1';

  /// Mengambil daftar media hasil scrap otomatis yang tersimpan di perangkat
  Future<List<MediaItem>> getScrapedMedia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_keyScrapedMedia) ?? [];
      return rawList.map((str) {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return MediaItem.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan dan menggabungkan daftar media hasil scrap otomatis secara persisten
  Future<void> saveScrapedMedia(List<MediaItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getScrapedMedia();
      final existingMap = {for (final e in existing) e.id: e};
      for (final item in items) {
        existingMap[item.id] = item;
      }
      final merged = existingMap.values.toList();
      final stringList = merged.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_keyScrapedMedia, stringList);
    } catch (_) {
      // Abaikan kegagalan non-kritis
    }
  }

  /// Mengambil daftar jadwal update hasil scrap otomatis
  Future<List<SeriesUpdateItem>> getScrapedUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_keyScrapedUpdates) ?? [];
      return rawList.map((str) {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return SeriesUpdateItem.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan dan menggabungkan daftar jadwal update hasil scrap otomatis
  Future<void> saveScrapedUpdates(List<SeriesUpdateItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getScrapedUpdates();
      final existingMap = {for (final e in existing) e.id: e};
      for (final item in items) {
        existingMap[item.id] = item;
      }
      final merged = existingMap.values.toList();
      final stringList = merged.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_keyScrapedUpdates, stringList);
    } catch (_) {
      // Abaikan kegagalan non-kritis
    }
  }

  /// Mengambil waktu scrap otomatis terakhir
  Future<DateTime?> getLastScrapeTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyLastScrapeTime);
      return str != null ? DateTime.tryParse(str) : null;
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan waktu scrap otomatis terakhir
  Future<void> setLastScrapeTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastScrapeTime, time.toIso8601String());
    } catch (_) {
      // Abaikan error non-kritis
    }
  }
}
