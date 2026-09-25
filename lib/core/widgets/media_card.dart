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
                    child: Image.network(
                      item.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Icon(
                          Icons.movie_outlined,
                          color: AppColors.textMuted,
                          size: 36,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.surfaceElevated,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
}
