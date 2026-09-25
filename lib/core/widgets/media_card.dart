// Komponen Kartu Media Universal (*Universal Media Poster Card*)
// Menampilkan poster, rating bintang, tag tipe, dan judul dengan estetika Apple HIG.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../contracts/models.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final double width;
  final double height;
  final String? customBadge;
  final Color? customBadgeColor;

  const MediaCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 130,
    this.height = 195,
    this.customBadge,
    this.customBadgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster dengan Border Radius & Efek Bayangan Halus
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    color: AppColors.surfaceElevated,
                    child: item.posterUrl.isNotEmpty
                        ? Image.network(
                            item.posterUrl,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackPoster(),
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }
                              return _buildFallbackPoster();
                            },
                          )
                        : _buildFallbackPoster(),
                  ),

                  // Badge Rating di Pojok Kiri Atas
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.starRating,
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: AppTypography.badge.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Badge Tipe (HD / Series) di Pojok Kanan Atas
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.type == MediaType.movie
                            ? AppColors.accentCyan.withValues(alpha: 0.85)
                            : AppColors.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.type == MediaType.movie
                            ? 'HD'
                            : (item.type == MediaType.anime ? 'ANIME' : 'SERIES'),
                        style: AppTypography.badge.copyWith(
                          fontSize: 9,
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  // Badge Khusus Update / Episode Baru (Gaya LokLok)
                  if (customBadge != null)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: customBadgeColor != null
                                ? [customBadgeColor!, customBadgeColor!.withValues(alpha: 0.8)]
                                : const [Color(0xFFFFB800), Color(0xFFFF5E00)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            customBadge!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Judul Media
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: 2),

            // Info Tahun dan Genre Utama
            Text(
              '${item.releaseYear} • ${item.genres.isNotEmpty ? item.genres.first : 'Umum'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.metadata.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  /// Poster Cadangan Artistik Apple HIG (*Cinematic Fallback Artwork*)
  /// Menjamin tampilan kartu selalu elegan dan tidak pernah menampilkan kotak kosong saat jaringan lambat.
  Widget _buildFallbackPoster() {
    List<Color> gradientColors;
    IconData iconData;

    if (item.type == MediaType.anime) {
      gradientColors = const [Color(0xFF2D1152), Color(0xFF130924)];
      iconData = Icons.auto_awesome_rounded;
    } else if (item.genres.any((g) => g.contains('Drakor') || g.contains('Romance'))) {
      gradientColors = const [Color(0xFF3B1238), Color(0xFF140816)];
      iconData = Icons.favorite_rounded;
    } else if (item.genres.any((g) => g.contains('Indonesia') || g.contains('Horor'))) {
      gradientColors = const [Color(0xFF2E1515), Color(0xFF0F0808)];
      iconData = Icons.nightlight_round;
    } else if (item.genres.any((g) => g.contains('Sci-Fi') || g.contains('Aksi'))) {
      gradientColors = const [Color(0xFF112233), Color(0xFF0A0F1A)];
      iconData = Icons.bolt_rounded;
    } else {
      gradientColors = const [Color(0xFF1F2430), Color(0xFF0E1118)];
      iconData = Icons.movie_filter_rounded;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 28,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Text(
              '${item.releaseYear}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
