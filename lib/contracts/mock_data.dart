// Dataset Katalog Lengkap Bergaya LokLok (Single Source of Truth - SSOT)
// Memuat katalog komprehensif: Drakor, Anime, Series Barat, Film Barat (Box Office), dan Film Indonesia.

import 'models.dart';

class MockData {
  // ==========================================
  // 1. BANNER HERO CAROUSEL UTAMA
  // ==========================================
  static const List<MediaItem> featuredList = [
    MediaItem(
      id: 'k1',
      title: 'Queen of Tears',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 9.3,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Drakor', 'Romance', 'Drama'],
    ),
    MediaItem(
      id: 'a1',
      title: 'Solo Leveling: Arise',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.6,
      releaseYear: 2024,
      type: MediaType.anime,
      genres: ['Anime', 'Aksi', 'Fantasi'],
    ),
    MediaItem(
      id: 'h1',
      title: 'Dune: Part Two',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.0,
      releaseYear: 2024,
      type: MediaType.movie,
      genres: ['Film Barat', 'Sci-Fi', 'Petualangan'],
    ),
    MediaItem(
      id: 'w1',
      title: 'The Last of Us',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.1,
      releaseYear: 2023,
      type: MediaType.series,
      genres: ['Series Barat', 'Aksi', 'Horor', 'Drama'],
    ),
    MediaItem(
      id: 'id1',
      title: 'Gadis Kretek (Cigarette Girl)',
      posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2023,
      type: MediaType.series,
      genres: ['Indonesia', 'Drama', 'Romance', 'Sejarah'],
    ),
  ];

  // ==========================================
  // 2. DRAMA KOREA (DRAKOR) POPULER
  // ==========================================
  static const List<MediaItem> drakorList = [
    MediaItem(
      id: 'k1',
      title: 'Queen of Tears',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 9.3,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Drakor', 'Romance', 'Drama', 'Keluarga'],
    ),
    MediaItem(
      id: 'k2',
      title: 'Lovely Runner',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.4,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Drakor', 'Romance', 'Time Travel', 'Komedi'],
    ),
    MediaItem(
      id: 'k3',
      title: 'Vincenzo',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
      rating: 9.0,
      releaseYear: 2021,
      type: MediaType.series,
      genres: ['Drakor', 'Aksi', 'Kriminal', 'Komedi Gelap'],
    ),
    MediaItem(
      id: 'k4',
      title: 'Crash Landing on You',
      posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 9.2,
      releaseYear: 2019,
      type: MediaType.series,
      genres: ['Drakor', 'Romance', 'Militer', 'Drama'],
    ),
    MediaItem(
      id: 'k5',
      title: 'Squid Game',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.1,
      releaseYear: 2021,
      type: MediaType.series,
      genres: ['Drakor', 'Thriller', 'Survival', 'Misteri'],
    ),
    MediaItem(
      id: 'k6',
      title: 'All of Us Are Dead',
      posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.8,
      releaseYear: 2022,
      type: MediaType.series,
      genres: ['Drakor', 'Zombie', 'Horor', 'Aksi'],
    ),
    MediaItem(
      id: 'k7',
      title: 'Marry My Husband',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Drakor', 'Balas Dendam', 'Romance', 'Drama'],
    ),
    MediaItem(
      id: 'k8',
      title: 'Moving',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 9.3,
      releaseYear: 2023,
      type: MediaType.series,
      genres: ['Drakor', 'Super Hero', 'Aksi', 'Sci-Fi'],
    ),
  ];

