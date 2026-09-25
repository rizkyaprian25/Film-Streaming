// Layar Detail Film & Serial (*Media Detail Screen*)
// Menghadirkan sinopsis, pemeran, pemilih episode bergaya LokLok, dan tombol tonton instan.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/widgets/media_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../contracts/models.dart';
import '../../../main.dart';
import '../../player/presentation/player_screen.dart';

class DetailScreen extends StatefulWidget {
  final String mediaId;

  const DetailScreen({super.key, required this.mediaId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  MediaDetail? _detail;
  List<MediaItem> _recommendations = [];
  bool _isLoading = true;
  bool _isInWatchlist = false;
  int _selectedSeasonIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadDetail();
    });
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final provider = CineFlowAppScope.of(context);

    final detailRes = await provider.getMediaDetail(widget.mediaId);
    final recRes = await provider.getTrending();
    final inWatchlist = await LocalStorageService.instance.isInWatchlist(widget.mediaId);

    if (mounted) {
      setState(() {
        _detail = detailRes.data;
        _recommendations = recRes.data ?? [];
        _isInWatchlist = inWatchlist;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    if (_detail == null) return;
    final item = WatchlistItem(
      mediaId: _detail!.id,
      title: _detail!.title,
      posterUrl: _detail!.posterUrl,
      rating: _detail!.rating,
      releaseYear: _detail!.releaseYear,
      type: _detail!.type,
      addedAt: DateTime.now(),
    );

    final added = await LocalStorageService.instance.toggleWatchlist(item);
    if (mounted) {
      setState(() {
        _isInWatchlist = added;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.surfaceElevated,
          content: Text(
            added ? 'Ditambahkan ke Koleksi Saya' : 'Dihapus dari Koleksi',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _startPlayback({EpisodeItem? episode, int initialSeconds = 0}) async {
    if (_detail == null) return;
    final provider = CineFlowAppScope.of(context);

    // Ambil sumber stream dan subtitle dari provider
    final sourcesRes = await provider.getStreamSources(
      mediaId: _detail!.id,
      episodeId: episode?.id,
    );
    final subsRes = await provider.getSubtitles(
      mediaId: _detail!.id,
      episodeId: episode?.id,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          media: _detail!,
          initialEpisode: episode,
          streamSources: sourcesRes.data ?? const [],
          subtitles: subsRes.data ?? const [],
          initialPositionSeconds: initialSeconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _detail == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final detail = _detail!;
    final seasons = detail.seasons;
    final currentEpisodes = seasons.isNotEmpty && _selectedSeasonIndex < seasons.length
        ? seasons[_selectedSeasonIndex].episodes
        : <EpisodeItem>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header Hero Banner dengan Tombol Aksi Kaca
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isInWatchlist ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                    color: _isInWatchlist ? AppColors.primary : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: _toggleWatchlist,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    detail.backdropUrl.isNotEmpty ? detail.backdropUrl : detail.posterUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, _, _) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF231828), Color(0xFF111420), Color(0xFF090A0E)],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.movie_filter_rounded,
                          size: 60,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  // Gradien Hitam Sinematik
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x990C0D12),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten Utama Detail
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Badge Tipe
                  Text(detail.title, style: AppTypography.displayLarge),
                  const SizedBox(height: 8),

                  // Metadata Baris (Rating, Tahun, Durasi)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '★ ${detail.rating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${detail.releaseYear}', style: AppTypography.metadata),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      Text(
                        detail.isSeries
                            ? '${detail.seasons.length} Musim'
                            : '${detail.durationMinutes} Menit',
                        style: AppTypography.metadata,
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      Text('Ultra HD', style: AppTypography.metadata.copyWith(color: AppColors.accentCyan)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Genre Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: detail.genres.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Text(
                          g,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Tombol Tonton Utama (Call to Action)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _startPlayback(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text('Tonton Sekarang', style: AppTypography.buttonText),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ringkasan Sinopsis
                  const Text('Sinopsis', style: AppTypography.sectionTitle),
                  const SizedBox(height: 6),
                  Text(detail.overview, style: AppTypography.bodyMedium),
                  const SizedBox(height: 20),

                  // Sutradara & Pemeran
                  if (detail.casts.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pemeran: ',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            detail.casts.join(', '),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (detail.directors.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sutradara: ',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            detail.directors.join(', '),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Bagian Pemilih Episode LokLok (Khusus Serial / Anime)
                  if (detail.isSeries && seasons.isNotEmpty) ...[
                    const Divider(color: AppColors.border, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daftar Episode', style: AppTypography.sectionTitle),
                        Text(
                          '${currentEpisodes.length} Episode',
                          style: AppTypography.metadata,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tab Musim jika ada lebih dari 1 musim
                    if (seasons.length > 1)
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: seasons.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final isSel = _selectedSeasonIndex == idx;
                            return ChoiceChip(
                              label: Text('Musim ${seasons[idx].seasonNumber}'),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.black : Colors.white70,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                              backgroundColor: AppColors.surfaceElevated,
                              onSelected: (_) => setState(() => _selectedSeasonIndex = idx),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Kartu Episode Horisontal Bergaya LokLok
                    SizedBox(
                      height: 155,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: currentEpisodes.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final ep = currentEpisodes[index];
                          return GestureDetector(
                            onTap: () => _startPlayback(episode: ep),
                            child: SizedBox(
                              width: 180,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 180,
                                          height: 100,
                                          color: AppColors.surfaceElevated,
                                          child: ep.thumbnailUrl.isNotEmpty
                                              ? Image.network(ep.thumbnailUrl, fit: BoxFit.cover)
                                              : const Icon(Icons.movie, color: AppColors.textMuted),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.black.withValues(alpha: 0.25),
                                            child: const Center(
                                              child: Icon(
                                                Icons.play_circle_fill_rounded,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 4,
                                          right: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${ep.durationMinutes}m',
                                              style: const TextStyle(color: Colors.white, fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Ep. ${ep.episodeNumber}: ${ep.title}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ep.overview,
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

                  // Bagian Rekomendasi Film Serupa
                  if (_recommendations.isNotEmpty) ...[
                    const Divider(color: AppColors.border, height: 32),
                    SectionHeader(title: 'Rekomendasi Serupa', onSeeAll: null),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommendations.length,
                        itemBuilder: (context, idx) {
                          final rec = _recommendations[idx];
                          return MediaCard(
                            item: rec,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(mediaId: rec.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
