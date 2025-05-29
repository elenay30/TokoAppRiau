import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ProfileService {
  // URL backend (ganti dengan URL sesuai backend Anda)
  static const String _baseUrl = 'https://api.tokoku.com/profile';

  // Simpan data pengguna ke local storage
  Future<void> simpanDataLokal(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  // Ambil data pengguna dari local storage
  Future<UserModel?> ambilDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      return UserModel.fromJson(json.decode(userData));
    }
    
    return null;
  }

  // Update profil ke backend
  Future<UserModel> updateProfil({
    required String id,
    required String nama,
    required String email,
    required String telepon,
    File? fotoProfil,
  }) async {
    try {
      // Buat request multipart untuk mengunggah foto
      var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/update'));
      
      // Tambahkan field teks
      request.fields['id'] = id;
      request.fields['nama'] = nama;
      request.fields['email'] = email;
      request.fields['telepon'] = telepon;

      // Tambahkan foto profil jika ada
      if (fotoProfil != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_profil', fotoProfil.path)
        );
      }

      // Kirim request
      final response = await request.send();
      
      // Baca response
      final responseBody = await response.stream.bytesToString();
      
      // Periksa status response
      if (response.statusCode == 200) {
        // Parse data pengguna dari response
        final userData = json.decode(responseBody);
        final updatedUser = UserModel.fromJson(userData);
        
        // Simpan data ke local storage
        await simpanDataLokal(updatedUser);
        
        return updatedUser;
      } else {
        // Lempar exception jika update gagal
        throw Exception('Gagal memperbarui profil: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Tangani error
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Validasi email
  bool validasiEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validasi nomor telepon (contoh untuk Indonesia)
  bool validasiNomorTelepon(String telepon) {
    final teleponRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$');
    return teleponRegex.hasMatch(telepon);
  }
}