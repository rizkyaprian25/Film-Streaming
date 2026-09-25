// Layar Beranda Utama (Home Catalog & Hero Carousel)
// Mengimplementasikan tata letak katalog LokLok dengan Banner Hero, Continue Watching, dan barisan konten.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/widgets/media_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../contracts/models.dart';
import '../../../main.dart';
import '../../detail/presentation/detail_screen.dart';
import '../../player/presentation/player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroPageController = PageController();
  int _currentHeroIndex = 0;

  List<MediaItem> _featuredList = [];
  List<MediaItem> _trendingList = [];
  List<MediaItem> _drakorList = [];
  List<MediaItem> _animeList = [];
  List<MediaItem> _westernSeriesList = [];
  List<MediaItem> _hollywoodList = [];
  List<MediaItem> _indonesianList = [];
  List<MediaItem> _allMediaList = [];
  List<WatchHistoryItem> _continueWatchingList = [];

  bool _isLoading = true;
  String _selectedCategoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCatalog();
    });
  }

  Future<void> _loadCatalog() async {
    setState(() => _isLoading = true);
    final provider = CineFlowAppScope.of(context);

    // Ambil seluruh kategori secara paralel dengan Future.wait
    final results = await Future.wait([
      provider.getFeaturedMedia(),
      provider.getTrending(),
      provider.getByCategory('drakor'),
      provider.getByCategory('anime'),
      provider.getByCategory('western_series'),
      provider.getByCategory('hollywood'),
      provider.getByCategory('indonesian'),
    ]);

    final featuredRes = results[0];
    final trendingRes = results[1];
    final drakorRes = results[2];
    final animeRes = results[3];
    final westernRes = results[4];
    final hollywoodRes = results[5];
    final indoRes = results[6];
    final history = await LocalStorageService.instance.getWatchHistory();

    final combined = <MediaItem>{
      ...(featuredRes.data ?? []),
      ...(trendingRes.data ?? []),
      ...(drakorRes.data ?? []),
      ...(animeRes.data ?? []),
      ...(westernRes.data ?? []),
      ...(hollywoodRes.data ?? []),
      ...(indoRes.data ?? []),
    }.toList();

    if (mounted) {
      setState(() {
        _featuredList = featuredRes.data ?? [];
        _trendingList = trendingRes.data ?? [];
        _drakorList = drakorRes.data ?? [];
        _animeList = animeRes.data ?? [];
        _westernSeriesList = westernRes.data ?? [];
        _hollywoodList = hollywoodRes.data ?? [];
        _indonesianList = indoRes.data ?? [];
        _allMediaList = combined;
        _continueWatchingList = history;
        _isLoading = false;
      });
    }
  }

  void _openDetail(String mediaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(mediaId: mediaId),
      ),
    ).then((_) {
      // Muat ulang daftar lanjutkan tontonan saat kembali dari detail/player
      _refreshContinueWatching();
    });
  }

  Future<void> _refreshContinueWatching() async {
    final history = await LocalStorageService.instance.getWatchHistory();
    if (mounted) {
      setState(() {
        _continueWatchingList = history;
      });
    }
  }

  void _resumePlayback(WatchHistoryItem item) async {
    final provider = CineFlowAppScope.of(context);
    final detailRes = await provider.getMediaDetail(item.mediaId);
    final detail = detailRes.data;

    if (detail == null || !mounted) return;

    final sourcesRes = await provider.getStreamSources(
      mediaId: item.mediaId,
      episodeId: item.episodeId,
    );
    final subsRes = await provider.getSubtitles(
      mediaId: item.mediaId,
      episodeId: item.episodeId,
    );

    if (!mounted) return;

    EpisodeItem? matchedEpisode;
    if (item.episodeId != null && detail.seasons.isNotEmpty) {
      for (final s in detail.seasons) {
        for (final ep in s.episodes) {
          if (ep.id == item.episodeId) {
            matchedEpisode = ep;
            break;
          }
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          media: detail,
          initialEpisode: matchedEpisode,
          streamSources: sourcesRes.data ?? const [],
          subtitles: subsRes.data ?? const [],
          initialPositionSeconds: item.positionSeconds,
        ),
      ),
    ).then((_) => _refreshContinueWatching());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadCatalog,
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceElevated,
        child: CustomScrollView(
          slivers: [
            // Bilah Atas Mengambang Transparan
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: AppColors.background.withValues(alpha: 0.9),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'CINEFLOW',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(42),
                child: _buildCategoryPills(),
              ),
            ),

            // Jika filter bukan 'all', tampilkan grid poster vertikal kategori tersebut
            if (_selectedCategoryFilter != 'all') ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: '${_getCategoryTitle(_selectedCategoryFilter)} (${_getFilteredList(_selectedCategoryFilter).length} Judul)',
                  onSeeAll: null,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, idx) {
                      final item = _getFilteredList(_selectedCategoryFilter)[idx];
                      return MediaCard(
                        item: item,
                        width: double.infinity,
                        height: 155,
                        onTap: () => _openDetail(item.id),
                      );
                    },
                    childCount: _getFilteredList(_selectedCategoryFilter).length,
                  ),
                ),
              ),
            ] else ...[
              // Banner Hero Carousel
              if (_featuredList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildHeroCarousel(),
                ),

              // Seksi Lanjutkan Menonton (LokLok Signature)
              if (_continueWatchingList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildContinueWatchingSection(),
                ),

              // Baris Sedang Tren
              if (_trendingList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildMediaRow(
                    title: 'Sedang Tren 🔥',
                    items: _trendingList,
                    onSeeAll: () => setState(() => _selectedCategoryFilter = 'trending'),
                  ),
                ),

              // Baris Drama Korea (Drakor)
              if (_drakorList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildMediaRow(
                    title: 'Drama Korea Populer (Drakor) 💖',
                    items: _drakorList,
                    onSeeAll: () => setState(() => _selectedCategoryFilter = 'drakor'),
                  ),
                ),

              // Baris Anime Terpopuler
              if (_animeList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildMediaRow(
                    title: 'Anime Terpopuler ⚔️',
                    items: _animeList,
                    onSeeAll: () => setState(() => _selectedCategoryFilter = 'anime'),
                  ),
                ),

              // Baris Series Barat Unggulan
              if (_westernSeriesList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildMediaRow(
                    title: 'Series Barat Unggulan 📺',
                    items: _westernSeriesList,
                    onSeeAll: () => setState(() => _selectedCategoryFilter = 'western_series'),
                  ),
                ),

              // Baris Film Barat & Box Office
              if (_hollywoodList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildMediaRow(
                    title: 'Film Barat & Box Office 🎬',
                    items: _hollywoodList,
                    onSeeAll: () => setState(() => _selectedCategoryFilter = 'hollywood'),
                  ),
                ),

              // Baris Film & Serial Indonesia
              if (_indonesianList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildMediaRow(
                    title: 'Film & Serial Indonesia 🇮🇩',
                    items: _indonesianList,
                    onSeeAll: () => setState(() => _selectedCategoryFilter = 'indonesian'),
                  ),
                ),

              // Eksplorasi Grid Masif 200+ Konten di Bagian Bawah
              if (_allMediaList.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Jelajahi Semua Koleksi (200+ Judul Lengkap) 🌟',
                    onSeeAll: null,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.52,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, idx) {
                        final item = _allMediaList[idx];
                        return MediaCard(
                          item: item,
                          width: double.infinity,
                          height: 155,
                          onTap: () => _openDetail(item.id),
                        );
                      },
                      childCount: _allMediaList.length,
                    ),
                  ),
                ),
              ],
            ],

            // Ruang Penahan Bawah agar Tidak Tertutup Tab Bar Kaca
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  /// Bilah Filter Kategori Cepat di Atas
  Widget _buildCategoryPills() {
    final categories = [
      {'id': 'all', 'label': 'Semua'},
      {'id': 'drakor', 'label': 'Drakor'},
      {'id': 'anime', 'label': 'Anime'},
      {'id': 'western_series', 'label': 'Series Barat'},
      {'id': 'hollywood', 'label': 'Film Barat'},
      {'id': 'indonesian', 'label': 'Indonesia'},
    ];

    return Container(
      height: 38,
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final isSelected = _selectedCategoryFilter == cat['id'];

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryFilter = cat['id']!;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 0.6,
                ),
              ),
              child: Center(
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Banner Hero Carousel Sinematik
  Widget _buildHeroCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _heroPageController,
            itemCount: _featuredList.length,
            onPageChanged: (index) {
              setState(() => _currentHeroIndex = index);
            },
            itemBuilder: (context, index) {
              final item = _featuredList[index];

              return GestureDetector(
                onTap: () => _openDetail(item.id),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.backdropUrl.isNotEmpty ? item.backdropUrl : item.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: AppColors.surfaceElevated),
                    ),
                    // Gradien Bayangan Gelap Apple HIG
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.4, 0.8, 1.0],
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Color(0xCC0C0D12),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                    // Informasi Media & Tombol Tonton Instan
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.displayLarge.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '★ ${item.rating.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.genres.take(3).join(' • '),
                                style: AppTypography.metadata,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _openDetail(item.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                                label: const Text('Tonton Sekarang', style: AppTypography.buttonText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Titik Indikator Hero Carousel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_featuredList.length, (idx) {
            final isCurrent = _currentHeroIndex == idx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              width: isCurrent ? 18 : 6,
              height: 4,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primary : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Seksi "Lanjutkan Menonton" dengan Indikator Progres Persentase
  Widget _buildContinueWatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Lanjutkan Menonton',
          onSeeAll: null,
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _continueWatchingList.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final item = _continueWatchingList[idx];

              return GestureDetector(
                onTap: () => _resumePlayback(item),
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Container(
                              width: 200,
                              height: 110,
                              color: AppColors.surfaceElevated,
                              child: Image.network(
                                item.posterUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(color: AppColors.surfaceElevated),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.35),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: AppColors.primary,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            // Bilah Progres Durasi Menonton
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: LinearProgressIndicator(
                                value: item.progressRatio,
                                minHeight: 4,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle,
                      ),
                      Text(
                        item.episodeTitle ?? 'Lanjutkan memutar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.metadata.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Komponen Baris Katalog Horisontal
  Widget _buildMediaRow({
    required String title,
    required List<MediaItem> items,
    VoidCallback? onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAll: onSeeAll,
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, idx) {
              final media = items[idx];
              return MediaCard(
                item: media,
                onTap: () => _openDetail(media.id),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Judul Deskriptif Kategori Berdasarkan Filter
  String _getCategoryTitle(String catId) {
    switch (catId) {
      case 'drakor':
        return 'Drama Korea Populer (Drakor) 💖';
      case 'anime':
        return 'Anime Terpopuler ⚔️';
      case 'western_series':
        return 'Series Barat Unggulan 📺';
      case 'hollywood':
        return 'Film Barat & Box Office 🎬';
      case 'indonesian':
        return 'Film & Serial Indonesia 🇮🇩';
      case 'trending':
        return 'Sedang Tren Terpanas 🔥';
      default:
        return 'Semua Koleksi';
    }
  }

  /// Ambil Daftar Media Sesuai Kategori
  List<MediaItem> _getFilteredList(String catId) {
    switch (catId) {
      case 'drakor':
        return _drakorList;
      case 'anime':
        return _animeList;
      case 'western_series':
        return _westernSeriesList;
      case 'hollywood':
        return _hollywoodList;
      case 'indonesian':
        return _indonesianList;
      case 'trending':
        return _trendingList;
      default:
        return _allMediaList;
    }
  }
}
