// Kerangka Aplikasi Utama (App Shell) Bergaya LokLok dengan Navigasi Kaca (*Liquid Glass Bar*)
// Memadukan 5 tab navigasi utama tanpa login: Beranda, Update (Jadwal Rilis), Kategori, Cari, dan Koleksi.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auto_update_service.dart';
import '../home/presentation/home_screen.dart';
import '../updates/presentation/updates_screen.dart';
import '../discover/presentation/discover_screen.dart';
import '../search/presentation/search_screen.dart';
import '../library/presentation/library_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Navigasi langsung antar tab dari layar mana pun
  static void switchTab(BuildContext context, int tabIndex) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    state?.switchTab(tabIndex);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Daftar 5 layar utama aplikasi bergaya LokLok 100%
  final List<Widget> _screens = const [
    HomeScreen(),
    UpdatesScreen(),
    DiscoverScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  void switchTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onTabSelected(int index) {
    switchTab(index);
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
            left: 8,
            right: 8,
            top: 6,
            bottom: bottomPadding > 0 ? bottomPadding : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Beranda',
              ),
              _buildNavItemWithBadge(
                index: 1,
                icon: Icons.update_rounded,
                label: 'Update',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.explore_rounded,
                label: 'Kategori',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.search_rounded,
                label: 'Cari',
              ),
              _buildNavItem(
                index: 4,
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
        constraints: const BoxConstraints(minWidth: 58, minHeight: 44),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Komponen tombol item navigasi khusus dengan Badge Notifikasi Dinamis
  Widget _buildNavItemWithBadge({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 58, minHeight: 44),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: AutoUpdateService.instance.unreadCountNotifier,
                builder: (context, unreadCount, child) {
                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                    backgroundColor: Colors.redAccent,
                    child: Icon(
                      icon,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                      size: 22,
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
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
