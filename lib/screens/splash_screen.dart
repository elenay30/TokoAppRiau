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
  late AnimationController _shimmerController;

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
  late Animation<double> _shimmerAnimation;

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
      duration: const Duration(milliseconds: 2500),
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
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _logoRotation = Tween<double>(begin: -math.pi * 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 0.9, curve: Curves.elasticOut),
      ),
    );

    _logoBounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.7, 1.0, curve: Curves.bounceOut),
      ),
    );

    // Text animations with smoother effects
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.elasticOut,
      ),
    );

    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Shimmer effect for text
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Loading animation with smoother rotation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Background floating with smoother motion
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    _backgroundFloat = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Pulse animation for breathing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Wave animation for dynamic background
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 4000),
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
      duration: const Duration(milliseconds: 8000),
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
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _glowIntensity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  void _startAnimationSequence() {
    // Start logo animation immediately
    _logoController.forward();

    // Start text animation with delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textController.forward();
        _shimmerController.repeat();
      }
    });

    // Start loading animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _loadingController.repeat();
      }
    });

    // Start continuous animations
    _backgroundController.repeat(reverse: true);
    _waveController.repeat();
    _particleController.repeat();
    
    // Start pulse and glow after logo appears
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        _glowController.repeat(reverse: true);
      }
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
        _shimmerController.stop();
        
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
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnimatedBuilder(
        animation: Listenable.merge([_backgroundFloat, _waveAnimation, _glowIntensity]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  math.sin(_waveAnimation.value) * 0.2,
                  math.cos(_waveAnimation.value) * 0.15,
                ),
                radius: 1.5 + math.sin(_waveAnimation.value * 0.3) * 0.2,
                colors: [
                  const Color(0xFFF8FAFF),
                  const Color(0xFFF0F4FF),
                  const Color(0xFFE8F2FF),
                  const Color(0xFFF5F7FA),
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Enhanced dynamic background
                _buildEnhancedBackground(screenWidth, screenHeight),
                
                // Improved particle system
                _buildImprovedParticleSystem(screenWidth, screenHeight),
                
                // Main content with subtle parallax
                Transform.translate(
                  offset: Offset(
                    math.sin(_backgroundFloat.value * 0.05) * 1,
                    math.cos(_backgroundFloat.value * 0.03) * 2,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enhanced logo
                        _buildEnhancedLogo(screenWidth),
                        
                        SizedBox(height: screenHeight * 0.05),
                        
                        // Improved loading indicator
                        _buildImprovedLoader(),
                        
                        SizedBox(height: screenHeight * 0.07),
                        
                        // Enhanced tagline
                        _buildEnhancedTagline(),
                      ],
                    ),
                  ),
                ),
                
                // Enhanced bottom info
                _buildEnhancedBottomInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedBackground(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundFloat, _waveAnimation, _glowIntensity]),
      builder: (context, child) {
        return Stack(
          children: [
            // Gentle floating orbs
            ...List.generate(4, (index) {
              final colors = [
                const Color(0xFF2D7BEE),
                const Color(0xFFFF8C00),
                const Color(0xFF00BCD4),
                const Color(0xFF4CAF50),
              ];
              
              return Positioned(
                top: screenHeight * (0.1 + index * 0.25) + 
                    math.sin(_waveAnimation.value + index * 1.5) * 25,
                left: screenWidth * (0.05 + index * 0.3) + 
                    math.cos(_waveAnimation.value + index * 1.2) * 30,
                child: Transform.scale(
                  scale: 0.8 + math.sin(_waveAnimation.value + index * 0.7) * 0.15,
                  child: Container(
                    width: screenWidth * (0.25 + index * 0.05),
                    height: screenWidth * (0.25 + index * 0.05),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors[index].withOpacity(0.15 * _glowIntensity.value),
                          colors[index].withOpacity(0.08 * _glowIntensity.value),
                          colors[index].withOpacity(0.03 * _glowIntensity.value),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // Subtle wave patterns
            ...List.generate(3, (index) {
              return Positioned(
                top: screenHeight * (0.2 + index * 0.3),
                left: -100,
                child: Transform.rotate(
                  angle: math.sin(_waveAnimation.value + index * 0.7) * 0.1,
                  child: Container(
                    width: screenWidth + 200,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF2D7BEE).withOpacity(0.04 * _glowIntensity.value),
                          const Color(0xFFFF8C00).withOpacity(0.03 * _glowIntensity.value),
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

  Widget _buildImprovedParticleSystem(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: Listenable.merge([_particleFloat, _glowIntensity]),
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final colors = [
              const Color(0xFF2D7BEE),
              const Color(0xFFFF8C00),
              const Color(0xFF00BCD4),
              const Color(0xFF4CAF50),
              const Color(0xFF9C27B0),
            ];
            
            final baseSize = 2.5 + (index % 3) * 1.5;
            final animatedSize = baseSize * (0.8 + math.sin(_particleFloat.value + index) * 0.3);
            
            return Positioned(
              left: screenWidth * (0.1 + (index * 0.08) % 0.8) + 
                  math.sin(_particleFloat.value + index * 0.6) * 40,
              top: screenHeight * (0.1 + (index * 0.07) % 0.8) + 
                  math.cos(_particleFloat.value + index * 0.4) * 30,
              child: Transform.scale(
                scale: 0.6 + math.sin(_particleFloat.value + index * 1.8) * 0.4,
                child: Container(
                  width: animatedSize,
                  height: animatedSize,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length].withOpacity(0.6 * _glowIntensity.value),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[index % colors.length].withOpacity(0.3 * _glowIntensity.value),
                        blurRadius: 8 + math.sin(_particleFloat.value + index) * 4,
                        spreadRadius: 1,
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

  Widget _buildEnhancedLogo(double screenWidth) {
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
              angle: _logoRotation.value + math.sin(_waveAnimation.value * 0.3) * 0.02,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.98),
                        Colors.white.withOpacity(0.94),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D7BEE).withOpacity(0.3 * _glowIntensity.value),
                        blurRadius: 40 + math.sin(_waveAnimation.value) * 15,
                        spreadRadius: 5,
                        offset: Offset(
                          math.sin(_waveAnimation.value * 0.5) * 3,
                          12 + math.cos(_waveAnimation.value * 0.3) * 4,
                        ),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withOpacity(0.2 * _glowIntensity.value),
                        blurRadius: 30 + math.cos(_waveAnimation.value * 0.8) * 10,
                        spreadRadius: 3,
                        offset: Offset(
                          -5 + math.cos(_waveAnimation.value * 0.7) * 2,
                          6 + math.sin(_waveAnimation.value * 0.6) * 2,
                        ),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2D7BEE).withOpacity(0.05 * _glowIntensity.value),
                          const Color(0xFFFF8C00).withOpacity(0.02 * _glowIntensity.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/LogoTokoKu.png',
                      width: screenWidth * 0.24,
                      height: screenWidth * 0.24,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: screenWidth * 0.24,
                          height: screenWidth * 0.24,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF2D7BEE).withOpacity(0.15 * _glowIntensity.value),
                                const Color(0xFF2D7BEE).withOpacity(0.08 * _glowIntensity.value),
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.store_rounded,
                            size: 60,
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

  Widget _buildImprovedLoader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_loadingRotation, _glowIntensity, _waveAnimation]),
      builder: (context, child) {
        return Container(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D7BEE).withOpacity(0.2 * _glowIntensity.value),
                      blurRadius: 20 + math.sin(_waveAnimation.value * 1.5) * 8,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
              
              // Rotating rings
              ...List.generate(2, (index) {
                return Transform.rotate(
                  angle: _loadingRotation.value * (1 + index * 0.4) * (index % 2 == 0 ? 1 : -1),
                  child: Container(
                    width: 65 - index * 8.0,
                    height: 65 - index * 8.0,
                    child: CustomPaint(
                      painter: EnhancedRingLoaderPainter(
                        _loadingRotation.value,
                        index,
                        _glowIntensity.value,
                      ),
                    ),
                  ),
                );
              }),
              
              // Center pulsing circle for loading
              Transform.scale(
                scale: 1.0 + math.sin(_waveAnimation.value * 2.5) * 0.15,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF8C00),
                        const Color(0xFF2D7BEE),
                        const Color(0xFF00BCD4),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D7BEE).withOpacity(0.6 * _glowIntensity.value),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withOpacity(0.4 * _glowIntensity.value),
                        blurRadius: 16,
                        spreadRadius: 3,
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

  Widget _buildEnhancedTagline() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _textFade, _textSlide, _textScale, _glowIntensity, 
        _waveAnimation, _shimmerAnimation
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textFade,
            child: Transform.scale(
              scale: _textScale.value * (1 + math.sin(_waveAnimation.value * 0.2) * 0.01),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.92),
                      Colors.white.withOpacity(0.88),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D7BEE).withOpacity(0.15 * _glowIntensity.value),
                      blurRadius: 35 + math.sin(_waveAnimation.value) * 10,
                      spreadRadius: 0,
                      offset: Offset(
                        math.sin(_waveAnimation.value * 0.4) * 2,
                        10 + math.cos(_waveAnimation.value * 0.2) * 3,
                      ),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF8C00).withOpacity(0.1 * _glowIntensity.value),
                      blurRadius: 25,
                      spreadRadius: 0,
                      offset: const Offset(-3, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    width: 1.5,
                    color: Color.lerp(
                      const Color(0xFF2D7BEE).withOpacity(0.15),
                      const Color(0xFFFF8C00).withOpacity(0.15),
                      math.sin(_waveAnimation.value * 0.4) * 0.5 + 0.5,
                    )!,
                  ),
                ),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                          end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                          colors: const [
                            Colors.transparent,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'SHOP MORE ',
                              style: GoogleFonts.poppins(
                                color: Color.lerp(
                                  const Color(0xFF2D7BEE),
                                  const Color(0xFF0066CC),
                                  math.sin(_waveAnimation.value * 0.5) * 0.5 + 0.5,
                                ),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF2D7BEE).withOpacity(0.3 * _glowIntensity.value),
                                    blurRadius: 8,
                                    offset: const Offset(0, 1),
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
                                  math.cos(_waveAnimation.value * 0.6) * 0.5 + 0.5,
                                ),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFFF8C00).withOpacity(0.3 * _glowIntensity.value),
                                    blurRadius: 8,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'COMFORTABLY & HAPPILY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Color.lerp(
                          const Color(0xFF2D7BEE),
                          const Color(0xFF0066CC),
                          math.sin(_waveAnimation.value * 0.3) * 0.3 + 0.5,
                        ),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF2D7BEE).withOpacity(0.2 * _glowIntensity.value),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2D7BEE),
                            const Color(0xFFFF8C00),
                            const Color(0xFF00BCD4),
                          ],
                          stops: [
                            0.0,
                            math.sin(_waveAnimation.value * 0.4) * 0.3 + 0.5,
                            1.0,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2D7BEE).withOpacity(0.4 * _glowIntensity.value),
                            blurRadius: 10,
                            spreadRadius: 1,
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

  Widget _buildEnhancedBottomInfo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowIntensity, _waveAnimation]),
      builder: (context, child) {
        return Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(
              math.sin(_waveAnimation.value * 0.2) * 1,
              math.cos(_waveAnimation.value * 0.15) * 2,
            ),
            child: Column(
              children: [
                Text(
                  'TokoKu App',
                  style: GoogleFonts.poppins(
                    color: Color.lerp(
                      const Color(0xFF2D7BEE),
                      const Color(0xFFFF8C00),
                      math.sin(_waveAnimation.value * 0.4) * 0.5 + 0.5,
                    ),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF2D7BEE).withOpacity(0.3 * _glowIntensity.value),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600]?.withOpacity(0.7 + _glowIntensity.value * 0.2),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
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

class EnhancedRingLoaderPainter extends CustomPainter {
  final double rotation;
  final int ringIndex;
  final double glowIntensity;

  EnhancedRingLoaderPainter(this.rotation, this.ringIndex, this.glowIntensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.5 - ringIndex * 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final colors = [
      [const Color(0xFF2D7BEE), const Color(0xFFFF8C00), const Color(0xFF00BCD4)],
      [const Color(0xFFFF8C00), const Color(0xFF4CAF50), const Color(0xFF2D7BEE)],
    ];

    final gradient = SweepGradient(
      colors: [
        ...colors[ringIndex % colors.length].map((c) => c.withOpacity(0.8 * glowIntensity)),
        colors[ringIndex % colors.length][0].withOpacity(0.2 * glowIntensity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), 
        radius: size.width / 2
      ),
    );

    // Main arc with smooth length variation
    final arcLength = math.pi * (1.3 + math.sin(rotation * 1.5 + ringIndex) * 0.2);
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), 
        radius: size.width / 2 - 1.5
      ),
      -math.pi / 2 + rotation * (1 + ringIndex * 0.15),
      arcLength,
      false,
      paint,
    );

    // Additional accent arc
    if (ringIndex == 0) {
      paint.strokeWidth = 1.5;
      paint.shader = LinearGradient(
        colors: [
          const Color(0xFFFF8C00).withOpacity(0.6 * glowIntensity),
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
          radius: size.width / 2 - 8
        ),
        -math.pi / 2 + rotation * 1.6,
        math.pi * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}