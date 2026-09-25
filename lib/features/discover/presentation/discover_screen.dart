// Layar Kategori & Eksplorasi Konten (*Discover & Filter Screen*)
// Menyediakan filter genre dinamis, filter tipe, dan tata letak grid poster responsif.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media_card.dart';
import '../../../contracts/models.dart';
import '../../../main.dart';
import '../../detail/presentation/detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedGenre = 'Semua';
  MediaType? _selectedType;
  List<MediaItem> _allItems = [];
  bool _isLoading = true;

  final List<String> _genres = [
    'Semua',
    'Aksi',
    'Sci-Fi',
    'Fantasi',
    'Thriller',
    'Drama',
    'Anime',
    'Misteri',
    'Petualangan',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final provider = CineFlowAppScope.of(context);

    final trendingRes = await provider.getTrending();
    final moviesRes = await provider.getByCategory('popular_movies');
    final seriesRes = await provider.getByCategory('tv_series');
    final animeRes = await provider.getByCategory('anime');

    final combined = <MediaItem>{
      ...(trendingRes.data ?? []),
      ...(moviesRes.data ?? []),
      ...(seriesRes.data ?? []),
      ...(animeRes.data ?? []),
    }.toList();

    if (mounted) {
      setState(() {
        _allItems = combined;
        _isLoading = false;
      });
    }
  }

  List<MediaItem> get _filteredItems {
    return _allItems.where((item) {
      final matchesGenre = _selectedGenre == 'Semua' ||
          item.genres.any((g) => g.toLowerCase() == _selectedGenre.toLowerCase());
      final matchesType = _selectedType == null || item.type == _selectedType;
      return matchesGenre && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jelajah Katalog', style: AppTypography.sectionTitle),
      ),
      body: Column(
        children: [
          // Filter Baris 1: Pilihan Tipe Media (Semua, Film, Serial, Anime)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                _buildTypeChip('Semua', null),
                const SizedBox(width: 8),
                _buildTypeChip('Film', MediaType.movie),
                const SizedBox(width: 8),
                _buildTypeChip('Serial', MediaType.series),
                const SizedBox(width: 8),
                _buildTypeChip('Anime', MediaType.anime),
              ],
            ),
          ),

          // Filter Baris 2: Horisontal Chips Genre
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _genres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final genre = _genres[idx];
                final isSel = _selectedGenre == genre;

                return ChoiceChip(
                  label: Text(genre),
                  selected: isSel,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : Colors.white70,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.surfaceElevated,
                  onSelected: (_) => setState(() => _selectedGenre = genre),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Grid Hasil Katalog Konten
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada konten untuk kategori $_selectedGenre',
                          style: AppTypography.bodyMedium,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.52,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final item = filtered[idx];
                          return MediaCard(
                            item: item,
                            width: double.infinity,
                            height: 155,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(mediaId: item.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, MediaType? type) {
    final isSel = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? AppColors.primary : AppColors.border,
              width: 0.6,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                color: isSel ? Colors.black : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
