// Layar Jadwal Rilis Mingguan & Update Otomatis Gaya LokLok 100% (*Release Schedule & Auto-Updates*)
// Menampilkan update episode serial baru secara otomatis, kalender harian (Senin-Minggu),
// tombol ingatkan saya, dan akses langsung ke pemutar video.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/auto_update_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../contracts/models.dart';
import '../../../main.dart';
import '../../detail/presentation/detail_screen.dart';
import '../../player/presentation/player_screen.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  final AutoUpdateService _updateService = AutoUpdateService.instance;
  String _selectedDay = 'Semua';
  String _selectedCategory = 'Semua';
  Set<String> _reminders = {};

  final List<String> _days = [
    'Semua',
    'Hari Ini',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  final List<String> _categories = [
    'Semua',
    'Drakor',
    'Anime',
    'Series Barat',
    'Indonesia',
  ];

  @override
  void initState() {
    super.initState();
    // Defaultkan ke hari ini jika ingin langsung melihat yang rilis hari ini
    final today = _updateService.getTodayDayName();
    _selectedDay = 'Hari Ini ($today)';
    _days[1] = 'Hari Ini ($today)';

    _loadReminders();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateService.checkUpdates();
      }
    });
  }

  Future<void> _loadReminders() async {
    final list = await LocalStorageService.instance.getReminders();
    if (mounted) {
      setState(() {
        _reminders = list.toSet();
      });
    }
  }

  Future<void> _toggleReminder(SeriesUpdateItem item) async {
    final active = await LocalStorageService.instance.toggleReminder(item.id);
    if (!mounted) return;

    setState(() {
      if (active) {
        _reminders.add(item.id);
      } else {
        _reminders.remove(item.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          active
              ? '🔔 Pengingat aktif untuk "${item.title}". Anda akan diberitahu saat episode rilis!'
              : '🔕 Pengingat dimatikan untuk "${item.title}".',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor: active ? AppColors.primary : AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDetail(String mediaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(mediaId: mediaId),
      ),
    );
  }

  Future<void> _playLatestEpisode(SeriesUpdateItem updateItem) async {
    final provider = CineFlowAppScope.of(context);
    final detailRes = await provider.getMediaDetail(updateItem.id);
    final detail = detailRes.data;

    if (detail == null || !mounted) return;

    final sourcesRes = await provider.getStreamSources(mediaId: updateItem.id);
    final subsRes = await provider.getSubtitles(mediaId: updateItem.id);

    if (!mounted) return;

    // Ambil episode terbaru dari daftar atau buat representasi episode
    final episode = _updateService.createPlayableEpisode(updateItem);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          media: detail,
          initialEpisode: episode,
          streamSources: sourcesRes.data ?? const [],
          subtitles: subsRes.data ?? const [],
        ),
      ),
    );
  }

  List<SeriesUpdateItem> _filterItems(List<SeriesUpdateItem> allItems) {
    final today = _updateService.getTodayDayName();

    return allItems.where((item) {
      // Filter Berdasarkan Hari
      bool matchesDay = true;
      if (_selectedDay.startsWith('Hari Ini')) {
        matchesDay = item.releaseDay == today || item.isNewToday;
      } else if (_selectedDay != 'Semua') {
        matchesDay = item.releaseDay == _selectedDay;
      }

      // Filter Berdasarkan Kategori
      bool matchesCategory = true;
      if (_selectedCategory != 'Semua') {
        matchesCategory = item.genres.any((g) => g.toLowerCase() == _selectedCategory.toLowerCase());
      }

      return matchesDay && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Jadwal & Rilis Baru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.redAccent, width: 0.6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.redAccent, size: 7),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Text(
              'Episode baru disinkronkan otomatis setiap hari',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _updateService.isSyncingNotifier,
            builder: (context, isSyncing, child) {
              return IconButton(
                icon: isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.sync_rounded, color: AppColors.primary),
                tooltip: 'Periksa Update Otomatis',
                onPressed: isSyncing
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await _updateService.checkUpdates(force: true);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('✨ Jadwal & update episode berhasil disinkronkan!'),
                            duration: Duration(seconds: 1),
                            backgroundColor: AppColors.surfaceElevated,
                          ),
                        );
                      },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _updateService.checkUpdates(force: true),
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceElevated,
        child: Column(
          children: [
            // Baris 1: Filter Hari (Senin - Minggu + Hari Ini)
            _buildDaySelector(),

            // Baris 2: Filter Kategori (Semua, Drakor, Anime, dll)
            _buildCategorySelector(),

            const Divider(color: AppColors.border, height: 1),

            // Daftar Seri & Episode yang Diperbarui
            Expanded(
              child: ValueListenableBuilder<List<SeriesUpdateItem>>(
                valueListenable: _updateService.updatesNotifier,
                builder: (context, allUpdates, child) {
                  final filtered = _filterItems(allUpdates);

                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 54,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada jadwal rilis untuk $_selectedDay',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Coba pilih hari lain untuk melihat rilis mendatang',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      final isReminded = _reminders.contains(item.id);
                      return _buildScheduleCard(item, isReminded);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bilah Pemilih Hari Kalender Rilis
  Widget _buildDaySelector() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final day = _days[idx];
          final isSelected = _selectedDay == day;
          final isToday = day.startsWith('Hari Ini');

          return InkWell(
            onTap: () => setState(() => _selectedDay = day),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isToday ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceElevated),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday ? AppColors.primary : AppColors.border),
                  width: isToday ? 1.0 : 0.6,
                ),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : (isToday ? FontWeight.w700 : FontWeight.w500),
                    color: isSelected
                        ? Colors.black
                        : (isToday ? AppColors.primary : Colors.white70),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Bilah Pemilih Kategori
  Widget _buildCategorySelector() {
    return Container(
      height: 38,
      padding: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final cat = _categories[idx];
          final isSelected = _selectedCategory == cat;

          return InkWell(
            onTap: () => setState(() => _selectedCategory = cat),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white12 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Kartu Serial Jadwal Rilis Bergaya LokLok 100%
  Widget _buildScheduleCard(SeriesUpdateItem item, bool isReminded) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isNewToday ? AppColors.primary.withValues(alpha: 0.6) : AppColors.border,
          width: item.isNewToday ? 1.0 : 0.6,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster dengan Badge Episode Baru
            GestureDetector(
              onTap: () => _openDetail(item.id),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 95,
                      height: 135,
                      child: Image.network(
                        item.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(color: Colors.black26),
                      ),
                    ),
                    // Badge Rilis di Poster
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        color: item.isNewToday ? AppColors.primary : Colors.black87,
                        child: Center(
                          child: Text(
                            'EP. ${item.latestEpisode}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Metadata Detail Serial & Episode Rilis
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag Status Rilis
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.isNewToday
                              ? Colors.redAccent.withValues(alpha: 0.2)
                              : AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: item.isNewToday ? Colors.redAccent : AppColors.primary,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          item.updateTag,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: item.isNewToday ? Colors.redAccent : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item.releaseDay} • ${item.releaseTime}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Judul Serial
                  GestureDetector(
                    onTap: () => _openDetail(item.id),
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Judul Episode Terbaru
                  Text(
                    item.latestEpisodeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Genre
                  Text(
                    item.genres.join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Aksi: Tonton Sekarang & Ingatkan Saya
                  Row(
                    children: [
                      // Tombol Tonton Episode Terbaru
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _playLatestEpisode(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text(
                            'Tonton Ep.',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tombol Pengingat (Bel Ingatkan Saya)
                      IconButton.filledTonal(
                        onPressed: () => _toggleReminder(item),
                        style: IconButton.styleFrom(
                          backgroundColor: isReminded
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.white10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(7),
                        ),
                        icon: Icon(
                          isReminded ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                          color: isReminded ? AppColors.primary : AppColors.textMuted,
                          size: 18,
                        ),
                        tooltip: isReminded ? 'Hapus Pengingat' : 'Ingatkan Saya',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
