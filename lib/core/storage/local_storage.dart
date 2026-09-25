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
}
