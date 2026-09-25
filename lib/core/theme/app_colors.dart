// Token Warna Semantik (Design Tokens) Berbasis Apple HIG & Nuansa Sinematik LokLok
// Dirancang dengan kontras tinggi, aksen warna emas/kuning cerah, dan latar hitam pekat.

import 'package:flutter/material.dart';

class AppColors {
  // Latar Belakang & Permukaan Sinematik (Dark Mode)
  static const Color background = Color(0xFF0C0D12);      // Latar belakang utama (Obsidian pekat)
  static const Color surface = Color(0xFF14161F);         // Lapisan kartu dan komponen dasar
  static const Color surfaceElevated = Color(0xFF1D202C); // Lapisan dialog, modal sheet, & header
  static const Color surfaceGlass = Color(0xCC12141E);    // Lapisan kaca transparan (*Liquid Glass*)

  // Warna Aksen Utama (Khas LokLok / Golden Cine)
  static const Color primary = Color(0xFFFFD028);         // Kuning emas sinematik (CTA & highlight)
  static const Color primaryDark = Color(0xFFE5B510);     // Kuning emas pekat saat ditekan
  static const Color primaryLight = Color(0xFFFFE680);    // Kuning muda untuk efek glow
  static const Color accentCyan = Color(0xFF2DD4BF);      // Aksen toska sekunder untuk badge resolusi HD
  static const Color accentRed = Color(0xFFEF4444);       // Merah untuk badge sedang tren / favorit

  // Tipografi & Teks
  static const Color textPrimary = Color(0xFFF9FAFB);     // Teks judul dan label utama (kontras tinggi)
  static const Color textSecondary = Color(0xFF9CA3AF);   // Teks sinopsis, metadata, dan subtitle
  static const Color textMuted = Color(0xFF6B7280);       // Teks placeholder dan caption kecil

  // Batas & Pemisah
  static const Color border = Color(0xFF262A3B);          // Garis pemisah halus
  static const Color borderLight = Color(0xFF374151);     // Batas saat item dipilih atau aktif

  // Indikator Status & Fungsional
  static const Color starRating = Color(0xFFFBBF24);      // Kuning bintang penilaian
  static const Color success = Color(0xFF10B981);         // Status unduhan/koneksi aman
  static const Color error = Color(0xFFF87171);           // Peringatan kegagalan pemutaran
}
