// Pemutar Video Kustom Bergaya LokLok (*Custom Cinematic Video Player*)
// Dilengkapi kontrol gesit, pemilih episode di dalam player, pemilih kualitas & subtitle, serta auto-save posisi tontonan.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/storage/local_storage.dart';
import '../../../contracts/models.dart';
import '../../../contracts/mock_data.dart';

class PlayerScreen extends StatefulWidget {
  final MediaDetail media;
  final EpisodeItem? initialEpisode;
  final List<StreamSource> streamSources;
  final List<SubtitleTrack> subtitles;
  final int initialPositionSeconds;

  const PlayerScreen({
    super.key,
    required this.media,
    this.initialEpisode,
    required this.streamSources,
    this.subtitles = const [],
    this.initialPositionSeconds = 0,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  Timer? _controlsTimer;
  Timer? _progressSaveTimer;

  late List<StreamSource> _availableSources;
  int _currentSourceIndex = 0;
  late StreamSource _currentSource;
  EpisodeItem? _currentEpisode;
  SubtitleTrack? _selectedSubtitle;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.initialEpisode ??
        (widget.media.seasons.isNotEmpty && widget.media.seasons.first.episodes.isNotEmpty
            ? widget.media.seasons.first.episodes.first
            : null);

    // Kumpulkan seluruh sumber stream video dan cadangan multi-mirror resmi
    _availableSources = widget.streamSources.isNotEmpty
        ? List<StreamSource>.from(widget.streamSources)
        : List<StreamSource>.from(MockData.sampleStreamSources);

    for (final backup in MockData.sampleStreamSources) {
      if (!_availableSources.any((s) => s.url == backup.url)) {
        _availableSources.add(backup);
      }
    }

    _currentSourceIndex = 0;
    _currentSource = _availableSources.first;

    if (widget.subtitles.isNotEmpty) {
      _selectedSubtitle = widget.subtitles.first;
    }

    _initializePlayer();
    _startPeriodicProgressSaver();
  }

  /// Inisialisasi pemutar video dengan Failover Otomatis Multi-Mirror
  Future<void> _initializePlayer({bool autoFailover = true}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final oldController = _controller;
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(_currentSource.url),
        httpHeaders: _currentSource.httpHeaders ?? const {},
      );

      await oldController?.dispose();
      await _controller!.initialize();

      if (widget.initialPositionSeconds > 0) {
        await _controller!.seekTo(Duration(seconds: widget.initialPositionSeconds));
      }

      await _controller!.play();

      _controller!.addListener(_onPlayerStateChanged);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
          _hasError = false;
        });
        _resetControlsTimer();
      }
    } catch (e) {
      // Auto failover ke cermin video berikutnya jika server saat ini gagal
      if (autoFailover && _currentSourceIndex + 1 < _availableSources.length) {
        _currentSourceIndex++;
        _currentSource = _availableSources[_currentSourceIndex];
        await _initializePlayer(autoFailover: true);
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage =
              'Tidak dapat memutar video pada server ini. Silakan pilih server streaming lain di bawah atau periksa koneksi jaringan Anda.';
        });
      }
    }
  }

  void _onPlayerStateChanged() {
    if (!mounted || _controller == null) return;
    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      _showControlsTemporarily();
    } else {
      _controller!.play();
      _resetControlsTimer();
    }
  }

  void _seekRelative(int seconds) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final currentPos = _controller!.value.position;
    final targetPos = currentPos + Duration(seconds: seconds);
    final duration = _controller!.value.duration;

    if (targetPos < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (targetPos > duration) {
      _controller!.seekTo(duration);
    } else {
      _controller!.seekTo(targetPos);
    }
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _resetControlsTimer();
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    if (_isPlaying) {
      _controlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _startPeriodicProgressSaver() {
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _saveCurrentPlaybackProgress();
    });
  }

  void _saveCurrentPlaybackProgress() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final positionSec = _controller!.value.position.inSeconds;
    final durationSec = _controller!.value.duration.inSeconds;

    if (durationSec <= 0) return;

    final historyItem = WatchHistoryItem(
      mediaId: widget.media.id,
      title: widget.media.title,
      posterUrl: widget.media.posterUrl,
      episodeId: _currentEpisode?.id,
      episodeTitle: _currentEpisode != null
          ? 'Ep. ${_currentEpisode!.episodeNumber}: ${_currentEpisode!.title}'
          : null,
      positionSeconds: positionSec,
      durationSeconds: durationSec,
      updatedAt: DateTime.now(),
    );

    LocalStorageService.instance.saveWatchProgress(historyItem);
  }

  void _selectEpisode(EpisodeItem episode) {
    Navigator.pop(context);
    setState(() {
      _currentEpisode = episode;
    });
    _saveCurrentPlaybackProgress();
    _initializePlayer();
  }

  void _selectQuality(StreamSource source) {
    Navigator.pop(context);
    final idx = _availableSources.indexOf(source);
    if (idx != -1) {
      _switchServer(idx);
    } else {
      final currentPos = _controller?.value.position ?? Duration.zero;
      setState(() {
        _currentSource = source;
      });
      _initializePlayer(autoFailover: false).then((_) {
        if (currentPos > Duration.zero) {
          _controller?.seekTo(currentPos);
        }
      });
    }
  }

  void _switchServer(int index) {
    if (_currentSourceIndex == index && _controller != null && _controller!.value.isInitialized) {
      return;
    }
    final currentPos = _controller?.value.position ?? Duration.zero;
    setState(() {
      _currentSourceIndex = index;
      _currentSource = _availableSources[index];
    });
    _initializePlayer(autoFailover: false).then((_) {
      if (currentPos > Duration.zero) {
        _controller?.seekTo(currentPos);
      }
    });
  }

  void _selectSubtitle(SubtitleTrack? track) {
    Navigator.pop(context);
    setState(() {
      _selectedSubtitle = track;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _progressSaveTimer?.cancel();
    _saveCurrentPlaybackProgress();
    _controller?.removeListener(_onPlayerStateChanged);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveVideo = _controller != null && _controller!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (_showControls) {
              setState(() => _showControls = false);
              _controlsTimer?.cancel();
            } else {
              _showControlsTemporarily();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Lapisan Layar Video Utama
              Center(
                child: hasActiveVideo
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : Container(color: Colors.black),
              ),

              // Indikator Loading Saat Buffering / Inisialisasi
              if (_isLoading)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 12),
                      Text(
                        'Memuat Streaming...',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              // Tampilan Kesalahan Pemutaran (*Error Recovery*)
              if (_hasError)
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded, color: AppColors.primary, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Kendala Sumber Pemutaran',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showServerSheet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.dns_rounded, size: 18),
                              label: Text('Ganti Server (${_availableSources.length} Mirror)'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _initializePlayer(autoFailover: false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AppColors.borderLight),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Coba Lagi'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textMuted,
                              ),
                              child: const Text('Kembali ke Detail'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Hamparan Teks Subtitle
              if (_selectedSubtitle != null && hasActiveVideo)
                Positioned(
                  bottom: _showControls ? 80 : 30,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '(${_selectedSubtitle!.label})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              // Lapisan Kontrol Player Kustom (Auto-Hide)
              if (_showControls && !_hasError)
                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bilah Atas Kontrol (Back, Title, Subtitle, Quality, Episodes)
                      _buildTopBar(),

                      // Bilah Tengah (Rewind -10, Play/Pause, Forward +10)
                      _buildCenterControls(),

                      // Bilah Bawah (Timeline Slider, Timestamp, Fullscreen)
                      _buildBottomBar(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bilah Navigasi & Opsi di Atas Video
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.media.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (_currentEpisode != null)
                  Text(
                    'Ep. ${_currentEpisode!.episodeNumber}: ${_currentEpisode!.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // Tombol Pemilih Episode (Khusus Serial / Anime)
          if (widget.media.isSeries && widget.media.seasons.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.video_library_outlined, color: Colors.white, size: 22),
              tooltip: 'Daftar Episode',
              onPressed: _showEpisodeSheet,
            ),

          // Tombol Pilihan Subtitle
          IconButton(
            icon: const Icon(Icons.subtitles_outlined, color: Colors.white, size: 22),
            tooltip: 'Subtitle',
            onPressed: _showSubtitleSheet,
          ),

          // Tombol Pilihan Kualitas Stream
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
            tooltip: 'Kualitas Video',
            onPressed: _showQualitySheet,
          ),

          // Tombol Pemilih Server Streaming (Multi-Mirror)
          InkWell(
            onTap: _showServerSheet,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 0.6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.dns_rounded, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Server ${_currentSourceIndex + 1}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kontrol Putar Tengah (-10s, Play/Pause, +10s)
  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 40,
          color: Colors.white,
          icon: const Icon(Icons.replay_10_rounded),
          onPressed: () => _seekRelative(-10),
        ),
        const SizedBox(width: 28),
        InkWell(
          onTap: _togglePlayPause,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.black,
              size: 42,
            ),
          ),
        ),
        const SizedBox(width: 28),
        IconButton(
          iconSize: 40,
          color: Colors.white,
          icon: const Icon(Icons.forward_10_rounded),
          onPressed: () => _seekRelative(10),
        ),
      ],
    );
  }

  /// Bilah Bawah (Timeline Slider & Tombol Fullscreen)
  Widget _buildBottomBar() {
    final position = _controller?.value.position ?? Duration.zero;
    final duration = _controller?.value.duration ?? Duration.zero;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 12, bottom: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.primary,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    trackHeight: 3.5,
                  ),
                  child: Slider(
                    value: position.inMilliseconds
                        .clamp(0, duration.inMilliseconds)
                        .toDouble(),
                    min: 0.0,
                    max: duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1.0,
                    onChanged: (value) {
                      _seekTo(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _seekTo(Duration target) {
    _controller?.seekTo(target);
    _showControlsTemporarily();
  }

  /// Lembar Pemilih Episode LokLok Langsung di Dalam Player
  void _showEpisodeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final episodes = widget.media.seasons.isNotEmpty
            ? widget.media.seasons.first.episodes
            : <EpisodeItem>[];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Episode', style: AppTypography.sectionTitle),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: episodes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final ep = episodes[index];
                    final isCurrent = _currentEpisode?.id == ep.id;

                    return ListTile(
                      tileColor: isCurrent
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isCurrent ? AppColors.primary : AppColors.border,
                          width: isCurrent ? 1.0 : 0.5,
                        ),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 60,
                          height: 38,
                          color: AppColors.surfaceElevated,
                          child: ep.thumbnailUrl.isNotEmpty
                              ? Image.network(ep.thumbnailUrl, fit: BoxFit.cover)
                              : const Icon(Icons.play_circle_outline, color: AppColors.primary),
                        ),
                      ),
                      title: Text(
                        'Episode ${ep.episodeNumber}: ${ep.title}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.primary : Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${ep.durationMinutes} Menit',
                        style: AppTypography.metadata.copyWith(fontSize: 11),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.graphic_eq_rounded, color: AppColors.primary)
                          : null,
                      onTap: () => _selectEpisode(ep),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Lembar Pemilih Kualitas Video
  void _showQualitySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Pilih Resolusi Video', style: AppTypography.sectionTitle),
              ),
              const Divider(color: AppColors.border, height: 1),
              ..._availableSources.map((source) {
                final isSelected = _currentSource.url == source.url;
                return ListTile(
                  title: Text(
                    source.serverName ?? source.quality.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    source.quality.label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => _selectQuality(source),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Lembar Pemilih Server Multi-Mirror (Failover Cepat)
  void _showServerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pilih Server Streaming', style: AppTypography.sectionTitle),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              ..._availableSources.asMap().entries.map((entry) {
                final idx = entry.key;
                final source = entry.value;
                final isSelected = _currentSourceIndex == idx;

                return ListTile(
                  tileColor: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surface,
                  leading: Icon(
                    source.isHls ? Icons.wifi_channel_rounded : Icons.flash_on_rounded,
                    color: isSelected ? AppColors.primary : Colors.white60,
                  ),
                  title: Text(
                    source.serverName ?? 'Server ${idx + 1} (${source.quality.label})',
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    source.isHls ? 'HLS Multi-Bitrate (Adaptif)' : 'Direct CDN Ultra Fast',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _switchServer(idx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Lembar Pemilih Subtitle
  void _showSubtitleSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Pilih Subtitle', style: AppTypography.sectionTitle),
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                title: Text(
                  'Nonaktifkan Subtitle',
                  style: TextStyle(
                    color: _selectedSubtitle == null ? AppColors.primary : Colors.white,
                    fontWeight: _selectedSubtitle == null ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                trailing: _selectedSubtitle == null
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                    : null,
                onTap: () => _selectSubtitle(null),
              ),
              ...widget.subtitles.map((track) {
                final isSelected = _selectedSubtitle?.id == track.id;
                return ListTile(
                  title: Text(
                    track.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => _selectSubtitle(track),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
