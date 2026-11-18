import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LessonVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const LessonVideoPlayer({super.key, required this.videoUrl});

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;
  double? _dragValue; // posisi slider (ms) saat sedang digeser

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    final controller =
    VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) return; // dispose() sudah membuang controller
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      _controller = null;
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Video tidak dapat dimuat. Periksa koneksi internetmu.';
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _initialize();
  }

  // Pause otomatis saat aplikasi ke background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(VideoPlayerController c) async {
    final v = c.value;
    if (v.isPlaying) {
      await c.pause();
    } else {
      if (v.isCompleted) await c.seekTo(Duration.zero);
      await c.play();
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  Widget _frame(Widget child) => AspectRatio(
    aspectRatio: 16 / 9,
    child: Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: child,
    ),
  );

  Widget _errorContent(String message) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 40),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _frame(const CircularProgressIndicator(color: Colors.white));
    }
    final controller = _controller;
    if (_error != null || controller == null) {
      return _frame(_errorContent(_error ?? 'Video tidak tersedia.'));
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.hasError) {
          return _frame(_errorContent('Video gagal diputar.'));
        }

        final duration = value.duration;
        final maxMs = duration.inMilliseconds > 0
            ? duration.inMilliseconds.toDouble()
            : 1.0;
        final current =
        (_dragValue ?? value.position.inMilliseconds.toDouble())
            .clamp(0.0, maxMs);

        return Column(
          children: [
            Container(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller),
                    if (value.isBuffering)
                      const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    value.isCompleted
                        ? Icons.replay
                        : value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: () => _togglePlay(controller),
                ),
                Text(_fmt(Duration(milliseconds: current.round()))),
                Expanded(
                  child: Slider(
                    value: current,
                    max: maxMs,
                    onChanged: (v) => setState(() => _dragValue = v),
                    onChangeEnd: (v) async {
                      await controller
                          .seekTo(Duration(milliseconds: v.round()));
                      if (mounted) setState(() => _dragValue = null);
                    },
                  ),
                ),
                Text(_fmt(duration)),
                const SizedBox(width: 12),
              ],
            ),
          ],
        );
      },
    );
  }
}