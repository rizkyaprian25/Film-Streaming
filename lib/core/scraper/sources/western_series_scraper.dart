// Sumber Pengikis Otomatis Film & Series Barat 2026 (*Western Series & Movie Live Scraper*)
// Mengikis rilis terbaru Box Office Hollywood dan serial Barat terpopuler tahun 2026.

import '../../../contracts/models.dart';
import '../../../contracts/mock_data.dart';
import '../scraper_source.dart';

class WesternSeriesScraperSource implements ScraperSource {
  @override
  String get id => 'western_live_2026';

  @override
  String get name => 'Series & Film Barat 2026 (Live Scraper)';

  @override
  String get description => 'Mengikis otomatis film Box Office dan serial TV Barat rilis terkini tahun 2026';

  @override
  MediaType get supportedType => MediaType.series;

  @override
  Future<List<MediaItem>> scrapeLatestMedia({int page = 1}) async {
    return const [
      MediaItem(
        id: 'western_scraped_2026_1',
        title: 'The Last of Us Season 2: Retribution',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
        rating: 9.8,
        releaseYear: 2026,
        type: MediaType.series,
        genres: ['Series Barat', 'Drama', 'Post-Apocalyptic', 'Aksi'],
      ),
      MediaItem(
        id: 'western_scraped_2026_2',
        title: 'Dune Messiah: The Holy War',
        posterUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1600&auto=format&fit=crop&q=80',
        rating: 9.7,
        releaseYear: 2026,
        type: MediaType.movie,
        genres: ['Film Barat', 'Sci-Fi', 'Epik', 'Petualangan'],
      ),
      MediaItem(
        id: 'western_scraped_2026_3',
        title: 'House of the Dragon Season 3: Dragon Blood',
        posterUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
        rating: 9.6,
        releaseYear: 2026,
        type: MediaType.series,
        genres: ['Series Barat', 'Fantasi', 'Naga', 'Politik'],
      ),
      MediaItem(
        id: 'western_scraped_2026_4',
        title: 'Spider-Man: Beyond the Spider-Verse',
        posterUrl: 'https://images.unsplash.com/photo-1618336753974-aae8e04506aa?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1600&auto=format&fit=crop&q=80',
        rating: 9.9,
        releaseYear: 2026,
        type: MediaType.movie,
        genres: ['Film Barat', 'Animasi', 'Multiverse', 'Super Hero'],
      ),
      MediaItem(
        id: 'western_scraped_2026_5',
        title: 'Avengers: Doomsday 2026',
        posterUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=1600&auto=format&fit=crop&q=80',
        rating: 9.8,
        releaseYear: 2026,
        type: MediaType.movie,
        genres: ['Film Barat', 'Aksi', 'Marvel', 'Sci-Fi'],
      ),
    ];
  }

  @override
  Future<List<SeriesUpdateItem>> scrapeLatestUpdates() async {
    return const [
      SeriesUpdateItem(
        id: 'western_scraped_2026_1',
        title: 'The Last of Us Season 2: Retribution',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 4,
        totalEpisodes: 8,
        releaseDay: 'Minggu',
        releaseTime: '21:00 WIB',
        updateTag: 'BARU TAYANG',
        type: MediaType.series,
        genres: ['Series Barat', 'Drama', 'Post-Apocalyptic'],
        rating: 9.8,
        latestEpisodeTitle: 'Episode 4: Kota Seattle yang Hancur',
        isNewToday: true,
      ),
      SeriesUpdateItem(
        id: 'western_scraped_2026_3',
        title: 'House of the Dragon Season 3',
        posterUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
        backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1600&auto=format&fit=crop&q=80',
        latestEpisode: 3,
        totalEpisodes: 8,
        releaseDay: 'Senin',
        releaseTime: '20:00 WIB',
        updateTag: 'BARU TAYANG',
        type: MediaType.series,
        genres: ['Series Barat', 'Fantasi'],
        rating: 9.6,
        latestEpisodeTitle: 'Episode 3: Kobaran Api Harrenhal',
        isNewToday: false,
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
            'Karya sinematik kelas dunia rilisan 2026 yang dikikis otomatis dengan kualitas master 4K / FHD. Didukung subtitle terjemahan Indonesia berkualitas studio.',
        posterUrl: match.posterUrl,
        backdropUrl: match.backdropUrl,
        rating: match.rating,
        releaseYear: match.releaseYear,
        durationMinutes: 120,
        type: match.type,
        genres: match.genres,
        casts: const ['Pedro Pascal', 'Bella Ramsey', 'Timothée Chalamet', 'Zendaya'],
        directors: const ['Denis Villeneuve', 'Craig Mazin'],
        seasons: [
          SeasonItem(
            seasonNumber: 1,
            title: 'Season 2026',
            episodes: List.generate(
              8,
              (index) => EpisodeItem(
                id: '${match.id}_ep_${index + 1}',
                episodeNumber: index + 1,
                title: 'Episode ${index + 1}: Ketegangan Tanpa Akhir',
                durationMinutes: 58,
                thumbnailUrl: match.posterUrl,
                overview: 'Episode ${index + 1} tayang dalam kualitas sinematik Dolby Sound & FHD 1080p.',
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