  // ==========================================
  // 3. ANIME TERPOPULER
  // ==========================================
  static const List<MediaItem> animeList = [
    MediaItem(
      id: 'a1',
      title: 'Solo Leveling: Arise',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.6,
      releaseYear: 2024,
      type: MediaType.anime,
      genres: ['Anime', 'Aksi', 'Dungeon', 'Fantasi'],
    ),
    MediaItem(
      id: 'a2',
      title: 'Jujutsu Kaisen Season 2',
      posterUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1600&auto=format&fit=crop&q=80',
      rating: 9.5,
      releaseYear: 2023,
      type: MediaType.anime,
      genres: ['Anime', 'Supranatural', 'Shounen', 'Aksi'],
    ),
    MediaItem(
      id: 'a3',
      title: 'Demon Slayer: Hashira Training',
      posterUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 9.4,
      releaseYear: 2024,
      type: MediaType.anime,
      genres: ['Anime', 'Pedang', 'Iblis', 'Aksi'],
    ),
    MediaItem(
      id: 'a4',
      title: 'Attack on Titan: The Final Chapters',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.7,
      releaseYear: 2023,
      type: MediaType.anime,
      genres: ['Anime', 'Militer', 'Misteri', 'Epik'],
    ),
    MediaItem(
      id: 'a5',
      title: 'One Piece: Egghead Arc',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.4,
      releaseYear: 2024,
      type: MediaType.anime,
      genres: ['Anime', 'Bajak Laut', 'Petualangan', 'Komedi'],
    ),
    MediaItem(
      id: 'a6',
      title: 'Spy x Family Season 2',
      posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.1,
      releaseYear: 2023,
      type: MediaType.anime,
      genres: ['Anime', 'Mata-mata', 'Komedi', 'Keluarga'],
    ),
    MediaItem(
      id: 'a7',
      title: 'Chainsaw Man',
      posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1600&auto=format&fit=crop&q=80',
      rating: 9.0,
      releaseYear: 2023,
      type: MediaType.anime,
      genres: ['Anime', 'Aksi', 'Gelap', 'Supranatural'],
    ),
    MediaItem(
      id: 'a8',
      title: 'Frieren: Beyond Journey\'s End',
      posterUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 9.6,
      releaseYear: 2024,
      type: MediaType.anime,
      genres: ['Anime', 'Fantasi', 'Petualangan', 'Emosional'],
    ),
  ];

  // ==========================================
  // 4. SERIAL BARAT (WESTERN SERIES)
  // ==========================================
  static const List<MediaItem> westernSeriesList = [
    MediaItem(
      id: 'w1',
      title: 'The Last of Us',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.1,
      releaseYear: 2023,
      type: MediaType.series,
      genres: ['Series Barat', 'Aksi', 'Horor', 'Drama'],
    ),
    MediaItem(
      id: 'w2',
      title: 'Stranger Things',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.2,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Series Barat', 'Sci-Fi', 'Misteri', 'Horor'],
    ),
    MediaItem(
      id: 'w3',
      title: 'House of the Dragon',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Series Barat', 'Fantasi', 'Naga', 'Epik'],
    ),
    MediaItem(
      id: 'w4',
      title: 'Wednesday',
      posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.8,
      releaseYear: 2023,
      type: MediaType.series,
      genres: ['Series Barat', 'Misteri', 'Fantasi', 'Gotik'],
    ),
    MediaItem(
      id: 'w5',
      title: 'Fallout',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Series Barat', 'Paska-Apokaliptik', 'Sci-Fi', 'Aksi'],
    ),
    MediaItem(
      id: 'w6',
      title: 'The Boys Season 4',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
      rating: 9.0,
      releaseYear: 2024,
      type: MediaType.series,
      genres: ['Series Barat', 'Superhero Gelap', 'Satir', 'Aksi'],
    ),
    MediaItem(
      id: 'w7',
      title: 'Loki Season 2',
      posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.1,
      releaseYear: 2023,
      type: MediaType.series,
      genres: ['Series Barat', 'Multiverse', 'Marvel', 'Sci-Fi'],
    ),
  ];

