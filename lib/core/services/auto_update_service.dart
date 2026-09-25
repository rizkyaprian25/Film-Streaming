// Layanan Pembaruan Otomatis Serial & Jadwal Rilis (*Auto-Update & Release Schedule Service*)
// Mengatur sinkronisasi otomatis episode serial baru, jadwal rilis mingguan (Senin-Minggu),
// dan notifikasi pembaruan in-app gaya LokLok 100%.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../contracts/models.dart';
import '../storage/local_storage.dart';

class AutoUpdateService {
  static AutoUpdateService? _instance;
  static AutoUpdateService get instance => _instance ??= AutoUpdateService._();

  AutoUpdateService._();

  Timer? _syncTimer;

  // Notifier untuk antarmuka yang reaktif secara real-time
  final ValueNotifier<List<SeriesUpdateItem>> updatesNotifier = ValueNotifier<List<SeriesUpdateItem>>([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isSyncingNotifier = ValueNotifier<bool>(false);

  // Controller aliran pesan banner update in-app
  final StreamController<String> _bannerMessageController = StreamController<String>.broadcast();
  Stream<String> get onNewUpdateBanner => _bannerMessageController.stream;

  /// Memulai sinkronisasi periodik otomatis di latar belakang
  void startPeriodicSync({Duration interval = const Duration(minutes: 10)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) {
      checkUpdates(isBackground: true);
    });
  }

  /// Menghentikan timer sinkronisasi
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Menentukan nama hari ini dalam Bahasa Indonesia
  String getTodayDayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
      default:
        return 'Minggu';
    }
  }

  /// Dataset Jadwal Rilis Mingguan Komprehensif (Senin - Minggu)
  List<SeriesUpdateItem> _generateWeeklySchedule() {
    final today = getTodayDayName();

    final allSchedule = [
      // === JUMAT (FOKUS RILIS HARI INI) ===
      SeriesUpdateItem(
        id: 'k1',
        title: 'Queen of Tears: Special Cut',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 16,
        totalEpisodes: 16,
        releaseDay: 'Jumat',
        releaseTime: '21:10 WIB',
        updateTag: today == 'Jumat' ? 'EPISODE FINAL' : 'TAMAT',
        type: MediaType.series,
        genres: ['Drakor', 'Romance', 'Drama'],
        rating: 9.5,
        latestEpisodeTitle: 'Episode 16: Takdir Cinta Abadi',
        isNewToday: today == 'Jumat',
      ),
      SeriesUpdateItem(
        id: 'a1',
        title: 'Solo Leveling Season 2: Arise',
        posterUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 13,
        totalEpisodes: 13,
        releaseDay: 'Jumat',
        releaseTime: '23:30 WIB',
        updateTag: today == 'Jumat' ? 'BARU TAYANG' : 'UPDATE',
        type: MediaType.anime,
        genres: ['Anime', 'Aksi', 'Dungeon', 'Fantasi'],
        rating: 9.7,
        latestEpisodeTitle: 'Episode 13: Kebangkitan Raja Bayangan',
        isNewToday: today == 'Jumat',
      ),
      SeriesUpdateItem(
        id: 'w1',
        title: 'Stranger Things Season 5: Finale',
        posterUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 8,
        totalEpisodes: 8,
        releaseDay: 'Jumat',
        releaseTime: '20:00 WIB',
        updateTag: today == 'Jumat' ? 'BARU TAYANG' : 'LENGKAP',
        type: MediaType.series,
        genres: ['Series Barat', 'Sci-Fi', 'Horor'],
        rating: 9.7,
        latestEpisodeTitle: 'Episode 8: Akhir Dunia Terbalik',
        isNewToday: today == 'Jumat',
      ),
      SeriesUpdateItem(
        id: 'a10',
        title: 'Frieren: Beyond Journey Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 12,
        totalEpisodes: 24,
        releaseDay: 'Jumat',
        releaseTime: '22:00 WIB',
        updateTag: today == 'Jumat' ? 'BARU RILIS' : 'ON GOING',
        type: MediaType.anime,
        genres: ['Anime', 'Fantasi', 'Petualangan'],
        rating: 9.8,
        latestEpisodeTitle: 'Episode 12: Menuju Dataran Tinggi Ende',
        isNewToday: today == 'Jumat',
      ),
      SeriesUpdateItem(
        id: 'id17',
        title: 'Gadis Kretek Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 6,
        totalEpisodes: 6,
        releaseDay: 'Jumat',
        releaseTime: '19:30 WIB',
        updateTag: today == 'Jumat' ? 'EPISODE SPESIAL' : 'LENGKAP',
        type: MediaType.series,
        genres: ['Indonesia', 'Drama', 'Romance'],
        rating: 9.5,
        latestEpisodeTitle: 'Episode 6: Warisan Abadi Sang Peracik',
        isNewToday: today == 'Jumat',
      ),
      SeriesUpdateItem(
        id: 'k8',
        title: 'Taxi Driver Season 3',
        posterUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 8,
        totalEpisodes: 16,
        releaseDay: 'Jumat',
        releaseTime: '21:00 WIB',
        updateTag: today == 'Jumat' ? 'BARU TAYANG' : 'ON GOING',
        type: MediaType.series,
        genres: ['Drakor', 'Aksi', 'Balas Dendam'],
        rating: 9.4,
        latestEpisodeTitle: 'Episode 8: Panggilan Darurat Terakhir',
        isNewToday: today == 'Jumat',
      ),

      // === SABTU ===
      SeriesUpdateItem(
        id: 'a7',
        title: 'Jujutsu Kaisen Season 3: Culling Game',
        posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 12,
        totalEpisodes: 24,
        releaseDay: 'Sabtu',
        releaseTime: '23:00 WIB',
        updateTag: today == 'Sabtu' ? 'BARU TAYANG' : 'HARI SABTU',
        type: MediaType.anime,
        genres: ['Anime', 'Supranatural', 'Aksi'],
        rating: 9.7,
        latestEpisodeTitle: 'Episode 12: Koloni Tokyo No. 1 Memanas',
        isNewToday: today == 'Sabtu',
      ),
      SeriesUpdateItem(
        id: 'a3',
        title: 'Demon Slayer: Infinity Castle Movie',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 1,
        totalEpisodes: 1,
        releaseDay: 'Sabtu',
        releaseTime: '22:15 WIB',
        updateTag: today == 'Sabtu' ? 'PREMIERE' : 'MOVIE SPESIAL',
        type: MediaType.anime,
        genres: ['Anime', 'Aksi', 'Iblis'],
        rating: 9.8,
        latestEpisodeTitle: 'Full Movie: Penyerbuan Kastil Tanpa Batas',
        isNewToday: today == 'Sabtu',
      ),
      SeriesUpdateItem(
        id: 'k4',
        title: 'All of Us Are Dead Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 10,
        totalEpisodes: 10,
        releaseDay: 'Sabtu',
        releaseTime: '21:30 WIB',
        updateTag: today == 'Sabtu' ? 'BARU TAYANG' : 'HARI SABTU',
        type: MediaType.series,
        genres: ['Drakor', 'Zombie', 'Horor'],
        rating: 9.3,
        latestEpisodeTitle: 'Episode 10: Kebangkitan Mutan Seoul',
        isNewToday: today == 'Sabtu',
      ),
      SeriesUpdateItem(
        id: 'w2',
        title: 'The Last of Us Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 7,
        totalEpisodes: 7,
        releaseDay: 'Sabtu',
        releaseTime: '18:00 WIB',
        updateTag: today == 'Sabtu' ? 'EPISODE FINAL' : 'TAMAT',
        type: MediaType.series,
        genres: ['Series Barat', 'Aksi', 'Horor'],
        rating: 9.6,
        latestEpisodeTitle: 'Episode 7: Lingkaran Dendam Tak Berujung',
        isNewToday: today == 'Sabtu',
      ),

      // === MINGGU ===
      SeriesUpdateItem(
        id: 'a8',
        title: 'One Piece: Egghead Island Climax',
        posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 1120,
        totalEpisodes: 1200,
        releaseDay: 'Minggu',
        releaseTime: '09:30 WIB',
        updateTag: today == 'Minggu' ? 'BARU TAYANG' : 'MINGGUAN',
        type: MediaType.anime,
        genres: ['Anime', 'Bajak Laut', 'Petualangan'],
        rating: 9.6,
        latestEpisodeTitle: 'Episode 1120: Siaran Abad Kekosongan Mengguncang Dunia',
        isNewToday: today == 'Minggu',
      ),
      SeriesUpdateItem(
        id: 'w3',
        title: 'House of the Dragon Season 3',
        posterUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 4,
        totalEpisodes: 8,
        releaseDay: 'Minggu',
        releaseTime: '20:00 WIB',
        updateTag: today == 'Minggu' ? 'BARU TAYANG' : 'HARI MINGGU',
        type: MediaType.series,
        genres: ['Series Barat', 'Epik', 'Naga'],
        rating: 9.5,
        latestEpisodeTitle: 'Episode 4: Api dan Darah di Gullet',
        isNewToday: today == 'Minggu',
      ),
      SeriesUpdateItem(
        id: 'k7',
        title: 'Vincenzo 2: Cassano Returns',
        posterUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 10,
        totalEpisodes: 16,
        releaseDay: 'Minggu',
        releaseTime: '21:10 WIB',
        updateTag: today == 'Minggu' ? 'BARU TAYANG' : 'HARI MINGGU',
        type: MediaType.series,
        genres: ['Drakor', 'Aksi', 'Mafia'],
        rating: 9.3,
        latestEpisodeTitle: 'Episode 10: Strategi Burung Merpati Roma',
        isNewToday: today == 'Minggu',
      ),

      // === SENIN ===
      SeriesUpdateItem(
        id: 'k14',
        title: 'Marry My Husband',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 16,
        totalEpisodes: 16,
        releaseDay: 'Senin',
        releaseTime: '20:50 WIB',
        updateTag: today == 'Senin' ? 'BARU TAYANG' : 'HARI SENIN',
        type: MediaType.series,
        genres: ['Drakor', 'Balas Dendam', 'Romance'],
        rating: 9.3,
        latestEpisodeTitle: 'Episode 16: Takdir Bahagia yang Diraih',
        isNewToday: today == 'Senin',
      ),
      SeriesUpdateItem(
        id: 'k5',
        title: 'Moving Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 6,
        totalEpisodes: 12,
        releaseDay: 'Senin',
        releaseTime: '14:00 WIB',
        updateTag: today == 'Senin' ? 'BARU TAYANG' : 'HARI SENIN',
        type: MediaType.series,
        genres: ['Drakor', 'Superhero', 'Sci-Fi'],
        rating: 9.5,
        latestEpisodeTitle: 'Episode 6: Generasi Baru Pembela Keadilan',
        isNewToday: today == 'Senin',
      ),
      SeriesUpdateItem(
        id: 'a16',
        title: 'Bleach: Thousand-Year Blood War Pt 4',
        posterUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 13,
        totalEpisodes: 13,
        releaseDay: 'Senin',
        releaseTime: '23:00 WIB',
        updateTag: today == 'Senin' ? 'EPISODE FINAL' : 'TAMAT',
        type: MediaType.anime,
        genres: ['Anime', 'Shinigami', 'Aksi'],
        rating: 9.7,
        latestEpisodeTitle: 'Episode 13: Pelepasan Kekuatan Pamungkas Ichigo',
        isNewToday: today == 'Senin',
      ),

      // === SELASA ===
      SeriesUpdateItem(
        id: 'k6',
        title: 'Lovely Runner: Special Story',
        posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 16,
        totalEpisodes: 16,
        releaseDay: 'Selasa',
        releaseTime: '20:50 WIB',
        updateTag: today == 'Selasa' ? 'BARU TAYANG' : 'HARI SELASA',
        type: MediaType.series,
        genres: ['Drakor', 'Romance', 'Time Travel'],
        rating: 9.4,
        latestEpisodeTitle: 'Episode 16: Melompat Menuju Masa Depan Abadi',
        isNewToday: today == 'Selasa',
      ),
      SeriesUpdateItem(
        id: 'a5',
        title: 'Chainsaw Man: Reze Arc Movie',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 1,
        totalEpisodes: 1,
        releaseDay: 'Selasa',
        releaseTime: '22:30 WIB',
        updateTag: today == 'Selasa' ? 'PREMIERE' : 'MOVIE',
        type: MediaType.anime,
        genres: ['Anime', 'Iblis', 'Aksi'],
        rating: 9.6,
        latestEpisodeTitle: 'Full Movie: Dentuman Cinta Bom Reze',
        isNewToday: today == 'Selasa',
      ),
      SeriesUpdateItem(
        id: 'w5',
        title: 'Wednesday Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 8,
        totalEpisodes: 8,
        releaseDay: 'Selasa',
        releaseTime: '17:00 WIB',
        updateTag: today == 'Selasa' ? 'BARU TAYANG' : 'HARI SELASA',
        type: MediaType.series,
        genres: ['Series Barat', 'Misteri', 'Gotik'],
        rating: 9.4,
        latestEpisodeTitle: 'Episode 8: Rahasia Kuburan Nevermore',
        isNewToday: today == 'Selasa',
      ),

      // === RABU ===
      SeriesUpdateItem(
        id: 'k2',
        title: 'Squid Game Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 7,
        totalEpisodes: 7,
        releaseDay: 'Rabu',
        releaseTime: '22:00 WIB',
        updateTag: today == 'Rabu' ? 'BARU TAYANG' : 'HARI RABU',
        type: MediaType.series,
        genres: ['Drakor', 'Survival', 'Aksi'],
        rating: 9.4,
        latestEpisodeTitle: 'Episode 7: Pembalasan Gi-hun Dimulai',
        isNewToday: today == 'Rabu',
      ),
      SeriesUpdateItem(
        id: 'a22',
        title: 'Oshi no Ko Season 3',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 6,
        totalEpisodes: 12,
        releaseDay: 'Rabu',
        releaseTime: '21:30 WIB',
        updateTag: today == 'Rabu' ? 'BARU TAYANG' : 'HARI RABU',
        type: MediaType.anime,
        genres: ['Anime', 'Drama', 'Showbiz'],
        rating: 9.4,
        latestEpisodeTitle: 'Episode 6: Kamera Pengungkap Kebenaran',
        isNewToday: today == 'Rabu',
      ),
      SeriesUpdateItem(
        id: 'w4',
        title: 'The Boys Season 5: Final Season',
        posterUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 4,
        totalEpisodes: 8,
        releaseDay: 'Rabu',
        releaseTime: '18:00 WIB',
        updateTag: today == 'Rabu' ? 'BARU TAYANG' : 'HARI RABU',
        type: MediaType.series,
        genres: ['Series Barat', 'Aksi', 'Satir'],
        rating: 9.6,
        latestEpisodeTitle: 'Episode 4: Perang Terbuka Butcher vs Homelander',
        isNewToday: today == 'Rabu',
      ),

      // === KAMIS ===
      SeriesUpdateItem(
        id: 'k40',
        title: 'Hospital Playlist 3',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 8,
        totalEpisodes: 12,
        releaseDay: 'Kamis',
        releaseTime: '21:00 WIB',
        updateTag: today == 'Kamis' ? 'BARU TAYANG' : 'HARI KAMIS',
        type: MediaType.series,
        genres: ['Drakor', 'Medis', 'Persahabatan'],
        rating: 9.5,
        latestEpisodeTitle: 'Episode 8: Irama Baru di Ruang Operasi Yulje',
        isNewToday: today == 'Kamis',
      ),
      SeriesUpdateItem(
        id: 'a11',
        title: 'Kaiju No. 8 Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 6,
        totalEpisodes: 12,
        releaseDay: 'Kamis',
        releaseTime: '20:30 WIB',
        updateTag: today == 'Kamis' ? 'BARU TAYANG' : 'HARI KAMIS',
        type: MediaType.anime,
        genres: ['Anime', 'Monster', 'Aksi'],
        rating: 9.4,
        latestEpisodeTitle: 'Episode 6: Senjata Terhebat Divisi Tiga',
        isNewToday: today == 'Kamis',
      ),
      SeriesUpdateItem(
        id: 'w8',
        title: 'Fallout Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 4,
        totalEpisodes: 8,
        releaseDay: 'Kamis',
        releaseTime: '19:00 WIB',
        updateTag: today == 'Kamis' ? 'BARU TAYANG' : 'HARI KAMIS',
        type: MediaType.series,
        genres: ['Series Barat', 'Sci-Fi', 'Post-Apocalyptic'],
        rating: 9.5,
        latestEpisodeTitle: 'Episode 4: Cahaya Neon Gurun New Vegas',
        isNewToday: today == 'Kamis',
      ),
    ];

    return allSchedule;
  }

  /// Memeriksa pembaruan serial dan episode secara real-time
  Future<List<SeriesUpdateItem>> checkUpdates({
    bool force = false,
    bool isBackground = false,
  }) async {
    isSyncingNotifier.value = true;

    try {
      // Simulasikan jeda sinkronisasi jaringan hanya saat dipicu manual demi feedback visual
      if (force) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final schedule = _generateWeeklySchedule();
      final today = getTodayDayName();

      // Hitung episode yang dirilis hari ini
      final todayItems = schedule.where((item) => item.releaseDay == today || item.isNewToday).toList();
      unreadCountNotifier.value = todayItems.length;

      // Perbarui notifikasi lokal
      updatesNotifier.value = schedule;

      // Perbarui cap waktu di penyimpanan lokal
      await LocalStorageService.instance.setLastUpdateCheck(DateTime.now());

      // Jika ada episode baru hari ini, pancarkan banner notifikasi in-app
      if (todayItems.isNotEmpty && !isBackground) {
        final titles = todayItems.take(2).map((e) => e.title).join(', ');
        _bannerMessageController.add(
          '🔔 Update Otomatis: ${todayItems.length} episode baru rilis hari ini ($titles)!',
        );
      }

      return schedule;
    } finally {
      isSyncingNotifier.value = false;
    }
  }

  /// Mengambil daftar episode yang baru rilis hari ini
  List<SeriesUpdateItem> getTodayReleases() {
    final today = getTodayDayName();
    return updatesNotifier.value.where((item) => item.releaseDay == today || item.isNewToday).toList();
  }

  /// Menghubungkan episode baru ke pemutar video secara langsung
  EpisodeItem createPlayableEpisode(SeriesUpdateItem updateItem) {
    return EpisodeItem(
      id: '${updateItem.id}_latest',
      episodeNumber: updateItem.latestEpisode,
      title: updateItem.latestEpisodeTitle,
      durationMinutes: 45,
      thumbnailUrl: updateItem.posterUrl,
      overview: 'Episode terbaru tayang resmi ${updateItem.releaseDay} ${updateItem.releaseTime}. Nikmati kualitas HD dengan subtitle Bahasa Indonesia.',
    );
  }

  void dispose() {
    _syncTimer?.cancel();
    _bannerMessageController.close();
  }
}
