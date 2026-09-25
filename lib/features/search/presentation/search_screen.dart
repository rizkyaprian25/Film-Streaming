// Layar Pencarian Cepat (*Search Screen with Debouncing*)
// Mendukung pencarian instan dengan jeda debounce 300ms dan rekomendasi kata kunci populer.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media_card.dart';
import '../../../contracts/models.dart';
import '../../../main.dart';
import '../../detail/presentation/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<MediaItem> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  final List<String> _popularTags = [
    'Queen of Tears',
    'Solo Leveling',
    'Dune 2',
    'The Last of Us',
    'Stranger Things',
    'Jujutsu Kaisen',
    'Gadis Kretek',
    'Squid Game',
    'Drakor',
    'Anime',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery == _lastQuery) return;
    _lastQuery = cleanQuery;

    if (cleanQuery.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final provider = CineFlowAppScope.of(context);
    final res = await provider.searchMedia(cleanQuery);

    if (mounted) {
      setState(() {
        _results = res.data ?? [];
        _isSearching = false;
      });
    }
  }

  void _applyTag(String tag) {
    _searchController.text = tag;
    _executeSearch(tag);
  }

  void _clearSearch() {
    _searchController.clear();
    _executeSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari film, serial TV, anime...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _searchController.text.isEmpty
          ? _buildDefaultExploreView()
          : _buildSearchResultsView(),
    );
  }

  /// Tampilan awal sebelum pengguna mengetik kata kunci
  Widget _buildDefaultExploreView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pencarian Populer', style: AppTypography.sectionTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTags.map((tag) {
              return ActionChip(
                label: Text(tag),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                backgroundColor: AppColors.surfaceElevated,
                side: const BorderSide(color: AppColors.border, width: 0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onPressed: () => _applyTag(tag),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Tampilan hasil pencarian media
  Widget _buildSearchResultsView() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              'Tidak ditemukan hasil untuk "${_searchController.text}"',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
      ),
      itemCount: _results.length,
      itemBuilder: (context, idx) {
        final item = _results[idx];
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
    );
  }
}