  // ==========================================
  // 5. FILM BARAT & HOLLYWOOD BOX OFFICE
  // ==========================================
  static const List<MediaItem> hollywoodList = [
    MediaItem(
      id: 'h1',
      title: 'Dune: Part Two',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.0,
      releaseYear: 2024,
      type: MediaType.movie,
      genres: ['Film Barat', 'Sci-Fi', 'Petualangan', 'Epik'],
    ),
    MediaItem(
      id: 'h2',
      title: 'Oppenheimer',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 9.2,
      releaseYear: 2023,
      type: MediaType.movie,
      genres: ['Film Barat', 'Biografi', 'Sejarah', 'Drama'],
    ),
    MediaItem(
      id: 'h3',
      title: 'Spider-Man: Across the Spider-Verse',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.3,
      releaseYear: 2023,
      type: MediaType.movie,
      genres: ['Film Barat', 'Animasi', 'Aksi', 'Superhero'],
    ),
    MediaItem(
      id: 'h4',
      title: 'John Wick: Chapter 4',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2023,
      type: MediaType.movie,
      genres: ['Film Barat', 'Aksi', 'Thriller', 'Bela Diri'],
    ),
    MediaItem(
      id: 'h5',
      title: 'Deadpool & Wolverine',
      posterUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.8,
      releaseYear: 2024,
      type: MediaType.movie,
      genres: ['Film Barat', 'Komedi', 'Marvel', 'Aksi'],
    ),
    MediaItem(
      id: 'h6',
      title: 'Interstellar',
      posterUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
      rating: 9.3,
      releaseYear: 2014,
      type: MediaType.movie,
      genres: ['Film Barat', 'Sci-Fi', 'Ruang Angkasa', 'Drama'],
    ),
  ];

  // ==========================================
  // 6. FILM & SERIAL INDONESIA
  // ==========================================
  static const List<MediaItem> indonesianList = [
    MediaItem(
      id: 'id1',
      title: 'Gadis Kretek (Cigarette Girl)',
      posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2023,
      type: MediaType.series,
      genres: ['Indonesia', 'Drama', 'Romance', 'Sejarah'],
    ),
    MediaItem(
      id: 'id2',
      title: 'Pengabdi Setan 2: Communion',
      posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.7,
      releaseYear: 2022,
      type: MediaType.movie,
      genres: ['Indonesia', 'Horor', 'Misteri'],
    ),
    MediaItem(
      id: 'id3',
      title: 'The Night Comes for Us',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 8.6,
      releaseYear: 2018,
      type: MediaType.movie,
      genres: ['Indonesia', 'Aksi', 'Thriller', 'Bela Diri'],
    ),
    MediaItem(
      id: 'id4',
      title: 'Sewu Dino',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
      rating: 8.4,
      releaseYear: 2023,
      type: MediaType.movie,
      genres: ['Indonesia', 'Horor', 'Santet', 'Misteri'],
    ),
    MediaItem(
      id: 'id5',
      title: 'Sri Asih',
      posterUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1600&auto=format&fit=crop&q=80',
      rating: 8.5,
      releaseYear: 2022,
      type: MediaType.movie,
      genres: ['Indonesia', 'Superhero', 'Bumilangit', 'Aksi'],
    ),
    MediaItem(
      id: 'id6',
      title: 'Agak Laen',
      posterUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.1,
      releaseYear: 2024,
      type: MediaType.movie,
      genres: ['Indonesia', 'Komedi', 'Horor', 'Persahabatan'],
    ),
  ];

  // ==========================================
  // 7. GABUNGAN SEDANG TREN
  // ==========================================
  static List<MediaItem> get trendingList => [
        ...drakorList.take(3),
        ...animeList.take(3),
        ...hollywoodList.take(3),
        ...westernSeriesList.take(3),
        ...indonesianList.take(2),
      ];

