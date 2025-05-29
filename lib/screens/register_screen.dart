import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
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

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    String cleaned = value.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 10) {
      return 'Nomor telepon minimal 10 digit';
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

  String? _validateAddress(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 5) {
      return 'Alamat minimal 5 karakter';
    }
    return null;
  }

  // Handle registration - FIXED VERSION
  Future<void> _handleRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    if (!_formKey.currentState!.validate()) {
      _showMessage('Mohon lengkapi semua field yang diperlukan', isError: true);
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      print('📝 Starting registration...');
      
      String trimmedName = _nameController.text.trim();
      String trimmedEmail = _emailController.text.trim();
      String trimmedPhone = _phoneController.text.trim();
      String trimmedAddress = _addressController.text.trim();
      String password = _passwordController.text;

      bool success = await authProvider.registerWithEmailPassword(
        email: trimmedEmail,
        password: password,
        nama: trimmedName,
        telepon: trimmedPhone,
        alamat: trimmedAddress,
      );

      if (!mounted) return;

      if (success) {
        print('✅ Registration successful');
        
        _showMessage('Registrasi berhasil! Akun Anda telah dibuat.', isError: false);
        
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          // SELALU sign out dan arahkan ke login screen setelah registrasi
          await authProvider.signOut();
          Navigator.pushReplacementNamed(
            context, 
            '/login',
            arguments: {
              'email': trimmedEmail,
              'message': 'Akun berhasil dibuat! Silakan login dengan akun baru Anda.'
            }
          );
        }
      } else {
        print('❌ Registration failed');
        String errorMsg = authProvider.errorMessage;
        
        if (errorMsg.contains('berhasil') || errorMsg.contains('coba login')) {
          _showMessage('Akun mungkin sudah berhasil dibuat. Silakan coba login.', isError: false);
          
          await Future.delayed(const Duration(milliseconds: 2000));
          
          if (mounted) {
            // Sign out just in case and go to login
            await authProvider.signOut();
            Navigator.pushReplacementNamed(
              context, 
              '/login',
              arguments: {
                'email': trimmedEmail,
                'message': 'Silakan coba login dengan akun yang baru dibuat.'
              }
            );
          }
        } else {
          if (errorMsg.isEmpty) {
            errorMsg = 'Registrasi gagal, silakan coba lagi';
          }
          _showMessage(errorMsg, isError: true);
        }
      }
    } catch (e) {
      print('❌ Registration exception: $e');
      if (mounted) {
        String errorStr = e.toString().toLowerCase();
        if (errorStr.contains('conversion') || 
            errorStr.contains('parsing') ||
            errorStr.contains('type cast')) {
          _showMessage('Akun mungkin berhasil dibuat. Silakan coba login.', isError: false);
          
          await Future.delayed(const Duration(milliseconds: 2000));
          
          if (mounted) {
            // Sign out just in case and go to login
            await authProvider.signOut();
            Navigator.pushReplacementNamed(
              context, 
              '/login',
              arguments: {
                'email': _emailController.text.trim(),
                'message': 'Silakan coba login dengan akun yang baru dibuat.'
              }
            );
          }
        } else {
          _showMessage('Terjadi kesalahan: ${e.toString()}', isError: true);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  // Show message method
  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    
    Color backgroundColor;
    if (isError) {
      backgroundColor = Colors.red;
    } else {
      backgroundColor = Colors.green;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded, 
              color: primaryColor,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Welcome text
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join Us!',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Create an account to start shopping',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/LogoTokoKu.png',
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.store,
                              size: 50,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Form fields
                  _buildInputField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    icon: Icons.person_outline,
                    validator: _validateName,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInputField(
                    controller: _phoneController,
                    hintText: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInputField(
                    controller: _addressController,
                    hintText: 'Delivery Address (Optional)',
                    icon: Icons.location_on_outlined,
                    validator: _validateAddress,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Create Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: _validatePassword,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Password requirement text
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      'Password must be at least 6 characters',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Create Account Button
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
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
                      onPressed: _isRegistering ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isRegistering
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Simple input field builder
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
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
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            icon: Icon(icon, color: const Color(0xFF2D7BEE)),
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: InputBorder.none,
            errorStyle: GoogleFonts.poppins(fontSize: 12),
            suffixIcon: isPassword
                ? IconButton(
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
                  )
                : null,
          ),
        ),
      ),
    );
  }
}