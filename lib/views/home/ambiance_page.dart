
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;

/// 
final AudioPlayer globalPlayer = AudioPlayer();

class AmbiancePage extends StatefulWidget {
  const AmbiancePage({super.key});
  @override
  State<AmbiancePage> createState() => _AmbiancePageState();
}
class _AmbiancePageState extends State<AmbiancePage>
    with TickerProviderStateMixin {
  bool isPlaying = false;
  bool isLoading = false;
  double volume = 0.5;
   String selectedAmbiance = 'Musique calme';
  String? errorMessage;
  late AnimationController _waveController;
   late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  final Map<String, AmbianceData> ambianceFiles = {
    'Musique calme': AmbianceData(
      path: 'assets/audio/calm.mp3',
      icon: Icons.nightlight_round,
      description: 'Ambiance relaxante et apaisante',
      color: Color(0xFF7777EE),
      gradient: [Color(0xFF7777EE), Color(0xFF9999FF), Color(0xFFBBBBFF)],
    ),
    'Café': AmbianceData(
      path: 'assets/audio/cafe.mp3',
      icon: Icons.coffee_rounded,
      description: 'Chaleur et convivialité',
      color: Color(0xFF4A90E2),
      gradient: [Color(0xFF4A90E2), Color(0xFF7AAFFF), Color(0xFFAAD4FF)],
    ),
    'Bibliothèque': AmbianceData(
      path: 'assets/audio/library.mp3',
      icon: Icons.auto_stories,
      description: 'Silence propice à la concentration',
      color: Color(0xFF5B9FED),
      gradient: [Color(0xFF5B9FED), Color(0xFF88C0FF), Color(0xFFB5DEFF)],
    ),
    'Quran': AmbianceData(
      path: 'assets/audio/quran.mp3',
      icon: Icons.spa_rounded,
      description: 'Paix intérieure et spiritualité',
      color: Color(0xFF6BA5E7),
      gradient: [Color(0xFF6BA5E7), Color(0xFF9BC8FF), Color(0xFFCAE7FF)],
    ),
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePlayer();
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  void _initializePlayer() {
    globalPlayer.setLoopMode(LoopMode.one);

    globalPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state.playing;
        isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });

globalPlayer.setVolume(volume);
    isPlaying = globalPlayer.playing;
  }

  Future<void> _playSelectedAmbiance() async {
final path = ambianceFiles[selectedAmbiance]?.path;
    if (path == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await globalPlayer.setAsset(path);
      await globalPlayer.setVolume(volume);
      await globalPlayer.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Erreur: Fichier audio introuvable';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de lire "$selectedAmbiance"'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  Future<void> _pauseAmbiance() async {
    await globalPlayer.pause();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color get _currentColor =>
      ambianceFiles[selectedAmbiance]?.color ?? Color(0xFF7777EE);

  List<Color> get _currentGradient =>
      ambianceFiles[selectedAmbiance]?.gradient ??
      [Color(0xFF7777EE), Color(0xFF9999FF), Color(0xFFBBBBFF)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
              Color(0xFF90CAF9),
              Color(0xFF64B5F6),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingClouds(),
            _buildAnimatedBackground(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    if (errorMessage != null) _buildErrorBanner(),
                    _buildMainCard(),
                    const SizedBox(height: 24),
                    _buildAmbianceSelector(),
                    const SizedBox(height: 24),
                    _buildVolumeControl(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingClouds() {
    return Stack(
      children: [
        Positioned(
          top: 50,
          right: -50,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_waveController.value * 100, 0),
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 150,
          left: -80,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-_waveController.value * 80, 0),
                child: Container(
                  width: 250,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 200,
          right: -100,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 300,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          painter: SkyWavePainter(
            animation: _waveController.value,
            color: _currentColor.withValues(alpha: 0.15),
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _currentColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: _currentColor),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ambiance Sonore",
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.white,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Plongez dans un univers relaxant",
                style: TextStyle(
                  color: Color(0xFF1976D2).withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }Widget _buildMainCard() {
    final ambianceData = ambianceFiles[selectedAmbiance]!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: _currentColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentColor.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 20,
            offset: const Offset(-10, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAnimatedIcon(ambianceData),
          const SizedBox(height: 28),
          Text(
            selectedAmbiance,
            style: TextStyle(
              fontSize: 30,
                fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
              ambianceData.description,
            textAlign: TextAlign.center,
            style: TextStyle(
                  fontSize: 15,
              color: Color(0xFF1976D2).withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _currentGradient),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: _currentColor.withValues(alpha: 0.3 + _glowController.value * 0.3),
                      blurRadius: 15 + _glowController.value * 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPlaying ? Icons.music_note : Icons.music_off,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isPlaying ? "En lecture" : "En pause",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildPlayButton(),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(AmbianceData data) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercles d'onde animés - effet 77
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 200 + (_pulseController.value * 40),
              height: 200 + (_pulseController.value * 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _currentColor.withValues(alpha: 0.25 - _pulseController.value * 0.15),
                  width: 3,
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 180 + (_pulseController.value * 30),
              height: 180 + (_pulseController.value * 30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _currentColor.withValues(alpha: 0.35 - _pulseController.value * 0.2),
                  width: 2,
                ),
              ),
            );
          },
        ),
        // Cercle de rotation - effet 77
        AnimatedBuilder(
          //animat
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      _currentColor.withValues(alpha: 0.4),
                      _currentColor.withValues(alpha: 0.1),
                      _currentColor.withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            );
          },
        ),
        // Icône centrale - effet glassmorphism
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _currentGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withValues(alpha: 0.4 + _glowController.value * 0.2),
                    blurRadius: 30 + _glowController.value * 15,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                color: Colors.white,
                size: 65,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              if (isPlaying) {
                _pauseAmbiance();
              } else {
                _playSelectedAmbiance();
              }
            },
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _currentGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: _currentColor.withValues(alpha: 0.5 + _glowController.value * 0.2),
                  blurRadius: 25 + _glowController.value * 15,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 10,
                  offset: const Offset(-3, -3),
                ),
              ],
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildAmbianceSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _currentColor.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentColor.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_music_rounded, color: Color(0xFF1565C0), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Sélectionnez votre ambiance',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...ambianceFiles.entries.map((entry) {
            final isSelected = selectedAmbiance == entry.key;
            return _buildAmbianceOption(entry.key, entry.value, isSelected);
          }),
        ],
      ),
    );
  }
  Widget _buildAmbianceOption(String name, AmbianceData data, bool isSelected) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              if (isPlaying) await _pauseAmbiance();
              setState(() => selectedAmbiance = name);
              await _playSelectedAmbiance();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.color.withValues(alpha: 0.25),
                    data.color.withValues(alpha: 0.15),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? data.color.withValues(alpha: 0.6)
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: data.gradient)
                    : null,
                color: isSelected ? null : data.color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: data.color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                data.icon,
                color: isSelected ? Colors.white : data.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 17,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: TextStyle(
                      color: Color(0xFF1976D2).withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: data.gradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _currentColor.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentColor.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volume_up_rounded, color: Color(0xFF1565C0), size: 24),
              const SizedBox(width: 12),
              const Text(
                  'Volume',
                style: TextStyle(
                   color: Color(0xFF1565C0),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
               Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _currentGradient),
                   borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: _currentColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '${(volume * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Icon(Icons.volume_mute_rounded, size: 26, color: Color(0xFF1976D2).withValues(alpha: 0.6)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                    thumbColor: Colors.white,
                    activeTrackColor: _currentColor,
                    inactiveTrackColor: _currentColor.withValues(alpha: 0.2),
                    trackHeight: 7,
                    overlayColor: _currentColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: volume,
                    min: 0,
                    max: 1,
                    onChanged: (v) {
                      setState(() => volume = v);
                      globalPlayer.setVolume(volume);
                    },
                  ),
                ),
              ),
              Icon(Icons.volume_up_rounded, size: 26, color: _currentColor),
            ],
          ),
        ],
      ),
    );
  }
}

class AmbianceData {
  final String path;
  final IconData icon;
  final String description;
  final Color color;
  final List<Color> gradient;

  AmbianceData({
    required this.path,
    required this.icon,
    required this.description,
    required this.color,
    required this.gradient,
  });
}

class SkyWavePainter extends CustomPainter {
  final double animation;
  final Color color;

  SkyWavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Première vague
    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);

    for (double i = 0; i < size.width; i++) {
      path1.lineTo(
        i,
        size.height * 0.7 +
            math.sin((i / size.width * 3 * math.pi) + (animation * 2 * math.pi)) * 40,
      );
    }

    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Deuxième vague
    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);

    for (double i = 0; i < size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.8 +
            math.sin((i / size.width * 2 * math.pi) - (animation * 2 * math.pi)) * 30,
      );
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(SkyWavePainter oldDelegate) => oldDelegate.animation != animation;
}