import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../providers/auth_provider.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({Key? key}) : super(key: key);

  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  // Warna utama dari aplikasi
  final Color _primaryColor = const Color(0xFF2D7BEE);

  // Controller untuk input field
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _teleponController;
  late TextEditingController _alamatController;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUpdatingImage = false;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi controller dengan data dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _namaController = TextEditingController(text: authProvider.userModel?.nama ?? '');
    _emailController = TextEditingController(text: authProvider.userModel?.email ?? '');
    _teleponController = TextEditingController(text: authProvider.userModel?.telepon ?? '');
    _alamatController = TextEditingController(text: authProvider.userModel?.alamat ?? '');
  }

  // Fungsi untuk memilih gambar dengan options
  Future<void> _pilihGambar() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Foto Profil',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromSource(ImageSource.camera);
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromSource(ImageSource.gallery);
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.delete,
                      label: 'Hapus',
                      onTap: () {
                        Navigator.pop(context);
                        _removeProfileImage();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // FIXED: Pick image dan simpan lokal
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      setState(() {
        _isUpdatingImage = true;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        // Save to local app directory
        String localPath = await _saveImageLocally(File(image.path));
        
        setState(() {
          _selectedImage = File(localPath);
        });

        _tampilkanSnackBar('Foto profil dipilih. Jangan lupa simpan perubahan!', isError: false);
      }
    } catch (e) {
      _tampilkanSnackBar('Error memilih gambar: $e');
    } finally {
      setState(() {
        _isUpdatingImage = false;
      });
    }
  }

  // Save image to app's local directory
  Future<String> _saveImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${directory.path}/profile_images');
      
      // Create directory if it doesn't exist
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Generate unique filename
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.firebaseUser?.uid ?? 'user';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = '${userId}_$timestamp$extension';
      
      final localPath = '${profileDir.path}/$fileName';
      
      // Copy file to app directory
      await imageFile.copy(localPath);
      
      return localPath;
    } catch (e) {
      throw Exception('Gagal menyimpan gambar: $e');
    }
  }

  // FIXED: Remove profile image
  Future<void> _removeProfileImage() async {
    try {
      setState(() {
        _isUpdatingImage = true;
      });

      // Clear selected image
      setState(() {
        _selectedImage = null;
      });

      _tampilkanSnackBar('Foto profil dihapus. Jangan lupa simpan perubahan!', isError: false);
    } catch (e) {
      _tampilkanSnackBar('Error menghapus foto: $e');
    } finally {
      setState(() {
        _isUpdatingImage = false;
      });
    }
  }

  // FIXED: Update profile tanpa Firebase Storage
  Future<void> _simpanProfil() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Validasi input
    if (_namaController.text.trim().isEmpty) {
      _tampilkanSnackBar('Nama tidak boleh kosong');
      return;
    }

    if (!_validasiEmail(_emailController.text.trim())) {
      _tampilkanSnackBar('Email tidak valid');
      return;
    }

    if (!_validasiNomorTelepon(_teleponController.text.trim())) {
      _tampilkanSnackBar('Nomor telepon tidak valid');
      return;
    }

    try {
      // Siapkan data update
      String? profileImagePath;
      
      if (_selectedImage != null) {
        // Gunakan path file lokal
        profileImagePath = _selectedImage!.path;
      } else {
        // Pertahankan foto yang sudah ada (jika ada)
        profileImagePath = authProvider.userModel?.fotoProfilPath;
      }

      // Update user model dengan foto profil lokal
      final updatedUser = authProvider.userModel?.copyWith(
        nama: _namaController.text.trim(),
        email: _emailController.text.trim(),
        telepon: _teleponController.text.trim(),
        alamat: _alamatController.text.trim().isEmpty ? null : _alamatController.text.trim(),
        fotoProfilPath: profileImagePath,
      );

      if (updatedUser != null) {
        bool success = await authProvider.updateUserProfile(updatedUser);

        if (success) {
          // Tampilkan konfirmasi
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Profil Diperbarui',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Perubahan profil Anda telah disimpan.',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context); // Kembali ke layar sebelumnya
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(color: _primaryColor),
                  ),
                ),
              ],
            ),
          );
        } else {
          _tampilkanSnackBar(authProvider.errorMessage.isNotEmpty 
              ? authProvider.errorMessage 
              : 'Gagal menyimpan perubahan profil');
        }
      }
    } catch (e) {
      _tampilkanSnackBar('Error: $e');
    }
  }

  // Validasi email lokal
  bool _validasiEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validasi nomor telepon lokal
  bool _validasiNomorTelepon(String phone) {
    // Hapus semua karakter non-digit
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Periksa panjang dan format dasar
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  // Menampilkan pesan kesalahan atau sukses
  void _tampilkanSnackBar(String pesan, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pesan,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profil',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Show loading indicator
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto Profil
                GestureDetector(
                  onTap: _isUpdatingImage ? null : _pilihGambar,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _primaryColor, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: _isUpdatingImage
                              ? const Center(child: CircularProgressIndicator())
                              : _buildProfileImage(authProvider),
                        ),
                      ),
                      if (!_isUpdatingImage)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Input Nama
                _buildInputField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_rounded,
                ),

                const SizedBox(height: 16),

                // Input Email
                _buildInputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Input Nomor Telepon
                _buildInputField(
                  controller: _teleponController,
                  label: 'Nomor Telepon',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                // Input Alamat
                _buildInputField(
                  controller: _alamatController,
                  label: 'Alamat (Opsional)',
                  icon: Icons.location_on_rounded,
                  keyboardType: TextInputType.streetAddress,
                ),

                const SizedBox(height: 32),

                // Tombol Simpan
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: (authProvider.isLoading || _isUpdatingImage) ? null : _simpanProfil,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: (authProvider.isLoading || _isUpdatingImage)
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // FIXED: Build profile image tanpa Firebase Storage
  Widget _buildProfileImage(AuthProvider authProvider) {
    // Prioritas: selectedImage > userModel.fotoProfilPath > avatar generated
    
    if (_selectedImage != null) {
      // Jika ada gambar yang baru dipilih
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _generateAvatar();
        },
      );
    }
    
    String? fotoPath = authProvider.userModel?.fotoProfilPath;
    
    if (fotoPath != null && fotoPath.isNotEmpty) {
      if (fotoPath.startsWith('http')) {
        // URL gambar dari internet (Google profile picture, etc.)
        return Image.network(
          fotoPath,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _generateAvatar();
          },
        );
      } else if (fotoPath.startsWith('assets/')) {
        // Asset gambar
        return Image.asset(
          fotoPath,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return _generateAvatar();
          },
        );
      } else {
        // File lokal
        File imageFile = File(fotoPath);
        if (imageFile.existsSync()) {
          return Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return _generateAvatar();
            },
          );
        } else {
          return _generateAvatar();
        }
      }
    }
    
    // Default: generate avatar
    return _generateAvatar();
  }

  // Generate avatar lokal
  Widget _generateAvatar() {
    String name = _namaController.text.isNotEmpty 
        ? _namaController.text 
        : 'User';
    
    String initials = name.trim()
        .split(' ')
        .map((l) => l.isNotEmpty ? l[0] : '')
        .join()
        .toUpperCase();
    
    if (initials.length > 2) {
      initials = initials.substring(0, 2);
    } else if (initials.isEmpty) {
      initials = "?";
    }
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat input field dengan desain kustom
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _primaryColor,
              size: 22,
            ),
          ),
          hintText: label,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Pembersihan controller
  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
}