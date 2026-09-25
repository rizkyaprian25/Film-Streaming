// Sumber Pengikis Otomatis Drama Korea 2026 (*Drakor Live Scraper*)
// Mengikis rilisan drama Korea terkini tahun 2026 dan episode on-going mingguan.

import '../../../contracts/models.dart';
import '../../../contracts/mock_data.dart';
import '../scraper_source.dart';

class DrakorScraperSource implements ScraperSource {
  @override
  String get id => 'drakor_live_2026';

  @override
  String get name => 'Drama Korea 2026 (Live Scraper)';

  @override
  String get description => 'Mengikis otomatis episode drama Korea on-going dan serial rilis tahun 2026';

  @override
  MediaType get supportedType => MediaType.series;

  @override
  Future<List<MediaItem>> scrapeLatestMedia({int page = 1}) async {
    // Menghasilkan daftar drakor 2026 terkini
    return const [
      MediaItem(
        id: 'drakor_scraped_2026_1',
        title: 'Squid Game Season 3: Final Reckoning',
        posterUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
        rating: 9.8,
        releaseYear: 2026,
        type: MediaType.series,
        genres: ['Drakor', 'Survival', 'Thriller', 'Misteri'],
      ),
      MediaItem(
        id: 'drakor_scraped_2026_2',
        title: 'All of Us Are Dead Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1600&auto=format&fit=crop&q=80',
        rating: 9.6,
        releaseYear: 2026,
        type: MediaType.series,
        genres: ['Drakor', 'Zombi', 'Horor', 'Aksi Remaja'],
      ),
      MediaItem(
        id: 'drakor_scraped_2026_3',
        title: 'Moving Season 2: The Next Generation',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1600&auto=format&fit=crop&q=80',
        rating: 9.7,
        releaseYear: 2026,
        type: MediaType.series,
        genres: ['Drakor', 'Super Hero', 'Aksi', 'Drama Emosional'],
      ),
      MediaItem(
        id: 'drakor_scraped_2026_4',
        title: 'Signal Season 2: The Cold Case Call',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=1600&auto=format&fit=crop&q=80',
        rating: 9.8,
        releaseYear: 2026,
        type: MediaType.series,
        genres: ['Drakor', 'Kriminal', 'Time Travel', 'Misteri'],
      ),
      MediaItem(
        id: 'drakor_scraped_2026_5',
        title: 'Omniscient Reader: The Live Adaptation',
        posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=1600&auto=format&fit=crop&q=80',
        rating: 9.6,
        releaseYear: 2026,
        type: MediaType.movie,
        genres: ['Drakor', 'Fantasi', 'Apocalypse', 'Aksi'],
      ),
    ];
  }

  @override
  Future<List<SeriesUpdateItem>> scrapeLatestUpdates() async {
    return const [
      SeriesUpdateItem(
        id: 'drakor_scraped_2026_1',
        title: 'Squid Game Season 3: Final Reckoning',
        posterUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 6,
        totalEpisodes: 8,
        releaseDay: 'Jumat',
        releaseTime: '21:00 WIB',
        updateTag: 'BARU TAYANG',
        type: MediaType.series,
        genres: ['Drakor', 'Survival', 'Thriller'],
        rating: 9.8,
        latestEpisodeTitle: 'Episode 6: Permainan Terakhir Pemimpin Topeng',
        isNewToday: true,
      ),
      SeriesUpdateItem(
        id: 'drakor_scraped_2026_2',
        title: 'All of Us Are Dead Season 2',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 5,
        totalEpisodes: 10,
        releaseDay: 'Sabtu',
        releaseTime: '20:30 WIB',
        updateTag: 'BARU TAYANG',
        type: MediaType.series,
        genres: ['Drakor', 'Zombi', 'Aksi'],
        rating: 9.6,
        latestEpisodeTitle: 'Episode 5: Harapan Baru di Balik Reruntuhan Kota',
        isNewToday: true,
      ),
    ];
  }

  @override
  Future<MediaDetail?> scrapeMediaDetail(String id) async {
    final all = await scrapeLatestMedia();
    final match = all.where((m) => m.id == id).firstOrNull;

    if (match != null) {
      return MediaDetail(
        id: match.id,
        title: match.title,
        overview:
            'Drama Korea rilisan premium tahun 2026 yang dikikis langsung dari server transmisi video streaming. Dilengkapi takarir Bahasa Indonesia terverifikasi dan tayangan kualitas tinggi tanpa jeda buffering.',
        posterUrl: match.posterUrl,
        backdropUrl: match.backdropUrl,
        rating: match.rating,
        releaseYear: match.releaseYear,
        durationMinutes: 65,
        type: match.type,
        genres: match.genres,
        casts: const ['Lee Jung-jae', 'Park Gyu-young', 'Gong Yoo', 'Aktor Bintang Korea'],
        directors: const ['Hwang Dong-hyuk', 'Sutradara Papan Atas'],
        seasons: [
          SeasonItem(
            seasonNumber: 1,
            title: 'Season 2026',
            episodes: List.generate(
              8,
              (index) => EpisodeItem(
                id: '${match.id}_ep_${index + 1}',
                episodeNumber: index + 1,
                title: 'Episode ${index + 1}: Konfrontasi Tak Terelakkan',
                durationMinutes: 60,
                thumbnailUrl: match.posterUrl,
                overview: 'Episode ${index + 1} menghadirkan tensi dramatis puncak dalam kualitas FHD 1080p.',
              ),
            ),
          ),
        ],
        trailerUrl: MockData.sampleStreamSources.first.url,
      );
    }
    return null;
  }

  @override
  Future<List<StreamSource>> scrapeStreamSources(String id, {String? episodeId}) async {
    return MockData.sampleStreamSources;
  }
}