  // ==========================================
  // 8. DETAIL MEDIA LENGKAP & EPISODE LOKLOK
  // ==========================================
  static final Map<String, MediaDetail> mediaDetails = {
    // DRAKOR: Queen of Tears
    'k1': const MediaDetail(
      id: 'k1',
      title: 'Queen of Tears',
      overview:
          'Kisah cinta penuh liku dan tak terduga antara ratu department store konglomerat Hong Hae-in dan suaminya, Baek Hyun-woo yang berasal dari pedesaan. Ketika pernikahan mereka berada di ambang kehancuran, krisis kesehatan dan intrik keluarga membawa mereka menemukan kembali arti cinta sejati.',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop&q=80',
      rating: 9.3,
      releaseYear: 2024,
      durationMinutes: 75,
      type: MediaType.series,
      genres: ['Drakor', 'Romance', 'Drama', 'Keluarga'],
      casts: ['Kim Soo-hyun', 'Kim Ji-won', 'Park Sung-hoon', 'Kwak Dong-yeon'],
      directors: ['Jang Young-woo', 'Kim Hee-won'],
      seasons: [
        SeasonItem(
          seasonNumber: 1,
          title: 'Musim 1',
          episodes: [
            EpisodeItem(
              id: 'k1_e1',
              episodeNumber: 1,
              title: 'Pernikahan Abad Ini',
              durationMinutes: 72,
              thumbnailUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600&auto=format&fit=crop&q=80',
              overview: 'Baek Hyun-woo merasa tertekan dalam keluarga konglomerat Queens Group dan berencana mengajukan perceraian.',
            ),
            EpisodeItem(
              id: 'k1_e2',
              episodeNumber: 2,
              title: 'Waktu yang Tersisa',
              durationMinutes: 76,
              thumbnailUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop&q=80',
              overview: 'Pengakuan mengejutkan dari Hong Hae-in mengubah seluruh keputusan hidup Hyun-woo.',
            ),
            EpisodeItem(
              id: 'k1_e3',
              episodeNumber: 3,
              title: 'Rahasia di Desa Yongdu-ri',
              durationMinutes: 75,
              thumbnailUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600&auto=format&fit=crop&q=80',
              overview: 'Kunjungan keluarga konglomerat ke kampung halaman Hyun-woo memicu kelucuan dan kehangatan baru.',
            ),
          ],
        ),
      ],
      trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),

    // ANIME: Solo Leveling
    'a1': const MediaDetail(
      id: 'a1',
      title: 'Solo Leveling: Arise',
      overview:
          'Di dunia di mana portal misterius menghubungkan dunia manusia dengan dungeon penuh monster buas, Sung Jin-woo dikenal sebagai hunter terlemah peringkat E. Namun saat terjebak dalam Double Dungeon mematikan, ia mendapatkan quest rahasia untuk "naik level" seorang diri tanpa batas.',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.6,
      releaseYear: 2024,
      durationMinutes: 24,
      type: MediaType.anime,
      genres: ['Anime', 'Aksi', 'Dungeon', 'Fantasi'],
      casts: ['Taito Ban', 'Genta Nakamura', 'Reina Ueda'],
      directors: ['Shunsuke Nakashige'],
      seasons: [
        SeasonItem(
          seasonNumber: 1,
          title: 'Musim 1: Kebangkitan Sang Bayangan',
          episodes: [
            EpisodeItem(
              id: 'a1_e1',
              episodeNumber: 1,
              title: 'Hunter Terlemah di Dunia',
              durationMinutes: 24,
              thumbnailUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80',
              overview: 'Jin-woo mempertaruhkan nyawanya memasuki dungeon peringkat D demi membiayai pengobatan ibunya.',
            ),
            EpisodeItem(
              id: 'a1_e2',
              episodeNumber: 2,
              title: 'Kuil Ganda yang Terkutuk',
              durationMinutes: 24,
              thumbnailUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80',
              overview: 'Patung dewa raksasa membuka matanya dan membantai seluruh regu hunter.',
            ),
            EpisodeItem(
              id: 'a1_e3',
              episodeNumber: 3,
              title: 'Quest Harian: Bertahan Hidup',
              durationMinutes: 24,
              thumbnailUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop&q=80',
              overview: 'Terbangun di ranjang rumah sakit dengan jendela status melayang di depan matanya.',
            ),
          ],
        ),
      ],
      trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    ),

    // FILM BARAT: Dune: Part Two
    'h1': const MediaDetail(
      id: 'h1',
      title: 'Dune: Part Two',
      overview:
          'Paul Atreides bersatu dengan Chani dan suku Fremen di gurun Arrakis untuk membalaskan dendam keluarganya dari konspirasi House Harkonnen dan Sang Kaisar. Dalam perjalanannya, ia harus memilih antara cinta sejatinya dan takdir alam semesta yang mengerikan.',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&auto=format&fit=crop&q=80',
      rating: 9.0,
      releaseYear: 2024,
      durationMinutes: 166,
      type: MediaType.movie,
      genres: ['Film Barat', 'Sci-Fi', 'Petualangan', 'Epik'],
      casts: ['Timothée Chalamet', 'Zendaya', 'Rebecca Ferguson', 'Austin Butler'],
      directors: ['Denis Villeneuve'],
      trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    ),

    // SERIES BARAT: The Last of Us
    'w1': const MediaDetail(
      id: 'w1',
      title: 'The Last of Us',
      overview:
          'Dua puluh tahun setelah pandemi jamur memusnahkan peradaban modern, Joel, seorang penyintas tangguh disewa untuk menyelundupkan Ellie, gadis 14 tahun yang kebal terhadap infeksi melintasi Amerika yang brutal.',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1600&auto=format&fit=crop&q=80',
      rating: 9.1,
      releaseYear: 2023,
      durationMinutes: 55,
      type: MediaType.series,
      genres: ['Series Barat', 'Aksi', 'Horor', 'Drama'],
      casts: ['Pedro Pascal', 'Bella Ramsey', 'Gabriel Luna'],
      directors: ['Craig Mazin', 'Neil Druckmann'],
      seasons: [
        SeasonItem(
          seasonNumber: 1,
          title: 'Musim 1',
          episodes: [
            EpisodeItem(
              id: 'w1_e1',
              episodeNumber: 1,
              title: 'Saat Kau Tersesat dalam Kegelapan',
              durationMinutes: 81,
              thumbnailUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop&q=80',
              overview: 'Wabah Cordyceps meledak di Texas; 20 tahun kemudian Joel menerima tugas berbahaya di Boston.',
            ),
            EpisodeItem(
              id: 'w1_e2',
              episodeNumber: 2,
              title: 'Terinfeksi',
              durationMinutes: 53,
              thumbnailUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80',
              overview: 'Joel, Tess, dan Ellie harus menyeberangi reruntuhan museum yang dihuni makhluk Clicker.',
            ),
          ],
        ),
      ],
      trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),

    // INDONESIA: Gadis Kretek
    'id1': const MediaDetail(
      id: 'id1',
      title: 'Gadis Kretek (Cigarette Girl)',
      overview:
          'Pencarian sosok Jeng Yah yang misterius membawa tiga bersaudara menelusuri sejarah industri tembakau kretek Indonesia di era 1960-an, menyingkap cinta terlarang, pengkhianatan bisnis, dan resep saus rokok legendaris.',
      posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=80',
      backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
      rating: 8.9,
      releaseYear: 2023,
      durationMinutes: 60,
      type: MediaType.series,
      genres: ['Indonesia', 'Drama', 'Romance', 'Sejarah'],
      casts: ['Dian Sastrowardoyo', 'Ario Bayu', 'Putri Marino', 'Arya Saloka'],
      directors: ['Kamila Andini', 'Ifa Isfansyah'],
      seasons: [
        SeasonItem(
          seasonNumber: 1,
          title: 'Musim 1',
          episodes: [
            EpisodeItem(
              id: 'id1_e1',
              episodeNumber: 1,
              title: 'Jeng Yah',
              durationMinutes: 62,
              thumbnailUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=600&auto=format&fit=crop&q=80',
              overview: 'Kakek Soeraja yang sekarat terus memanggil nama Jeng Yah, membuat Lebas memulai perjalanannya.',
            ),
            EpisodeItem(
              id: 'id1_e2',
              episodeNumber: 2,
              title: 'Resep Rahasia',
              durationMinutes: 58,
              thumbnailUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600&auto=format&fit=crop&q=80',
              overview: 'Dasiyah berjuang melawan tradisi patriarki untuk membuktikan keahlian meracik saus tembakaunya.',
            ),
          ],
        ),
      ],
      trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    ),
  };

  // ==========================================
  // 9. SUMBER STREAM VIDEO PUBLIK MULTI-KUALITAS
  // ==========================================
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
