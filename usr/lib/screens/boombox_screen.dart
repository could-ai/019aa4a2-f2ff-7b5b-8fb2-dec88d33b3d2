import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BoomboxScreen extends StatefulWidget {
  const BoomboxScreen({super.key});

  @override
  State<BoomboxScreen> createState() => _BoomboxScreenState();
}

class _BoomboxScreenState extends State<BoomboxScreen> with TickerProviderStateMixin {
  bool _isPlaying = false;
  double _volume = 0.5;
  int _currentTrackIndex = 0;
  Duration _currentPosition = Duration.zero;
  Timer? _timer;
  
  // Animation controller for speaker pulse
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, String>> _tracks = [
    {'title': 'Billie Jean', 'artist': 'Michael Jackson', 'duration': '4:54'},
    {'title': 'Sweet Child O\' Mine', 'artist': 'Guns N\' Roses', 'duration': '5:56'},
    {'title': 'Bohemian Rhapsody', 'artist': 'Queen', 'duration': '5:55'},
    {'title': 'Smells Like Teen Spirit', 'artist': 'Nirvana', 'duration': '5:01'},
    {'title': 'Eye of the Tiger', 'artist': 'Survivor', 'duration': '4:04'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed && _isPlaying) {
        _pulseController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _pulseController.forward();
        _startTimer();
      } else {
        _pulseController.stop();
        _pulseController.reset();
        _timer?.cancel();
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentPosition += const Duration(seconds: 1);
        // Simple loop for demo purposes
        if (_currentPosition.inMinutes >= 5) {
          _currentPosition = Duration.zero;
          _nextTrack();
        }
      });
    });
  }

  void _nextTrack() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
      _currentPosition = Duration.zero;
    });
    HapticFeedback.lightImpact();
  }

  void _prevTrack() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
      _currentPosition = Duration.zero;
    });
    HapticFeedback.lightImpact();
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = _tracks[_currentTrackIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            // Top Handle / Branding Area
            Container(
              height: 60,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF333333), Color(0xFF111111)],
                ),
              ),
              child: Center(
                child: Text(
                  'SONY',
                  style: TextStyle(
                    fontFamily: 'Roboto', // Fallback to default sans if not available
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // LCD Display
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF444444), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B3A28), // Retro LCD Greenish/Dark
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2B3A28), Color(0xFF1F2B1D)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isPlaying ? 'PLAY' : 'PAUSE',
                                  style: const TextStyle(
                                    color: Color(0xFF8FBC8F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.battery_full,
                                  color: const Color(0xFF8FBC8F).withOpacity(0.7),
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentTrack['title']!,
                              style: const TextStyle(
                                color: Color(0xFF8FBC8F), // LCD Green
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                letterSpacing: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentTrack['artist']!,
                              style: TextStyle(
                                color: const Color(0xFF8FBC8F).withOpacity(0.8),
                                fontSize: 14,
                                fontFamily: 'Courier',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_currentPosition),
                                  style: const TextStyle(color: Color(0xFF8FBC8F)),
                                ),
                                Text(
                                  currentTrack['duration']!,
                                  style: const TextStyle(color: Color(0xFF8FBC8F)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Speakers Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpeaker(),
                        _buildCassetteDeck(),
                        _buildSpeaker(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Controls
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF333333)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Playback Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(Icons.skip_previous, _prevTrack),
                              _buildControlButton(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                _togglePlay,
                                isPrimary: true,
                              ),
                              _buildControlButton(Icons.skip_next, _nextTrack),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Volume Slider
                          Row(
                            children: [
                              const Icon(Icons.volume_mute, color: Colors.grey, size: 20),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFFE53935),
                                    inactiveTrackColor: const Color(0xFF424242),
                                    thumbColor: Colors.white,
                                    overlayColor: const Color(0xFFE53935).withOpacity(0.2),
                                  ),
                                  child: Slider(
                                    value: _volume,
                                    onChanged: _changeVolume,
                                  ),
                                ),
                              ),
                              const Icon(Icons.volume_up, color: Colors.grey, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Footer
            Container(
              height: 20,
              color: const Color(0xFF000000),
              child: Center(
                child: Text(
                  'MEGA BASS',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeaker() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPlaying ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF111111),
              border: Border.all(color: const Color(0xFF444444), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
              gradient: const RadialGradient(
                colors: [Color(0xFF333333), Color(0xFF000000)],
                stops: [0.1, 0.9],
              ),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: const Color(0xFF222222), width: 1),
                ),
                child: CustomPaint(
                  painter: SpeakerGrillPainter(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCassetteDeck() {
    // A small visual representation of a cassette deck or equalizer
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 8,
                height: _isPlaying ? 20.0 + Random().nextInt(30) : 5.0,
                decoration: BoxDecoration(
                  color: _isPlaying ? Colors.redAccent : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isPrimary ? 70 : 50,
        height: isPrimary ? 70 : 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary ? const Color(0xFFE53935) : const Color(0xFF333333),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
            BoxShadow(
              color: isPrimary ? const Color(0xFFFF6B6B) : const Color(0xFF444444),
              blurRadius: 2,
              offset: const Offset(-1, -1),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPrimary
                ? [const Color(0xFFE53935), const Color(0xFFB71C1C)]
                : [const Color(0xFF424242), const Color(0xFF212121)],
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isPrimary ? 32 : 24,
        ),
      ),
    );
  }
}

class SpeakerGrillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.fill;

    const double spacing = 6.0;
    const double radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Only draw if inside the circle
        final center = Offset(size.width / 2, size.height / 2);
        final point = Offset(x, y);
        if ((point - center).distance < size.width / 2 - 4) {
           canvas.drawCircle(point, radius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
