// Skala Tipografi Berakar pada Standar Apple HIG
// Menggunakan hierarki visual yang jelas untuk keterbacaan optimal di layar smartphone.

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  /// Judul besar pada Hero Banner
  static const TextStyle displayLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Judul seksi katalog (misal: "Sedang Tren", "Serial TV")
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Judul kartu film
  static const TextStyle cardTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    overflow: TextOverflow.ellipsis,
    height: 1.3,
  );

  /// Teks tombol utama (*Call To Action*)
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: Colors.black87,
  );

  /// Teks isi sinopsis dan deskripsi episode
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// Label metadata (Tahun rilis, durasi, genre)
  static const TextStyle metadata = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Teks mikro badge (Rating, resolusi HD, nomor episode)
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );
}
