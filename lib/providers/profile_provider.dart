import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  // Data profil default - TETAP SAMA
  String _nama = 'Kelompok 5';
  String _email = 'ezpzgeming@gmail.com';
  String _telepon = '085960652905';
  
  // Path foto profil default - TETAP SAMA
  String _fotoProfilPath = 'assets/images/profile_avatar.png';

  // Firebase instances - BARU
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Loading state untuk Firebase operations - BARU
  bool _isLoading = false;
  String _errorMessage = '';

  // Getter untuk data profil - TETAP SAMA
  String get nama => _nama;
  String get email => _email;
  String get telepon => _telepon;
  String get fotoProfilPath => _fotoProfilPath;

  // Getter baru untuk Firebase - BARU
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Constructor - TAMBAHAN untuk listen auth changes
  ProfileProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadProfileFromFirebase();
      } else {
        // Reset ke default saat logout
        _nama = 'Kelompok 5';
        _email = 'ezpzgeming@gmail.com';
        _telepon = '085960652905';
        _fotoProfilPath = 'assets/images/profile_avatar.png';
        notifyListeners();
      }
    });
  }

  // Load profile dari Firebase - BARU
  Future<void> _loadProfileFromFirebase() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      _isLoading = true;
      notifyListeners();

      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        UserModel user = UserModel.fromFirestore(doc);
        _nama = user.nama;
        _email = user.email;
        _telepon = user.telepon;
        _fotoProfilPath = user.fotoProfilPath ?? 'assets/images/profile_avatar.png';
      } else {
        // Jika user belum ada di Firestore, gunakan data dari Firebase Auth
        User? firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          _nama = firebaseUser.displayName ?? _nama;
          _email = firebaseUser.email ?? _email;
          _fotoProfilPath = firebaseUser.photoURL ?? _fotoProfilPath;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode untuk upload foto profil - LOGIC ASLI TETAP SAMA + Firebase sync
  Future<void> uploadFotoProfil() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Kompresi gambar
      );

      if (pickedFile != null) {
        // Dapatkan direktori dokumen aplikasi - LOGIC ASLI TETAP SAMA
        final appDir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${appDir.path}/profile');
        
        // Buat direktori jika belum ada - LOGIC ASLI TETAP SAMA
        if (!await profileDir.exists()) {
          await profileDir.create(recursive: true);
        }

        // Generate nama file unik - LOGIC ASLI TETAP SAMA
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
        final newPath = '${profileDir.path}/$fileName';

        // Copy file ke direktori profile - LOGIC ASLI TETAP SAMA
        final File newImage = await File(pickedFile.path).copy(newPath);

        // Update path foto profil dengan path absolut - LOGIC ASLI TETAP SAMA
        _fotoProfilPath = newPath;
        
        // Beritahu listener - LOGIC ASLI TETAP SAMA
        notifyListeners();

        // TAMBAHAN: Sync to Firebase
        await _syncToFirebase();
      }
    } catch (e) {
      print('Gagal mengupload foto: $e');
      _errorMessage = 'Gagal mengupload foto: $e';
      notifyListeners();
    }
  }

  // Fungsi untuk generate avatar dari nama - TETAP SAMA PERSIS
  Widget generateAvatar({double size = 70, Color? backgroundColor}) {
    if (nama.isEmpty) {
      return Icon(
        Icons.person, 
        size: size, 
        color: backgroundColor ?? Colors.grey
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          nama[0].toUpperCase(), // Ambil huruf pertama
          style: TextStyle(
            color: Colors.white,
            fontSize: size / 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Metode untuk update profil - LOGIC ASLI TETAP SAMA + Firebase sync
  void updateProfil({
    String? nama, 
    String? email, 
    String? telepon, 
    String? fotoProfilPath
  }) {
    // Update data jika ada perubahan - LOGIC ASLI TETAP SAMA
    if (nama != null) _nama = nama;
    if (email != null) _email = email;
    if (telepon != null) _telepon = telepon;
    if (fotoProfilPath != null) _fotoProfilPath = fotoProfilPath;

    // Beritahu listener - LOGIC ASLI TETAP SAMA
    notifyListeners();

    // TAMBAHAN: Sync to Firebase
    _syncToFirebase();
  }

  // Helper method untuk sync ke Firebase - BARU
  Future<void> _syncToFirebase() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      UserModel user = UserModel(
        id: userId,
        nama: _nama,
        email: _email,
        telepon: _telepon,
        fotoProfilPath: _fotoProfilPath,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(
        user.toFirestore(),
        SetOptions(merge: true)
      );

      // Update Firebase Auth display name jika berubah
      if (_auth.currentUser!.displayName != _nama) {
        await _auth.currentUser!.updateDisplayName(_nama);
      }

    } catch (e) {
      _errorMessage = 'Error syncing to Firebase: $e';
      notifyListeners();
    }
  }

  // Validasi email - TETAP SAMA PERSIS
  bool validasiEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validasi nomor telepon (untuk Indonesia) - TETAP SAMA PERSIS
  bool validasiNomorTelepon(String telepon) {
    final teleponRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$');
    return teleponRegex.hasMatch(telepon);
  }

  // Method tambahan untuk Firebase - BARU
  Future<bool> updateProfileWithValidation({
    String? nama,
    String? email,
    String? telepon,
  }) async {
    // Validasi menggunakan method yang sudah ada
    if (email != null && !validasiEmail(email)) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return false;
    }

    if (telepon != null && !validasiNomorTelepon(telepon)) {
      _errorMessage = 'Format nomor telepon tidak valid';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Update menggunakan method asli
      updateProfil(nama: nama, email: email, telepon: telepon);
      
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message - BARU
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Manual refresh dari Firebase - BARU
  Future<void> refreshProfile() async {
    await _loadProfileFromFirebase();
  }
}