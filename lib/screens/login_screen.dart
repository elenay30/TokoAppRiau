import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['email'] != null) {
        _emailController.text = args['email'];
        if (args['message'] != null) {
          _showSuccessSnackBar(args['message']);
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // ENHANCED: Handle login dengan PigeonUserDetails error recovery
  Future<void> _handleLogin() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Mohon isi email dan password dengan benar');
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      print('🔑 Starting login process...');
      
      String trimmedEmail = _emailController.text.trim();
      String password = _passwordController.text;

      print('🔑 Login attempt for: $trimmedEmail');

      bool success = await authProvider.signInWithEmailPassword(
        trimmedEmail,
        password,
      );

      if (!mounted) return;

      if (success) {
        if (authProvider.isLoggedIn && 
            authProvider.firebaseUser != null && 
            authProvider.userModel != null) {
          
          print('✅ Login successful - navigating to main screen');
          await authProvider.debugUserData();
          
          // PERBAIKAN: Pastikan navigation aman
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          print('❌ Login validation failed after authentication');
          _showErrorSnackBar('Login gagal - data pengguna tidak lengkap');
          
          if (authProvider.firebaseUser != null) {
            await authProvider.signOut();
          }
        }
      } else {
        print('❌ Login failed');
        String errorMsg = authProvider.errorMessage;
        
        // SPECIAL HANDLING: Check if this is a PigeonUserDetails "success" error
        if (errorMsg.contains('Login berhasil') || errorMsg.contains('Mengalihkan')) {
          print('🔄 PigeonUserDetails detected - checking auth state...');
          
          // Wait a moment for auth state to stabilize
          await Future.delayed(const Duration(milliseconds: 1500));
          
          // Re-check auth state after the error
          if (authProvider.isLoggedIn && 
              authProvider.firebaseUser != null && 
              authProvider.userModel != null) {
            print('✅ Login actually successful after PigeonUserDetails error');
            await authProvider.debugUserData();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/main');
            }
            return;
          } else {
            print('⚠️ Auth state not ready yet, showing success message');
            _showSuccessSnackBar('Login berhasil! Memuat data...');
            
            // Try one more time after another delay
            await Future.delayed(const Duration(milliseconds: 2000));
            
            if (authProvider.isLoggedIn && 
                authProvider.firebaseUser != null && 
                authProvider.userModel != null) {
              print('✅ Login successful on second check');
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/main');
              }
              return;
            }
          }
        }
        
        if (errorMsg.isEmpty) {
          errorMsg = 'Email atau password salah';
        }
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      print('❌ Login exception: $e');
      if (mounted) {
        // Check if this is PigeonUserDetails error at the top level
        if (e.toString().contains('PigeonUserDetails') || 
            e.toString().contains('List<Object?>') ||
            e.toString().contains('type cast')) {
          
          print('🔄 Top-level PigeonUserDetails error detected');
          _showSuccessSnackBar('Login berhasil! Memuat data...');
          
          // Wait and check auth state
          await Future.delayed(const Duration(milliseconds: 2000));
          
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.isLoggedIn && 
              authProvider.firebaseUser != null && 
              authProvider.userModel != null) {
            print('✅ Login recovered from top-level PigeonUserDetails error');
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/main');
            }
            return;
          } else {
            _showErrorSnackBar('Terjadi kesalahan saat login. Coba lagi.');
          }
        } else {
          _showErrorSnackBar('Terjadi kesalahan tidak terduga: ${e.toString()}');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  // ENHANCED: Handle Google Sign In dengan recovery yang lebih baik
  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    setState(() {
      _isLoggingIn = true;
    });

    try {
      print('📱 Starting Google Sign In from UI...');
      
      // PERBAIKAN: Tambahkan feedback visual
      _showInfoSnackBar('Memulai Google Sign-In...');
      
      bool success = await authProvider.signInWithGoogle();

      if (!mounted) return;

      print('📱 Google Sign In result: $success');
      print('📱 Auth provider state - isLoggedIn: ${authProvider.isLoggedIn}');
      
      if (success && authProvider.isLoggedIn) {
        print('✅ Google Sign In successful - navigating immediately');
        await authProvider.debugUserData();
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        String errorMsg = authProvider.errorMessage;
        print('📱 Error message: "$errorMsg"');
        
        // SPECIAL HANDLING: Check for PigeonUserDetails "success" error in Google Sign In
        if (errorMsg.contains('Login berhasil') || errorMsg.contains('Mengalihkan')) {
          print('🔄 Google PigeonUserDetails detected - checking auth state...');
          
          _showSuccessSnackBar('Login Google berhasil! Memuat data...');
          
          // Wait longer for Google auth to stabilize
          await Future.delayed(const Duration(milliseconds: 3000));
          
          if (authProvider.isLoggedIn && 
              authProvider.firebaseUser != null && 
              authProvider.userModel != null) {
            print('✅ Google login actually successful after PigeonUserDetails error');
            await authProvider.debugUserData();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/main');
            }
            return;
          } else {
            // Try refreshing the auth state
            print('🔄 Attempting to refresh auth state...');
            
            // Check current Firebase user
            if (authProvider.firebaseUser != null) {
              print('📱 Firebase user exists, trying to reload user model...');
              await Future.delayed(const Duration(milliseconds: 2000));
              
              if (authProvider.isLoggedIn) {
                print('✅ Google login successful after refresh');
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/main');
                }
                return;
              }
            }
          }
        }
        
        if (errorMsg.isEmpty) {
          errorMsg = 'Gagal login dengan Google';
        }
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      print('❌ Google Sign In UI exception: $e');
      if (mounted) {
        // Handle PigeonUserDetails error at UI level for Google Sign In
        if (e.toString().contains('PigeonUserDetails') || 
            e.toString().contains('List<Object?>') ||
            e.toString().contains('type cast')) {
          
          print('🔄 Top-level Google PigeonUserDetails error detected');
          _showSuccessSnackBar('Login Google berhasil! Memuat data...');
          
          // Wait longer for Google auth to fully settle
          await Future.delayed(const Duration(milliseconds: 4000));
          
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.isLoggedIn && 
              authProvider.firebaseUser != null && 
              authProvider.userModel != null) {
            print('✅ Google login recovered from top-level PigeonUserDetails error');
            await authProvider.debugUserData();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/main');
            }
            return;
          } else {
            _showErrorSnackBar('Terjadi kesalahan saat login dengan Google. Coba lagi.');
          }
        } else {
          _showErrorSnackBar('Terjadi kesalahan saat login dengan Google');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    String email = _emailController.text.trim();
    
    if (email.isEmpty) {
      _showErrorSnackBar('Masukkan email terlebih dahulu');
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Kirim link reset password ke $email?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Kirim',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      bool success = await authProvider.resetPassword(email);

      if (success) {
        if (mounted) {
          _showSuccessSnackBar(
            'Link reset password telah dikirim ke email $email. Cek inbox dan spam folder.'
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(authProvider.errorMessage);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // PERBAIKAN: Tambahkan info snackbar
  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryColor = const Color(0xFF2D7BEE);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -screenWidth * 0.2,
              right: -screenWidth * 0.2,
              child: Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -screenWidth * 0.15,
              left: -screenWidth * 0.15,
              child: Container(
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8C00).withOpacity(0.05),
                ),
              ),
            ),
            
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      
                      // Welcome text
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back,',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Login to continue shopping!',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.03),
                      
                      // Logo with shadow
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.15),
                                blurRadius: 25,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/LogoTokoKu.png',
                            width: screenWidth * 0.4,
                            height: screenWidth * 0.4,
                            // PERBAIKAN: Tambahkan error handling untuk asset
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: screenWidth * 0.4,
                                height: screenWidth * 0.4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.store,
                                  size: screenWidth * 0.2,
                                  color: primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.04),
                      
                      // Email Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            decoration: InputDecoration(
                              icon: Icon(Icons.person_outline, color: primaryColor),
                              hintText: 'Your Email',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              errorStyle: GoogleFonts.poppins(fontSize: 12),
                            ),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Password Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock_outline, color: primaryColor),
                              hintText: 'Your Password',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              errorStyle: GoogleFonts.poppins(fontSize: 12),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword 
                                      ? Icons.visibility_off_outlined 
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Login Button
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoggingIn ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoggingIn
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Log In',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Or continue with
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Or continue with',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _modernSocialLoginButton(
                            'assets/images/google_icon.png', 
                            'Google',
                            _isLoggingIn ? null : _handleGoogleSignIn,
                            _isLoggingIn,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            ),
                            child: Text(
                              'Register',
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _modernSocialLoginButton(String iconPath, String label, VoidCallback? onPressed, bool isLoading) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2D7BEE),
                ),
              )
            : Image.asset(
                iconPath,
                width: 28,
                height: 28,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade400,
                          Colors.orange.shade400,
                          Colors.yellow.shade400,
                          Colors.green.shade400,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.g_mobiledata,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
        onPressed: onPressed,
      ),
    );
  }
}