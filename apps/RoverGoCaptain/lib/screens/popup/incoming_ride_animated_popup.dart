import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class IncomingRideAnimatedPopup extends StatefulWidget {
  final String captainName;
  final String pickupAddress;
  final Duration duration;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTimeout;
  final bool beepEnabled;

  const IncomingRideAnimatedPopup({
    super.key,
    required this.captainName,
    required this.pickupAddress,
    required this.onAccept,
    required this.onReject,
    required this.onTimeout,
    this.duration = const Duration(seconds: 15),
    this.beepEnabled = true,
  });

  @override
  State<IncomingRideAnimatedPopup> createState() =>
      _IncomingRideAnimatedPopupState();
}

class _IncomingRideAnimatedPopupState extends State<IncomingRideAnimatedPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final AudioPlayer _audioPlayer;
  Timer? _secondTimer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();

    _secondsLeft = widget.duration.inSeconds;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _audioPlayer = AudioPlayer();

    // Start countdown animation
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onTimeout();
      }
    });

    // Tick every second
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsed = (_controller.value * widget.duration.inSeconds).floor();
      final left = widget.duration.inSeconds - elapsed;

      if (left != _secondsLeft && mounted) {
        setState(() => _secondsLeft = left);

        if (widget.beepEnabled && left > 0) {
          _playBeep();
        }
      }

      if (left <= 0) timer.cancel();
    });
  }

  Future<void> _playBeep() async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/beep.mp3'),
        volume: 1.0,
      );
    } catch (_) {
      // ignore if missing asset
    }
  }

  void _onTimeout() {
    if (!mounted) return;
    widget.onTimeout();
  }

  void _onAccept() {
    if (!mounted) return;
    widget.onAccept();
  }

  void _onReject() {
    if (!mounted) return;
    widget.onReject();
  }

  @override
  void dispose() {
    _secondTimer?.cancel();
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      widget.captainName.isNotEmpty
                          ? widget.captainName[0].toUpperCase()
                          : 'R',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.captainName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.pickupAddress,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Countdown circle
              SizedBox(
                height: 140,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    final progress = 1 - _controller.value;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 10,
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_secondsLeft',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'seconds',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onAccept,
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
