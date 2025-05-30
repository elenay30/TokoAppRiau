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
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  late AnimationController _glowController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  late Animation<double> _logoBounce;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textScale;
  late Animation<double> _loadingRotation;
  late Animation<double> _backgroundFloat;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _particleFloat;
  late Animation<double> _glowIntensity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _navigateToLogin();
  }

  void _initializeAnimations() {
    // Logo animations with multiple effects
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -math.pi, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _logoBounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.6, 1.0, curve: Curves.bounceOut),
      ),
    );

    // Text animations with multiple effects
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.elasticOut,
      ),
    );

    _textScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Loading animation with smooth rotation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _loadingRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOutQuart,
      ),
    );

    // Background floating with sine wave
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _backgroundFloat = Tween<double>(begin: -25, end: 25).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Pulse animation for breathing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Wave animation for dynamic background
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.linear,
      ),
    );

    // Particle floating animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 7000),
      vsync: this,
    );

    _particleFloat = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.linear,
      ),
    );

    // Glow intensity animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _glowIntensity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  void _startAnimationSequence() {
    // Start logo animation immediately with staggered effects
    _logoController.forward();

    // Start text animation with delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      _textController.forward();
    });

    // Start loading animation
    Future.delayed(const Duration(milliseconds: 1800), () {
      _loadingController.repeat();
    });

    // Start continuous animations
    _backgroundController.repeat(reverse: true);
    _waveController.repeat();
    _particleController.repeat();
    
    // Start pulse and glow after logo appears
    Future.delayed(const Duration(milliseconds: 2000), () {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    });
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 4), () async {
      if (mounted) {
        // Stop all animations smoothly
        _loadingController.stop();
        _backgroundController.stop();
        _waveController.stop();
        _particleController.stop();
        _pulseController.stop();
        _glowController.stop();
        
        // Wait a brief moment for animations to settle
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Navigate with proper route replacement
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    // Properly dispose all controllers
    _logoController.dispose();
    _loadingController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Set explicit background color
      body: AnimatedBuilder(
        animation: Listenable.merge([_backgroundFloat, _waveAnimation, _glowIntensity]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  math.sin(_waveAnimation.value) * 0.3,
                  math.cos(_waveAnimation.value) * 0.2,
                ),
                radius: 1.8 + math.sin(_waveAnimation.value * 0.5) * 0.3,
                colors: [
                  Color.lerp(const Color(0xFFF8FAFF), const Color(0xFFE8F4FD), 
                    (_glowIntensity.value * 0.5))!,
                  Color.lerp(const Color(0xFFE8F4FD), const Color(0xFFDCF0FF), 
                    _glowIntensity.value * 0.3)!,
                  Color.lerp(const Color(0xFFDCF0FF), const Color(0xFFF0F8FF), 
                    _glowIntensity.value * 0.4)!,
                  Color.lerp(const Color(0xFFF0F8FF), const Color(0xFFE0EFFF), 
                    _glowIntensity.value * 0.2)!,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Dynamic animated background
                _buildDynamicBackground(screenWidth, screenHeight),
                
                // Floating particles system
                _buildParticleSystem(screenWidth, screenHeight),
                
                // Main content with parallax effect
                Transform.translate(
                  offset: Offset(
                    math.sin(_backgroundFloat.value * 0.1) * 2,
                    math.cos(_backgroundFloat.value * 0.08) * 3,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Super animated logo
                        _buildSuperAnimatedLogo(screenWidth),
                        
                        SizedBox(height: screenHeight * 0.06),
                        
                        // Ultra modern loading indicator
                        _buildUltraModernLoader(),
                        
                        SizedBox(height: screenHeight * 0.08),
                        
                        // Dynamic animated tagline
                        _buildDynamicTagline(),
                      ],
                    ),
                  ),
                ),
                
                // Animated bottom info
                _buildAnimatedBottomInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicBackground(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundFloat, _waveAnimation, _particleFloat]),
      builder: (context, child) {
        return Stack(
          children: [
            // Large morphing orbs with wave motion
            ...List.generate(3, (index) {
              final baseColors = [
                const Color(0xFF2D7BEE),
                const Color(0xFFFF8C00),
                const Color(0xFF00BCD4),
              ];
              
              return Positioned(
                top: screenHeight * (0.1 + index * 0.3) + 
                    math.sin(_waveAnimation.value + index * 2) * 30,
                left: screenWidth * (0.1 + index * 0.3) + 
                    math.cos(_waveAnimation.value + index * 1.5) * 40,
                child: Transform.scale(
                  scale: 1.0 + math.sin(_waveAnimation.value + index) * 0.2,
                  child: Container(
                    width: screenWidth * (0.4 + index * 0.1),
                    height: screenWidth * (0.4 + index * 0.1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          baseColors[index].withOpacity(0.25 * _glowIntensity.value),
                          baseColors[index].withOpacity(0.15 * _glowIntensity.value),
                          baseColors[index].withOpacity(0.05 * _glowIntensity.value),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // Flowing ribbon effects
            ...List.generate(2, (index) {
              return Positioned(
                top: screenHeight * (0.3 + index * 0.4),
                left: -50,
                child: Transform.rotate(
                  angle: math.sin(_waveAnimation.value + index * math.pi) * 0.2,
                  child: Container(
                    width: screenWidth + 100,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF2D7BEE).withOpacity(0.08 * _glowIntensity.value),
                          const Color(0xFFFF8C00).withOpacity(0.06 * _glowIntensity.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildParticleSystem(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: Listenable.merge([_particleFloat, _glowIntensity]),
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final colors = [
              const Color(0xFF2D7BEE),
              const Color(0xFFFF8C00),
              const Color(0xFF00BCD4),
              const Color(0xFF9C27B0),
              const Color(0xFF4CAF50),
            ];
            
            final baseSize = 3.0 + (index % 4) * 2;
            final animatedSize = baseSize * (1 + math.sin(_particleFloat.value + index) * 0.5);
            
            return Positioned(
              left: screenWidth * (0.1 + (index * 0.07) % 0.8) + 
                  math.sin(_particleFloat.value + index * 0.8) * 50,
              top: screenHeight * (0.1 + (index * 0.06) % 0.8) + 
                  math.cos(_particleFloat.value + index * 0.6) * 40,
              child: Transform.scale(
                scale: 0.5 + math.sin(_particleFloat.value + index * 2) * 0.5,
                child: Container(
                  width: animatedSize,
                  height: animatedSize,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length].withOpacity(0.8 * _glowIntensity.value),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[index % colors.length].withOpacity(0.6 * _glowIntensity.value),
                        blurRadius: 15 + math.sin(_particleFloat.value + index) * 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSuperAnimatedLogo(double screenWidth) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoScale, _logoOpacity, _logoRotation, _logoBounce, 
        _pulseAnimation, _glowIntensity, _waveAnimation
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoOpacity,
          child: Transform.scale(
            scale: _pulseAnimation.value * _logoBounce.value,
            child: Transform.rotate(
              angle: _logoRotation.value + math.sin(_waveAnimation.value * 0.5) * 0.05,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.98),
                        Colors.white.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D7BEE).withOpacity(0.4 * _glowIntensity.value),
                        blurRadius: 60 + math.sin(_waveAnimation.value) * 20,
                        spreadRadius: 8,
                        offset: Offset(
                          math.sin(_waveAnimation.value * 0.7) * 5,
                          15 + math.cos(_waveAnimation.value * 0.5) * 5,
                        ),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withOpacity(0.3 * _glowIntensity.value),
                        blurRadius: 40 + math.cos(_waveAnimation.value * 1.2) * 15,
                        spreadRadius: 5,
                        offset: Offset(
                          -8 + math.cos(_waveAnimation.value) * 3,
                          8 + math.sin(_waveAnimation.value * 0.8) * 3,
                        ),
                      ),
                      BoxShadow(
                        color: const Color(0xFF00BCD4).withOpacity(0.2 * _glowIntensity.value),
                        blurRadius: 35,
                        spreadRadius: 3,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2D7BEE).withOpacity(0.08 * _glowIntensity.value),
                          const Color(0xFFFF8C00).withOpacity(0.04 * _glowIntensity.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/LogoTokoKu.png',
                      width: screenWidth * 0.28,
                      height: screenWidth * 0.28,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.28,
                          height: screenWidth * 0.28,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF2D7BEE).withOpacity(0.2 * _glowIntensity.value),
                                const Color(0xFF2D7BEE).withOpacity(0.1 * _glowIntensity.value),
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.store_rounded,
                            size: 70,
                            color: Color.lerp(
                              const Color(0xFF2D7BEE),
                              const Color(0xFFFF8C00),
                              math.sin(_waveAnimation.value) * 0.5 + 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraModernLoader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_loadingRotation, _glowIntensity, _waveAnimation]),
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring with pulsing effect
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D7BEE).withOpacity(0.3 * _glowIntensity.value),
                      blurRadius: 30 + math.sin(_waveAnimation.value * 2) * 10,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF8C00).withOpacity(0.2 * _glowIntensity.value),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
              
              // Multiple rotating rings
              ...List.generate(3, (index) {
                return Transform.rotate(
                  angle: _loadingRotation.value * (1 + index * 0.3) * (index % 2 == 0 ? 1 : -1),
                  child: Container(
                    width: 75 - index * 10.0,
                    height: 75 - index * 10.0,
                    child: CustomPaint(
                      painter: MultiRingLoaderPainter(
                        _loadingRotation.value,
                        index,
                        _glowIntensity.value,
                      ),
                    ),
                  ),
                );
              }),
              
              // Center pulsing dot
              Transform.scale(
                scale: 1.0 + math.sin(_waveAnimation.value * 3) * 0.3,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF8C00),
                        const Color(0xFF2D7BEE),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withOpacity(0.8 * _glowIntensity.value),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicTagline() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _textFade, _textSlide, _textScale, _glowIntensity, _waveAnimation
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textFade,
            child: Transform.scale(
              scale: _textScale.value * (1 + math.sin(_waveAnimation.value * 0.3) * 0.02),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.98),
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.92),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D7BEE).withOpacity(0.2 * _glowIntensity.value),
                      blurRadius: 50 + math.sin(_waveAnimation.value) * 15,
                      spreadRadius: 0,
                      offset: Offset(
                        math.sin(_waveAnimation.value * 0.5) * 3,
                        15 + math.cos(_waveAnimation.value * 0.3) * 5,
                      ),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF8C00).withOpacity(0.15 * _glowIntensity.value),
                      blurRadius: 35,
                      spreadRadius: 0,
                      offset: const Offset(-5, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    width: 2,
                    color: Color.lerp(
                      const Color(0xFF2D7BEE).withOpacity(0.2),
                      const Color(0xFFFF8C00).withOpacity(0.2),
                      math.sin(_waveAnimation.value * 0.5) * 0.5 + 0.5,
                    )!,
                  ),
                ),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'SHOP MORE ',
                            style: GoogleFonts.poppins(
                              color: Color.lerp(
                                const Color(0xFF2D7BEE),
                                const Color(0xFF0066CC),
                                math.sin(_waveAnimation.value * 0.7) * 0.5 + 0.5,
                              ),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF2D7BEE).withOpacity(0.4 * _glowIntensity.value),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          TextSpan(
                            text: 'ECONOMICALLY',
                            style: GoogleFonts.poppins(
                              color: Color.lerp(
                                const Color(0xFFFF8C00),
                                const Color(0xFFFF6600),
                                math.cos(_waveAnimation.value * 0.8) * 0.5 + 0.5,
                              ),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFFFF8C00).withOpacity(0.4 * _glowIntensity.value),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'COMFORTABLY & HAPPILY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Color.lerp(
                          const Color(0xFF2D7BEE),
                          const Color(0xFF0066CC),
                          math.sin(_waveAnimation.value * 0.4) * 0.3 + 0.5,
                        ),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF2D7BEE).withOpacity(0.3 * _glowIntensity.value),
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2D7BEE),
                            const Color(0xFF00BCD4),
                            const Color(0xFFFF8C00),
                            const Color(0xFF9C27B0),
                          ],
                          stops: [
                            0.0,
                            math.sin(_waveAnimation.value * 0.5) * 0.3 + 0.3,
                            math.cos(_waveAnimation.value * 0.7) * 0.3 + 0.7,
                            1.0,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2D7BEE).withOpacity(0.5 * _glowIntensity.value),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBottomInfo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowIntensity, _waveAnimation]),
      builder: (context, child) {
        return Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(
              math.sin(_waveAnimation.value * 0.3) * 2,
              math.cos(_waveAnimation.value * 0.2) * 3,
            ),
            child: Column(
              children: [
                Text(
                  'TokoKu App',
                  style: GoogleFonts.poppins(
                    color: Color.lerp(
                      const Color(0xFF2D7BEE),
                      const Color(0xFFFF8C00),
                      math.sin(_waveAnimation.value * 0.6) * 0.5 + 0.5,
                    ),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF2D7BEE).withOpacity(0.4 * _glowIntensity.value),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600]?.withOpacity(0.8 + _glowIntensity.value * 0.2),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MultiRingLoaderPainter extends CustomPainter {
  final double rotation;
  final int ringIndex;
  final double glowIntensity;

  MultiRingLoaderPainter(this.rotation, this.ringIndex, this.glowIntensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4 - ringIndex * 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final colors = [
      [const Color(0xFF2D7BEE), const Color(0xFF00BCD4), const Color(0xFFFF8C00)],
      [const Color(0xFFFF8C00), const Color(0xFF9C27B0), const Color(0xFF2D7BEE)],
      [const Color(0xFF00BCD4), const Color(0xFF2D7BEE), const Color(0xFFFF8C00)],
    ];

    final gradient = SweepGradient(
      colors: [
        ...colors[ringIndex % colors.length].map((c) => c.withOpacity(0.9 * glowIntensity)),
        colors[ringIndex % colors.length][0].withOpacity(0.3 * glowIntensity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), 
        radius: size.width / 2
      ),
    );

    // Main arc with varying length
    final arcLength = math.pi * (1.5 + math.sin(rotation * 2 + ringIndex) * 0.3);
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), 
        radius: size.width / 2 - 2
      ),
      -math.pi / 2 + rotation * (1 + ringIndex * 0.2),
      arcLength,
      false,
      paint,
    );

    // Secondary smaller arc for depth
    if (ringIndex == 0) {
      paint.strokeWidth = 2;
      paint.shader = LinearGradient(
        colors: [
          const Color(0xFFFF8C00).withOpacity(0.8 * glowIntensity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), 
          radius: size.width / 2
        ),
      );

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), 
          radius: size.width / 2 - 12
        ),
        -math.pi / 2 + rotation * 1.8,
        math.pi * 0.6,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}