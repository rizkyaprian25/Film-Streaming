// Dataset Mock SSOT Mandiri untuk Validasi dan Pengujian Offline
// Menyediakan konten visual berkualitas tinggi dan tautan stream video publik yang valid.

import 'models.dart';

class MockData {
  /// Daftar media unggulan untuk Carousel Hero di Beranda
  static const List<MediaItem> featuredList = [
    MediaItem(
      id: 'm1',
      title: 'Cosmic Horizons: The Void Beyond',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2024,
      type: MediaType.movie,
      genres: ['Sci-Fi', 'Petualangan', 'Misteri'],
    ),
    MediaItem(
      id: 's1',
      title: 'Cyberpunk Chronicles: Neo Jakarta',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.2,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Aksi', 'Cyberpunk', 'Thriller'],
    ),
    MediaItem(
      id: 'm2',
      title: 'Echoes of the Forgotten Realm',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.6,
      releaseYear: 2023,
      type: MediaType.movie,
      genres: ['Fantasi', 'Drama', 'Epik'],
    ),
  ];

  /// Daftar media sedang tren
  static const List<MediaItem> trendingList = [
    MediaItem(
      id: 'm1',
      title: 'Cosmic Horizons: The Void Beyond',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2024,
      type: MediaType.movie,
      genres: ['Sci-Fi', 'Petualangan'],
    ),
    MediaItem(
      id: 's1',
      title: 'Cyberpunk Chronicles: Neo Jakarta',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.2,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Aksi', 'Thriller'],
    ),
    MediaItem(
      id: 'a1',
      title: 'Shadow Blade: Spirit Blossom',
      posterUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1600&auto=format&fit=crop&q=80',
      rating: 9.5,
      releaseYear: 2024,
      type: MediaType.anime,
      genres: ['Anime', 'Supranatural', 'Aksi'],
    ),
    MediaItem(
      id: 'm3',
      title: 'Deep Abyss: Silent Waters',
      posterUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=1600&auto=format&fit=crop&q=80',
      rating: 8.1,
      releaseYear: 2023,
      type: MediaType.movie,
      genres: ['Thriller', 'Misteri'],
    ),
    MediaItem(
      id: 'm4',
      title: 'Velocity: Midnight Drift',
      posterUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=1600&auto=format&fit=crop&q=80',
      rating: 8.4,
      releaseYear: 2024,
      type: MediaType.movie,
      genres: ['Aksi', 'Balap'],
    ),
  ];

  /// Daftar Serial TV
  static const List<MediaItem> tvSeriesList = [
    MediaItem(
      id: 's1',
      title: 'Cyberpunk Chronicles: Neo Jakarta',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.2,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Cyberpunk', 'Aksi'],
    ),
    MediaItem(
      id: 's2',
      title: 'The Silicon Syndicate',
      posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=1600&auto=format&fit=crop&q=80',
      rating: 8.7,
      releaseYear: 2023,
      type: MediaType.series,
      genres: ['Drama', 'Kriminal'],
    ),
    MediaItem(
      id: 's3',
      title: 'Quantum Paradox',
      posterUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1600&auto=format&fit=crop&q=80',
      rating: 8.8,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Sci-Fi', 'Misteri'],
    ),
  ];

  /// Daftar Anime Pilihan
  static const List<MediaItem> animeList = [
    MediaItem(
      id: 'a1',
      title: 'Shadow Blade: Spirit Blossom',
      posterUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1600&auto=format&fit=crop&q=80',
      rating: 9.5,
      releaseYear: 2024,
      type: MediaType.anime,
      genres: ['Anime', 'Aksi', 'Supranatural'],
    ),
    MediaItem(
      id: 'a2',
      title: 'Aura of the Ronin',
      posterUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=1600&auto=format&fit=crop&q=80',
      rating: 9.1,
      releaseYear: 2023,
      type: MediaType.anime,
      genres: ['Anime', 'Petualangan'],
    ),
  ];

