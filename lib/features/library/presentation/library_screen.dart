// Layar Koleksi Saya (*Library Screen - Local-First & Tanpa Login*)
// Menyediakan tab "Lanjutkan Menonton" dan "Daftar Tontonan Tersimpan" berbasis SharedPreferences.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/storage/local_storage.dart';
import '../../../contracts/models.dart';
import '../../../main.dart';
import '../../detail/presentation/detail_screen.dart';
import '../../player/presentation/player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WatchHistoryItem> _historyList = [];
  List<WatchlistItem> _watchlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLocalCollections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalCollections() async {
    setState(() => _isLoading = true);
    final history = await LocalStorageService.instance.getWatchHistory();
    final watchlist = await LocalStorageService.instance.getWatchlist();

    if (mounted) {
      setState(() {
        _historyList = history;
        _watchlist = watchlist;
        _isLoading = false;
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
    ).then((_) => _loadLocalCollections());
  }

  void _removeHistory(String mediaId) async {
    await LocalStorageService.instance.removeWatchHistory(mediaId);
    _loadLocalCollections();
  }

  void _removeFromWatchlist(WatchlistItem item) async {
    await LocalStorageService.instance.toggleWatchlist(item);
    _loadLocalCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Koleksi Saya', style: AppTypography.sectionTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Riwayat Tontonan'),
            Tab(text: 'Daftar Tersimpan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(),
                _buildWatchlistTab(),
              ],
            ),
    );
  }

  /// Tab Riwayat Tontonan (Continue Watching)
  Widget _buildHistoryTab() {
    if (_historyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_toggle_off_rounded, color: AppColors.textMuted, size: 52),
            const SizedBox(height: 12),
            const Text('Belum Ada Riwayat Tontonan', style: AppTypography.sectionTitle),
            const SizedBox(height: 6),
            const Text(
              'Film atau serial yang Anda tonton akan otomatis muncul di sini.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _historyList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = _historyList[idx];

        return Dismissible(
          key: Key(item.mediaId),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeHistory(item.mediaId),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          child: InkWell(
            onTap: () => _resumePlayback(item),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.6),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 64,
                          color: AppColors.surfaceElevated,
                          child: Image.network(
                            item.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(color: AppColors.surfaceElevated),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.3),
                            child: const Center(
                              child: Icon(Icons.play_circle_fill, color: AppColors.primary, size: 28),
                            ),
                          ),
                        ),
                        // Bilah Progres Durasi
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            value: item.progressRatio,
                            minHeight: 3,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.episodeTitle ?? 'Lanjutkan memutar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.metadata.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tersisa ${_formatRemainingMinutes(item.durationSeconds - item.positionSeconds)}',
                          style: const TextStyle(color: AppColors.accentCyan, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                    onPressed: () => _removeHistory(item.mediaId),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Tab Daftar Tontonan Tersimpan (Watchlist)
  Widget _buildWatchlistTab() {
    if (_watchlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border_rounded, color: AppColors.textMuted, size: 52),
            const SizedBox(height: 12),
            const Text('Watchlist Anda Masih Kosong', style: AppTypography.sectionTitle),
            const SizedBox(height: 6),
            const Text(
              'Tekan ikon simpan pada halaman detail untuk mengoleksi film favorit Anda.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _watchlist.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = _watchlist[idx];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(mediaId: item.mediaId),
              ),
            ).then((_) => _loadLocalCollections());
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.6),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 55,
                    height: 80,
                    color: AppColors.surfaceElevated,
                    child: Image.network(
                      item.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: AppColors.surfaceElevated),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '★ ${item.rating.toStringAsFixed(1)}',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${item.releaseYear}', style: AppTypography.metadata),
                          const SizedBox(width: 6),
                          Text('•', style: AppTypography.metadata),
                          const SizedBox(width: 6),
                          Text(item.type.name.toUpperCase(), style: AppTypography.metadata.copyWith(color: AppColors.accentCyan)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove_outlined, color: AppColors.primary, size: 22),
                  onPressed: () => _removeFromWatchlist(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatRemainingMinutes(int remainingSeconds) {
    if (remainingSeconds <= 0) return 'Selesai';
    final minutes = (remainingSeconds / 60).ceil();
    return '$minutes menit';
  }
}
