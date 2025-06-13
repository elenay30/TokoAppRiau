import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _loadingProgress;
  late Animation<double> _backgroundFloat;
  late Animation<double> _particleFloat;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _navigateToLogin();
  }

  void _initializeAnimations() {
    // Logo Animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text Animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutBack,
      ),
    );

    // Loading Animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Background Animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    _backgroundFloat = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.linear,
      ),
    );

    // Particle Animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _particleFloat = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.linear,
      ),
    );
  }

  void _startAnimationSequence() {
    // Start logo immediately
    _logoController.forward();

    // Start text with delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });

    // Start loading
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _loadingController.forward();
    });

    // Start background effects
    _backgroundController.repeat();
    _particleController.repeat();
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 4), () async {
      if (mounted) {
        _loadingController.stop();
        _backgroundController.stop();
        _particleController.stop();
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildModernBackground(),
        child: Stack(
          children: [
            _buildBackgroundElements(screenWidth, screenHeight),
            _buildParticleSystem(screenWidth, screenHeight),
            _buildMainContent(screenWidth, screenHeight),
            _buildTopDecoration(screenWidth),
            _buildBottomWave(screenWidth, screenHeight),
            _buildAppInfo(),
          ],
        ),
      ),
    );
  }

  // Modern gradient background seperti Shopee/Tokopedia
  BoxDecoration _buildModernBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF667eea),
          const Color(0xFF64b3f4),
          const Color(0xFF2D7BEE),
          const Color(0xFF1e3c72),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  // Background floating elements
  Widget _buildBackgroundElements(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: _backgroundFloat,
      builder: (context, child) {
        return Stack(
          children: [
            // Large floating circles
            ...List.generate(4, (index) {
              final colors = [
                Colors.white.withOpacity(0.1),
                const Color(0xFFFF8C00).withOpacity(0.08),
                const Color(0xFF00BCD4).withOpacity(0.06),
                const Color(0xFF4CAF50).withOpacity(0.05),
              ];
              
              return Positioned(
                top: screenHeight * (0.1 + index * 0.2) + 
                    math.sin(_backgroundFloat.value + index * 1.5) * 30,
                left: screenWidth * (-0.1 + index * 0.35) + 
                    math.cos(_backgroundFloat.value + index * 1.2) * 25,
                child: Container(
                  width: screenWidth * (0.4 + index * 0.1),
                  height: screenWidth * (0.4 + index * 0.1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[index],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // Modern particle system
  Widget _buildParticleSystem(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: _particleFloat,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final size = 2.0 + (index % 3) * 1.5;
            final opacity = 0.3 + (index % 4) * 0.2;
            
            return Positioned(
              left: screenWidth * (0.1 + (index * 0.04) % 0.8) + 
                  math.sin(_particleFloat.value + index * 0.8) * 40,
              top: screenHeight * (0.1 + (index * 0.05) % 0.8) + 
                  math.cos(_particleFloat.value + index * 0.6) * 30,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Top decoration seperti design modern
  Widget _buildTopDecoration(double screenWidth) {
    return Positioned(
      top: -50,
      right: -50,
      child: AnimatedBuilder(
        animation: _backgroundFloat,
        builder: (context, child) {
          return Transform.rotate(
            angle: _backgroundFloat.value * 0.2,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Bottom wave decoration
  Widget _buildBottomWave(double screenWidth, double screenHeight) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: AnimatedBuilder(
        animation: _backgroundFloat,
        builder: (context, child) {
          return CustomPaint(
            size: Size(screenWidth, 120),
            painter: WavePainter(_backgroundFloat.value),
          );
        },
      ),
    );
  }

  // Main content area
  Widget _buildMainContent(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.05),
          _buildLogo(screenWidth),
          SizedBox(height: screenHeight * 0.04),
          _buildBrandName(),
          SizedBox(height: screenHeight * 0.02),
          _buildTagline(),
          SizedBox(height: screenHeight * 0.08),
          _buildProgressLoader(),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }

  // Logo dengan design modern
  Widget _buildLogo(double screenWidth) {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScale, _logoOpacity, _backgroundFloat]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoOpacity,
          child: ScaleTransition(
            scale: _logoScale,
            child: Container(
              width: screenWidth * 0.32,
              height: screenWidth * 0.32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 15,
                    spreadRadius: -5,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Transform.scale(
                scale: 1.0 + math.sin(_backgroundFloat.value * 0.5) * 0.02,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/LogoTokoKu.png',
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2D7BEE),
                              const Color(0xFF64b3f4),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.store_rounded,
                          size: screenWidth * 0.12,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Brand name dengan typography modern
  Widget _buildBrandName() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textFade, _textSlide]),
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textFade,
            child: Text(
              'TokoKu',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Tagline modern
  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textFade, _textSlide]),
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textFade,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Shop More, Save More',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Progress loader yang modern dan real
  Widget _buildProgressLoader() {
    return AnimatedBuilder(
      animation: _loadingProgress,
      builder: (context, child) {
        final progress = _loadingProgress.value;
        final progressPercent = (progress * 100).round();
        
        return Column(
          children: [
            // Progress text
            Text(
              'Loading... $progressPercent%',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress circle
            Container(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background track
                  Container(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: ProgressTrackPainter(),
                    ),
                  ),
                  
                  // Progress fill
                  Container(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: ModernProgressPainter(progress),
                    ),
                  ),
                  
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$progressPercent%',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // App info di bottom
  Widget _buildAppInfo() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textFade,
        builder: (context, child) {
          return FadeTransition(
            opacity: _textFade,
            child: Column(
              children: [
                Text(
                  'Your Shopping Partner',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Wave painter untuk bottom decoration
class WavePainter extends CustomPainter {
  final double animation;

  WavePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height - 40 + 
          math.sin((x / size.width * 2 * math.pi) + animation) * 20;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Progress track painter
class ProgressTrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.2);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Modern progress painter
class ModernProgressPainter extends CustomPainter {
  final double progress;

  ModernProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Gradient untuk progress
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      colors: [
        Colors.white,
        const Color(0xFFFF8C00),
        const Color(0xFF00BCD4),
        Colors.white,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), 
        radius: size.width / 2
      ),
    );

    // Draw progress arc
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), 
        radius: size.width / 2 - 3
      ),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );

    // Glow effect at progress end
    if (progress > 0) {
      final endAngle = -math.pi / 2 + sweepAngle;
      final endX = size.width / 2 + (size.width / 2 - 3) * math.cos(endAngle);
      final endY = size.height / 2 + (size.width / 2 - 3) * math.sin(endAngle);
      
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawCircle(Offset(endX, endY), 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}