  /// Peta data detail media komprehensif
  static final Map<String, MediaDetail> mediaDetails = {
    'm1': const MediaDetail(
      id: 'm1',
      title: 'Cosmic Horizons: The Void Beyond',
      overview:
          'Ketika sebuah sinyal misterius dari batas tata surya tertangkap oleh stasiun observasi antariksa, tim astronot elit diberangkatkan dalam misi berbahaya untuk menyingkap rahasia peradaban kuno yang mengancam eksistensi manusia di bumi.',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2024,
      durationMinutes: 142,
      type: MediaType.movie,
      genres: ['Sci-Fi', 'Petualangan', 'Misteri', 'Drama'],
      casts: ['Reza Rahadian', 'Chelsea Islan', 'Iko Uwais', 'Arifin Putra'],
      directors: ['Joko Anwar'],
      trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),
    's1': const MediaDetail(
      id: 's1',
      title: 'Cyberpunk Chronicles: Neo Jakarta',
      overview:
          'Di tengah gemerlap lampu neon kota metropolitan distopia Neo Jakarta tahun 2088, seorang hacker bawah tanah dan mantan agen keamanan korporat harus bersatu untuk mengungkap konspirasi AI raksasa yang mengendalikan pikiran populasi.',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.2,
      releaseYear: 2024,
      durationMinutes: 52,
      type: MediaType.series,
      genres: ['Cyberpunk', 'Aksi', 'Thriller', 'Sci-Fi'],
      casts: ['Joe Taslim', 'Tara Basro', 'Chicco Jerikho', 'Pevita Pearce'],
      directors: ['Timo Tjahjanto'],
      seasons: [
        SeasonItem(
          seasonNumber: 1,
          title: 'Musim 1: Bangkitnya Glitch',
          episodes: [
            EpisodeItem(
              id: 's1_e1',
              episodeNumber: 1,
              title: 'Protokol Nol',
              durationMinutes: 48,
              thumbnailUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80',
              overview: 'Sebuah transaksi data rahasia di distrik Glodok Cyber berakhir kacau saat pasukan drone korporat menyerang markas persembunyian.',
            ),
            EpisodeItem(
              id: 's1_e2',
              episodeNumber: 2,
              title: 'Sinyal Hantu',
              durationMinutes: 54,
              thumbnailUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80',
              overview: 'Penyelidikan jejak frekuensi membawa tim memasuki terowongan bawah tanah kota lama yang dihuni kelompok pemberontak.',
            ),
            EpisodeItem(
              id: 's1_e3',
              episodeNumber: 3,
              title: 'Kelebihan Beban Memori',
              durationMinutes: 50,
              thumbnailUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop&q=80',
              overview: 'Implan sibernetik salah satu kru mulai menunjukkan malfungsi setelah bersentuhan langsung dengan kode misterius.',
            ),
          ],
        ),
      ],
      trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    ),
    'a1': const MediaDetail(
      id: 'a1',
      title: 'Shadow Blade: Spirit Blossom',
      overview:
          'Kisah pendekar pedang yang membawa kutukan roh naga kuno dalam pengembaraannya melintasi kuil-kuil pegunungan berkabut untuk menebus dosa masa lalu.',
      posterUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1600&auto=format&fit=crop&q=80',
      rating: 9.5,
      releaseYear: 2024,
      durationMinutes: 24,
      type: MediaType.anime,
      genres: ['Anime', 'Aksi', 'Supranatural', 'Fantasi'],
      casts: ['Kenjiro Tsuda', 'Mamoru Miyano', 'Saori Hayami'],
      directors: ['Sunghoo Park'],
      seasons: [
        SeasonItem(
          seasonNumber: 1,
          title: 'Musim 1: Gerbang Arwah',
          episodes: [
            EpisodeItem(
              id: 'a1_e1',
              episodeNumber: 1,
              title: 'Pedang yang Terjaga',
              durationMinutes: 24,
              thumbnailUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=600&auto=format&fit=crop&q=80',
              overview: 'Di malam gerhana merah darah, segel kuno yang mengurung roh pedang terkutuk akhirnya retak.',
            ),
            EpisodeItem(
              id: 'a1_e2',
              episodeNumber: 2,
              title: 'Tebasan Angin Utara',
              durationMinutes: 24,
              thumbnailUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=600&auto=format&fit=crop&q=80',
              overview: 'Pertarungan sengit di atas jembatan bambu melawan pembunuh bayaran bayangan istana.',
            ),
          ],
        ),
      ],
      trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    ),
  };

  /// Sumber stream video yang stabil dan dapat langsung diuji di pemutar media
  static const List<StreamSource> sampleStreamSources = [
    StreamSource(
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      quality: VideoQuality.q1080p,
      isHls: false,
    ),
    StreamSource(
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      quality: VideoQuality.q720p,
      isHls: false,
    ),
    StreamSource(
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      quality: VideoQuality.q480p,
      isHls: false,
    ),
  ];

  /// Daftar subtitle sampel
  static const List<SubtitleTrack> sampleSubtitles = [
    SubtitleTrack(
      id: 'id_sub',
      language: 'id',
      label: 'Bahasa Indonesia',
      url: 'https://raw.githubusercontent.com/brenopolanski/html5-video-webvtt-example/master/subtitles/subtitles-en.vtt',
    ),
    SubtitleTrack(
      id: 'en_sub',
      language: 'en',
      label: 'English (US)',
      url: 'https://raw.githubusercontent.com/brenopolanski/html5-video-webvtt-example/master/subtitles/subtitles-en.vtt',
    ),
  ];
}
