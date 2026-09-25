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

    _currentSource = widget.streamSources.isNotEmpty
        ? widget.streamSources.first
        : const StreamSource(
            url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            quality: VideoQuality.q1080p,
          );

    if (widget.subtitles.isNotEmpty) {
      _selectedSubtitle = widget.subtitles.first;
    }

    _initializePlayer();
    _startPeriodicProgressSaver();
  }

  Future<void> _initializePlayer() async {
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
        });
        _resetControlsTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Gagal memutar video. Silakan periksa koneksi atau coba server lain.';
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
    if (_currentSource.quality == source.quality) return;

    final currentPos = _controller?.value.position ?? Duration.zero;
    setState(() {
      _currentSource = source;
    });
    _initializePlayer().then((_) {
      _controller?.seekTo(currentPos);
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _initializePlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
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
              ...widget.streamSources.map((source) {
                final isSelected = _currentSource.quality == source.quality;
                return ListTile(
                  title: Text(
                    source.quality.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
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
