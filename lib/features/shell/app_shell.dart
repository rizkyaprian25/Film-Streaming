// Kerangka Aplikasi Utama (App Shell) Bergaya LokLok dengan Navigasi Kaca (*Liquid Glass Bar*)
// Memadukan 4 tab navigasi utama tanpa login: Beranda, Kategori, Cari, dan Koleksi.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/presentation/home_screen.dart';
import '../discover/presentation/discover_screen.dart';
import '../search/presentation/search_screen.dart';
import '../library/presentation/library_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Daftar 4 layar utama aplikasi
  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true, // Memungkinkan konten scroll meluncur di bawah tab bar kaca
      bottomNavigationBar: _buildFrostedBottomBar(),
    );
  }

  /// Membangun bilah navigasi bawah dengan efek blur kaca transparan (Apple HIG Liquid Glass)
  Widget _buildFrostedBottomBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 0.6),
            ),
          ),
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: bottomPadding > 0 ? bottomPadding : 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Beranda',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.explore_rounded,
                label: 'Kategori',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.search_rounded,
                label: 'Cari',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.bookmark_rounded,
                label: 'Koleksi',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Komponen tombol item navigasi tunggal dengan touch target minimal 44x44 pt
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
