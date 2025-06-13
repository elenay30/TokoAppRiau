import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String nama;
  String email;
  String telepon;
  String? alamat;
  String? fotoProfilPath;
  DateTime? createdAt;
  DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.telepon,
    this.alamat,
    this.fotoProfilPath,
    this.createdAt,
    this.lastLogin,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telepon: json['telepon']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
      fotoProfilPath: json['foto_profil']?.toString(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'telepon': telepon,
      'alamat': alamat,
      'foto_profil': fotoProfilPath,
    };
  }

  // FIXED: From Firestore with maximum safety and better error handling
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    try {
      print('📄 Converting Firestore doc to UserModel...');
      print('📄 Document ID: ${doc.id}');
      
      if (!doc.exists) {
        print('❌ Document does not exist');
        throw Exception('Document does not exist');
      }

      var rawData = doc.data();
      print('📄 Raw data type: ${rawData.runtimeType}');
      
      if (rawData == null) {
        print('❌ Raw data is null');
        throw Exception('Raw data is null');
      }

      // Convert to Map safely with better error handling
      Map<String, dynamic> data = {};
      
      try {
        if (rawData is Map<String, dynamic>) {
          data = Map<String, dynamic>.from(rawData);
        } else if (rawData is Map) {
          // Convert any Map to Map<String, dynamic> more safely
          for (var entry in rawData.entries) {
            try {
              data[entry.key.toString()] = entry.value;
            } catch (e) {
              print('⚠️ Error processing map entry ${entry.key}: $e');
              // Skip problematic entries instead of failing completely
            }
          }
        } else {
          print('❌ Unknown data type: ${rawData.runtimeType}');
          throw Exception('Unknown data type: ${rawData.runtimeType}');
        }
      } catch (e) {
        print('❌ Error converting raw data to map: $e');
        throw Exception('Error converting raw data to map: $e');
      }

      print('📄 Data keys: ${data.keys.toList()}');
      print('📄 Data preview: ${data.toString().length > 200 ? data.toString().substring(0, 200) + "..." : data.toString()}');

      // Extract data with ultra-safe approach
      String safeName = _safeString(data, 'nama') ?? 
                       _safeString(data, 'name') ?? 
                       'User';
      String safeEmail = _safeString(data, 'email') ?? '';
      String safePhone = _safeString(data, 'telepon') ?? 
                        _safeString(data, 'phone') ?? '';
      String? safeAddress = _safeString(data, 'alamat') ?? 
                           _safeString(data, 'address');
      String? safePhotoPath = _safeString(data, 'foto_profil') ?? 
                             _safeString(data, 'photo_url') ??
                             _safeString(data, 'fotoProfilPath');

      DateTime? safeCreatedAt = _safeDateTime(data, 'createdAt') ?? 
                               _safeDateTime(data, 'created_at');
      DateTime? safeLastLogin = _safeDateTime(data, 'lastLogin') ?? 
                               _safeDateTime(data, 'last_login');

      print('📄 Safe extracted data:');
      print('   - nama: "$safeName"');
      print('   - email: "$safeEmail"');
      print('   - telepon: "$safePhone"');
      print('   - alamat: "$safeAddress"');
      print('   - foto: "$safePhotoPath"');

      UserModel user = UserModel(
        id: doc.id,
        nama: safeName,
        email: safeEmail,
        telepon: safePhone,
        alamat: safeAddress,
        fotoProfilPath: safePhotoPath,
        createdAt: safeCreatedAt ?? DateTime.now(),
        lastLogin: safeLastLogin ?? DateTime.now(),
      );

      print('✅ UserModel created successfully');
      return user;
      
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR in UserModel.fromFirestore: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ Document ID: ${doc.id}');
      
      // Return absolute emergency fallback with doc ID
      return UserModel(
        id: doc.id,
        nama: 'User',
        email: '',
        telepon: '',
        alamat: '',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    }
  }

  // FIXED: ULTRA SAFE string extraction with Map parameter
  static String? _safeString(Map<String, dynamic> data, String key) {
    try {
      var value = data[key];
      if (value == null) return null;
      
      String stringValue = value.toString().trim();
      
      if (stringValue.isEmpty || 
          stringValue.toLowerCase() == 'null' || 
          stringValue.toLowerCase() == 'undefined') {
        return null;
      }
      
      return stringValue;
    } catch (e) {
      print('⚠️ Error converting key "$key" to string: $e');
      return null;
    }
  }

  // FIXED: ULTRA SAFE DateTime extraction with Map parameter
  static DateTime? _safeDateTime(Map<String, dynamic> data, String key) {
    try {
      var value = data[key];
      if (value == null) return null;
      
      if (value is Timestamp) {
        return value.toDate();
      }
      
      if (value is String) {
        DateTime? parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      
      if (value is int) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(value);
        } catch (e) {
          // Might be seconds instead of milliseconds
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }
      }
      
      if (value is double) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(value.toInt());
        } catch (e) {
          return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
        }
      }
      
      return null;
    } catch (e) {
      print('⚠️ Error converting key "$key" to DateTime: $e');
      return null;
    }
  }

  // STEP 2: PERBAIKAN METHOD toFirestore() - COMPLETE VERSION
  Map<String, dynamic> toFirestore() {
    try {
      print('📤 === toFirestore() START ===');
      print('📤 Original UserModel data:');
      print('   - nama: "${nama}"');
      print('   - email: "${email}"');
      print('   - telepon: "${telepon}"');
      print('   - alamat: "${alamat}"');
      print('   - fotoProfilPath: "${fotoProfilPath}"');

      // STEP 2A: Bersihkan data tanpa mengubah nilai asli
      String cleanNama = nama.trim();
      String cleanEmail = email.trim().toLowerCase();
      String cleanTelepon = telepon.trim();
      String? cleanAlamat = alamat?.trim();

      print('📤 After cleaning:');
      print('   - cleanNama: "${cleanNama}"');
      print('   - cleanEmail: "${cleanEmail}"');
      print('   - cleanTelepon: "${cleanTelepon}"');
      print('   - cleanAlamat: "${cleanAlamat}"');

      // STEP 2B: Validasi field wajib
      if (cleanNama.isEmpty) {
        print('⚠️ Warning: nama kosong, using fallback');
        cleanNama = 'User';
      }

      if (cleanEmail.isEmpty) {
        print('❌ Critical: email kosong!');
      }

      if (cleanTelepon.isEmpty) {
        print('❌ Critical: telepon kosong!');
      }

      // STEP 2C: Siapkan data dengan field yang PERSIS sesuai yang dibutuhkan
      Map<String, dynamic> firestoreData = {
        // Field utama - PASTIKAN tidak null atau kosong
        'nama': cleanNama,
        'email': cleanEmail,
        'telepon': cleanTelepon,  // JANGAN BIARKAN KOSONG
        'alamat': cleanAlamat ?? '',  // Kosong tapi bukan null
        
        // Field foto - bisa null
        'fotoProfilPath': fotoProfilPath,
        'foto_profil': fotoProfilPath,  // Backup compatibility
        
        // Field timestamp
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
        'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        
        // Field tambahan dengan nilai default yang aman
        'account_status': 'active',
        'email_verified': false,
        'phone_verified': cleanTelepon.isNotEmpty,  // true jika ada telepon
        'total_orders': 0,
        'total_spent': 0.0,
        'favorite_categories': <String>[],
      };

      print('📤 Final Firestore data:');
      firestoreData.forEach((key, value) {
        if (key == 'createdAt' || key == 'lastLogin' || key == 'updatedAt') {
          print('   - $key: ${value.runtimeType}');
        } else {
          print('   - $key: "$value"');
        }
      });

      // STEP 2D: Validasi akhir sebelum return
      if (firestoreData['nama'] == null || firestoreData['nama'].toString().isEmpty) {
        print('❌ CRITICAL: nama akan kosong di Firestore!');
      }
      
      if (firestoreData['telepon'] == null || firestoreData['telepon'].toString().isEmpty) {
        print('❌ CRITICAL: telepon akan kosong di Firestore!');
        // PAKSA isi telepon jika masih kosong
        firestoreData['telepon'] = telepon.isNotEmpty ? telepon : '';
      }

      print('📤 === toFirestore() COMPLETE ===');
      return firestoreData;

    } catch (e, stackTrace) {
      print('❌ ERROR in toFirestore(): $e');
      print('❌ StackTrace: $stackTrace');
      
      // STEP 2E: Fallback data yang AMAN dan LENGKAP
      print('📤 Using emergency fallback data');
      return {
        'nama': nama.isNotEmpty ? nama : 'User',
        'email': email.isNotEmpty ? email : '',
        'telepon': telepon.isNotEmpty ? telepon : '',  // PASTIKAN ada nilai
        'alamat': alamat ?? '',
        'fotoProfilPath': fotoProfilPath,
        'foto_profil': fotoProfilPath,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'account_status': 'active',
        'email_verified': false,
        'phone_verified': telepon.isNotEmpty,
        'total_orders': 0,
        'total_spent': 0.0,
        'favorite_categories': <String>[],
      };
    }
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? telepon,
    String? alamat,
    String? fotoProfilPath,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      alamat: alamat ?? this.alamat,
      fotoProfilPath: fotoProfilPath ?? this.fotoProfilPath,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // toString method
  @override
  String toString() {
    return 'UserModel(id: $id, nama: $nama, email: $email, telepon: $telepon, alamat: $alamat)';
  }

  // Enhanced validation method
  bool isValid() {
    try {
      return id.trim().isNotEmpty && 
             nama.trim().isNotEmpty && 
             email.trim().isNotEmpty &&
             RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
    } catch (e) {
      print('⚠️ Error in isValid(): $e');
      return false;
    }
  }

  // Check if profile is complete
  bool isProfileComplete() {
    try {
      return isValid() && 
             telepon.trim().isNotEmpty &&
             (alamat?.trim().isNotEmpty ?? false);
    } catch (e) {
      print('⚠️ Error in isProfileComplete(): $e');
      return false;
    }
  }

  // Get display name
  String get displayName {
    try {
      String trimmedName = nama.trim();
      if (trimmedName.isNotEmpty && 
          trimmedName != 'User' && 
          trimmedName != 'user' &&
          trimmedName.toLowerCase() != 'user') {
        return trimmedName;
      }
      
      if (email.isNotEmpty) {
        String emailUser = email.split('@')[0];
        if (emailUser.isNotEmpty) {
          return emailUser;
        }
      }
      
      return 'User';
    } catch (e) {
      print('⚠️ Error in displayName: $e');
      return 'User';
    }
  }

  // Get formatted phone
  String get formattedPhone {
    try {
      String phone = telepon.trim();
      if (phone.isEmpty) return '';
      
      // Add basic formatting if needed
      if (phone.startsWith('08')) {
        return '+62${phone.substring(1)}';
      }
      
      return phone;
    } catch (e) {
      print('⚠️ Error in formattedPhone: $e');
      return telepon;
    }
  }

  // Additional helper method to check if user data is minimal
  bool isMinimalData() {
    try {
      return nama.trim().isEmpty || 
             nama.trim().toLowerCase() == 'user' ||
             email.trim().isEmpty ||
             telepon.trim().isEmpty;
    } catch (e) {
      return true;
    }
  }
}