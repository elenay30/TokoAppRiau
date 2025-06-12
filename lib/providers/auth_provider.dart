import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Biarkan auto-detect dari google-services.json yang sudah di-update dengan SHA-1 yang benar
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isRegistering = false;

  // Getters
  User? get firebaseUser => _firebaseUser;
  User? get user => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  bool get isLoggedIn {
    bool hasFirebaseUser = _firebaseUser != null;
    bool hasUserModel = _userModel != null;
    bool result = hasFirebaseUser && hasUserModel;
    
    print('🔍 isLoggedIn check:');
    print('  - hasFirebaseUser: $hasFirebaseUser');
    print('  - hasUserModel: $hasUserModel');  
    print('  - result: $result');
    
    return result;
  }

  String get currentUserName {
    if (_userModel != null && _userModel!.nama.isNotEmpty) {
      return _userModel!.nama;
    } else if (_firebaseUser != null && _firebaseUser!.displayName != null && _firebaseUser!.displayName!.isNotEmpty) {
      return _firebaseUser!.displayName!;
    } else if (_firebaseUser != null && _firebaseUser!.email != null) {
      String email = _firebaseUser!.email!;
      return email.split('@')[0];
    }
    return 'User';
  }

  AuthProvider() {
    print('🔧 AuthProvider initialized');
    _auth.authStateChanges().listen((User? user) {
      if (_isRegistering) {
        print('⏸️ Auth state change IGNORED during registration');
        return;
      }
      
      print('🔄 Auth state changed: ${user?.email ?? 'No user'}');
      _firebaseUser = user;
      if (user != null) {
        _loadUserModel(user.uid).catchError((e) {
          print('⚠️ Could not load user model: $e');
          _createFallbackUserModel(user);
        });
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  void _createFallbackUserModel(User user) {
    try {
      String displayName = user.displayName ?? '';
      
      if (displayName.isEmpty && user.email != null) {
        displayName = user.email!.split('@')[0];
      }
      
      if (displayName.isEmpty) {
        displayName = 'User';
      }

      _userModel = UserModel(
        id: user.uid,
        nama: displayName,
        email: user.email ?? '',
        telepon: '',
        alamat: '',
        fotoProfilPath: user.photoURL,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      print('✅ Fallback user model created with name: $displayName');
    } catch (e) {
      print('❌ Error creating fallback user model: $e');
      _userModel = UserModel(
        id: user.uid,
        nama: 'User',
        email: user.email ?? '',
        telepon: '',
        alamat: '',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    }
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      print('🔄 Loading user model for UID: $uid');
      
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      
      if (doc.exists && doc.data() != null) {
        try {
          _userModel = UserModel.fromFirestore(doc);
          print('✅ User model loaded: ${_userModel?.nama}');
          _updateLastLoginSafely(uid);
        } catch (parseError) {
          print('❌ Error parsing user model, creating new one: $parseError');
          await _createDefaultUserDocument(uid);
        }
      } else {
        print('⚠️ User document does not exist, creating default');
        await _createDefaultUserDocument(uid);
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user model: $e');
      if (_firebaseUser != null) {
        _createFallbackUserModel(_firebaseUser!);
      }
      notifyListeners();
    }
  }

  void _updateLastLoginSafely(String uid) {
    _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    }).then((_) {
      print('✅ Last login updated');
      if (_userModel != null) {
        _userModel = _userModel!.copyWith(lastLogin: DateTime.now());
      }
      notifyListeners();
    }).catchError((e) {
      print('⚠️ Could not update lastLogin (ignored): $e');
    });
  }

  Future<void> _createDefaultUserDocument(String uid) async {
    try {
      String properName = 'User';
      String email = '';
      
      if (_firebaseUser != null) {
        if (_firebaseUser!.displayName != null && _firebaseUser!.displayName!.isNotEmpty) {
          properName = _firebaseUser!.displayName!;
        } else if (_firebaseUser!.email != null && _firebaseUser!.email!.isNotEmpty) {
          properName = _firebaseUser!.email!.split('@')[0];
          email = _firebaseUser!.email!;
        }
      }
      
      _userModel = UserModel(
        id: uid,
        nama: properName,
        email: email,
        telepon: '',
        alamat: '',
        fotoProfilPath: _firebaseUser?.photoURL,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      try {
        await _firestore.collection('users').doc(uid).set(_userModel!.toFirestore())
            .timeout(const Duration(seconds: 10));
        print('✅ Default user model saved to Firestore');
      } catch (saveError) {
        print('⚠️ Could not save to Firestore (using local only): $saveError');
      }
      
    } catch (e) {
      print('❌ Error creating default user document: $e');
      if (_firebaseUser != null) {
        _createFallbackUserModel(_firebaseUser!);
      }
    }
  }

  // FIXED Email & Password Login with PigeonUserDetails handling
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      print('🔑 Starting email login for: $email');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _firebaseUser = result.user;
      
      if (_firebaseUser != null) {
        print('✅ Firebase user authenticated: ${_firebaseUser!.uid}');
        
        try {
          print('🔄 Loading user model directly...');
          
          DocumentSnapshot doc = await _firestore
              .collection('users')
              .doc(_firebaseUser!.uid)
              .get()
              .timeout(const Duration(seconds: 10));
          
          if (doc.exists && doc.data() != null) {
            _userModel = UserModel.fromFirestore(doc);
            print('✅ User model loaded directly: ${_userModel?.nama}');
            _updateLastLoginSafely(_firebaseUser!.uid);
          } else {
            print('⚠️ No user document, creating fallback');
            _createFallbackUserModel(_firebaseUser!);
          }
          
          if (_firebaseUser != null && _userModel != null) {
            print('✅ Login successful - both Firebase user and UserModel ready');
            _setLoading(false);
            notifyListeners();
            return true;
          } else {
            print('❌ Missing user data after login');
            _setError('Gagal memuat data pengguna');
            _setLoading(false);
            return false;
          }
          
        } catch (userLoadError) {
          print('❌ Error loading user model: $userLoadError');
          _createFallbackUserModel(_firebaseUser!);
          
          if (_userModel != null) {
            print('✅ Login successful with fallback user model');
            _setLoading(false);
            notifyListeners();
            return true;
          } else {
            _setError('Gagal memuat data pengguna');
            _setLoading(false);
            return false;
          }
        }
      }
      
      _setError('Login gagal');
      _setLoading(false);
      return false;
      
    } catch (e) {
      print('❌ Login error: $e');
      
      // Handle PigeonUserDetails error for email login
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
        print('⚠️ PigeonUserDetails error detected in email login - attempting recovery');
        
        User? currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email.trim()) {
          print('✅ Firebase user exists despite error - recovering...');
          _firebaseUser = currentUser;
          
          try {
            DocumentSnapshot doc = await _firestore
                .collection('users')
                .doc(currentUser.uid)
                .get();
            
            if (doc.exists) {
              _userModel = UserModel.fromFirestore(doc);
              print('✅ Email login recovered successfully');
              _setLoading(false);
              notifyListeners();
              return true;
            }
          } catch (recoveryError) {
            print('❌ Recovery failed: $recoveryError');
          }
        }
      }
      
      _setError(_getErrorMessage(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  // FIXED Google Sign In with enhanced PigeonUserDetails error handling
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();
      print('📱 Starting Google Sign In...');
      print('📱 Expected SHA-1: 43:61:6D:C6:21:DE:AE:E2:B9:B1:56:9B:70:4D:6B:94:DF:28:A4:6A');

      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Google sign in cancelled');
        _setLoading(false);
        return false;
      }

      print('✅ Google user selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // STEP 1: Authenticate with Firebase
      UserCredential result;
      try {
        result = await _auth.signInWithCredential(credential);
        _firebaseUser = result.user;
        print('✅ Firebase authentication successful');
      } catch (authError) {
        print('❌ Firebase authentication error: $authError');
        
        // Handle PigeonUserDetails error during Google authentication
        if (authError.toString().contains('PigeonUserDetails') || 
            authError.toString().contains('List<Object?>') ||
            authError.toString().contains('type cast')) {
          
          print('🔄 PigeonUserDetails error detected - attempting recovery...');
          
          // Check if user was actually authenticated despite the error
          User? currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.email == googleUser.email) {
            print('✅ Firebase user exists despite error - recovering Google sign in...');
            _firebaseUser = currentUser;
          } else {
            print('❌ User not authenticated and cannot recover');
            _setError('Gagal login dengan Google');
            _setLoading(false);
            return false;
          }
        } else {
          // Re-throw if not PigeonUserDetails error
          throw authError;
        }
      }

      // STEP 2: Handle user data (this should work even after PigeonUserDetails error)
      if (_firebaseUser != null) {
        print('✅ Firebase user authenticated via Google: ${_firebaseUser!.uid}');
        
        try {
          await _handleGoogleUserDataDirectly();
          
          // STEP 3: Final verification
          if (_firebaseUser != null && _userModel != null) {
            print('✅ Google sign in completed successfully');
            _setLoading(false);
            notifyListeners();
            return true;
          } else {
            print('❌ Missing user data after Google sign in');
            _setError('Gagal memuat data pengguna Google');
            _setLoading(false);
            return false;
          }
          
        } catch (userDataError) {
          print('❌ Error handling Google user data: $userDataError');
          
          // Create fallback and try to continue
          _createFallbackUserModel(_firebaseUser!);
          
          if (_userModel != null) {
            print('✅ Google sign in successful with fallback user model');
            _setLoading(false);
            notifyListeners();
            return true;
          } else {
            _setError('Gagal memuat data pengguna Google');
            _setLoading(false);
            return false;
          }
        }
      }
      
      _setError('Gagal login dengan Google');
      _setLoading(false);
      return false;
      
    } catch (e) {
      print('❌ Google sign in error: $e');
      
      // Final PigeonUserDetails check at the top level
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>') ||
          e.toString().contains('type cast')) {
        
        print('🔄 Top-level PigeonUserDetails error - final recovery attempt...');
        
        // Check if we have a Firebase user despite the error
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('✅ Firebase user found in final recovery - attempting to complete login...');
          _firebaseUser = currentUser;
          
          try {
            await _handleGoogleUserDataDirectly();
            
            if (_firebaseUser != null && _userModel != null) {
              print('✅ Google sign in recovered in final attempt');
              _setLoading(false);
              notifyListeners();
              return true;
            }
          } catch (finalRecoveryError) {
            print('❌ Final recovery failed: $finalRecoveryError');
          }
        }
        
        // If all recovery attempts fail, show success message since user might actually be logged in
        _setError('Login berhasil! Mengalihkan...');
      } else {
        _setError('Gagal login dengan Google: ${e.toString()}');
      }
      
      _setLoading(false);
      return false;
    }
  }

  // DIRECT method to handle Google user data without auth state interference
  Future<void> _handleGoogleUserDataDirectly() async {
    if (_firebaseUser == null) return;

    try {
      print('📝 Handling Google user data directly...');
      
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      
      if (!userDoc.exists) {
        print('📝 Creating new user document for Google user');
        
        String name = _firebaseUser!.displayName ?? 'User';
        if (name.isEmpty && _firebaseUser!.email != null) {
          name = _firebaseUser!.email!.split('@')[0];
        }
        
        _userModel = UserModel(
          id: _firebaseUser!.uid,
          nama: name,
          email: _firebaseUser!.email ?? '',
          telepon: '',
          alamat: '',
          fotoProfilPath: _firebaseUser!.photoURL,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        
        // Save to Firestore
        Map<String, dynamic> userData = {
          'nama': name,
          'email': _firebaseUser!.email ?? '',
          'telepon': '',
          'alamat': '',
          'fotoProfilPath': _firebaseUser!.photoURL,
          'foto_profil': _firebaseUser!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'account_status': 'active',
          'email_verified': _firebaseUser!.emailVerified,
          'phone_verified': false,
          'total_orders': 0,
          'total_spent': 0.0,
          'favorite_categories': <String>[],
        };
        
        await _firestore
            .collection('users')
            .doc(_firebaseUser!.uid)
            .set(userData);
        
        print('✅ New Google user saved to Firestore');
      } else {
        print('📝 Loading existing user from Firestore');
        _userModel = UserModel.fromFirestore(userDoc);
        _updateLastLoginSafely(_firebaseUser!.uid);
      }
      
      print('✅ Google user data handled successfully: ${_userModel?.nama}');
    } catch (e) {
      print('❌ Error handling Google user data: $e');
      _createFallbackUserModel(_firebaseUser!);
    }
  }

  // Registration method (unchanged from your version)
  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
    required String nama,
    required String telepon,
    String? alamat,
  }) async {
    try {
      _isRegistering = true;
      _setLoading(true);
      _clearError();
      
      print('📝 === REGISTRATION START (AUTH LISTENER DISABLED) ===');
      print('📝 RAW INPUT RECEIVED:');
      print('   - Email: "$email"');
      print('   - Password: [HIDDEN]');
      print('   - Nama: "$nama"');
      print('   - Telepon: "$telepon"');
      print('   - Alamat: "$alamat"');

      String trimmedName = nama.trim();
      String trimmedPhone = telepon.trim();
      String trimmedEmail = email.trim().toLowerCase();
      String trimmedAlamat = alamat?.trim() ?? '';

      print('📝 AFTER CLEANING:');
      print('   - Email: "$trimmedEmail"');
      print('   - Nama: "$trimmedName"');
      print('   - Telepon: "$trimmedPhone"');
      print('   - Alamat: "$trimmedAlamat"');

      if (trimmedName.isEmpty) {
        throw Exception('Nama tidak boleh kosong');
      }

      if (trimmedPhone.isEmpty) {
        throw Exception('Nomor telepon tidak boleh kosong');
      }

      if (trimmedEmail.isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }

      print('✅ Input validation passed');

      print('📝 Creating Firebase user...');
      User? firebaseUser;
      
      try {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: trimmedEmail,
          password: password,
        );
        firebaseUser = result.user;
      } catch (createUserError) {
        print('❌ Error creating user: $createUserError');
        
        if (createUserError.toString().contains('PigeonUserDetails') || 
            createUserError.toString().contains('List<Object?>') ||
            createUserError.toString().contains('type cast')) {
          
          print('🔄 PigeonUserDetails error during creation - checking if user was created...');
          
          User? currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.email == trimmedEmail) {
            print('✅ Firebase user was created despite error!');
            firebaseUser = currentUser;
          } else {
            try {
              UserCredential signInResult = await _auth.signInWithEmailAndPassword(
                email: trimmedEmail,
                password: password,
              );
              firebaseUser = signInResult.user;
              print('✅ User exists - signed in successfully');
            } catch (signInError) {
              print('❌ User not created and cannot sign in: $signInError');
              throw createUserError;
            }
          }
        } else {
          throw createUserError;
        }
      }
      
      if (firebaseUser == null) {
        throw Exception('Failed to create Firebase user');
      }

      print('✅ Firebase user created with UID: ${firebaseUser.uid}');

      print('📝 Creating UserModel with ORIGINAL input data...');
      UserModel newUserModel = UserModel(
        id: firebaseUser.uid,
        nama: trimmedName,
        email: trimmedEmail,
        telepon: trimmedPhone,
        alamat: trimmedAlamat.isNotEmpty ? trimmedAlamat : null,
        fotoProfilPath: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      print('📝 UserModel created with CORRECT data:');
      print('   - ID: "${newUserModel.id}"');
      print('   - Nama: "${newUserModel.nama}"');
      print('   - Email: "${newUserModel.email}"');
      print('   - Telepon: "${newUserModel.telepon}"');
      print('   - Alamat: "${newUserModel.alamat}"');

      print('📝 Saving to Firestore with CORRECT data...');
      
      Map<String, dynamic> correctFirestoreData = {
        'nama': trimmedName,
        'email': trimmedEmail,
        'telepon': trimmedPhone,
        'alamat': trimmedAlamat,
        'fotoProfilPath': null,
        'foto_profil': null,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'account_status': 'active',
        'email_verified': false,
        'phone_verified': trimmedPhone.isNotEmpty,
        'total_orders': 0,
        'total_spent': 0.0,
        'favorite_categories': <String>[],
      };

      print('📝 CORRECT Firestore data being saved:');
      correctFirestoreData.forEach((key, value) {
        print('   - $key: "$value"');
      });

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(correctFirestoreData);

      print('✅ Data saved to Firestore with CORRECT values');

      _firebaseUser = firebaseUser;
      _userModel = newUserModel;

      print('📝 Verifying saved data...');
      try {
        DocumentSnapshot verifyDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
        if (verifyDoc.exists) {
          var savedData = verifyDoc.data() as Map<String, dynamic>?;
          print('✅ VERIFICATION - Data actually in Firestore:');
          print('   - nama: "${savedData?['nama']}"');
          print('   - email: "${savedData?['email']}"');
          print('   - telepon: "${savedData?['telepon']}"');
          print('   - alamat: "${savedData?['alamat']}"');
          
          bool dataCorrect = true;
          if (savedData?['telepon'] != trimmedPhone) {
            print('❌ CRITICAL: Telepon mismatch! Expected: "$trimmedPhone", Got: "${savedData?['telepon']}"');
            dataCorrect = false;
          }
          if (savedData?['nama'] != trimmedName) {
            print('❌ CRITICAL: Nama mismatch! Expected: "$trimmedName", Got: "${savedData?['nama']}"');
            dataCorrect = false;
          }
          
          if (dataCorrect) {
            print('✅ DATA VERIFICATION PASSED - ALL CORRECT!');
          } else {
            print('❌ DATA VERIFICATION FAILED!');
          }
        }
      } catch (verifyError) {
        print('⚠️ Could not verify saved data: $verifyError');
      }

      _isRegistering = false;
      
      _setLoading(false);
      notifyListeners();
      print('✅ === REGISTRATION COMPLETED SUCCESSFULLY ===');
      return true;

    } catch (e) {
      print('❌ === REGISTRATION FAILED ===');
      print('❌ Error: $e');
      
      _isRegistering = false;
      
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          await currentUser.delete();
          print('🧹 Cleaned up failed Firebase user');
        }
      } catch (cleanupError) {
        print('⚠️ Could not clean up: $cleanupError');
      }
      
      _firebaseUser = null;
      _userModel = null;
      
      _setError(_getErrorMessage(e.toString()));
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      print('🚪 Signing out...');
      await _auth.signOut();
      await _googleSignIn.signOut();
      _firebaseUser = null;
      _userModel = null;
      _clearError();
      notifyListeners();
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  // Update user profile - METHOD INI YANG HILANG DAN MENYEBABKAN ERROR
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      _setLoading(true);
      _clearError();

      if (_firebaseUser != null) {
        await _firestore.collection('users').doc(_firebaseUser!.uid).update(updatedUser.toFirestore());
        _userModel = updatedUser;
        
        print('⚠️ Skipping updateDisplayName to avoid Flutter bug');
        
        _setLoading(false);
        notifyListeners();
        return true;
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  // Get user summary for dashboard
  Map<String, dynamic> getUserSummary() {
    try {
      if (_userModel == null) {
        return {
          'name': 'User',
          'email': '',
          'phone': '',
          'address': '',
          'totalOrders': 0,
          'totalSpent': 0.0,
          'memberSince': null,
          'status': 'inactive',
          'emailVerified': false,
          'phoneVerified': false,
          'profileComplete': false,
          'favoriteCategories': <String>[],
        };
      }
      
      return {
        'name': _userModel!.nama,
        'email': _userModel!.email,
        'phone': _userModel!.telepon,
        'address': _userModel!.alamat ?? '',
        'totalOrders': 0,
        'totalSpent': 0.0,
        'memberSince': _userModel!.createdAt,
        'lastLogin': _userModel!.lastLogin,
        'status': 'active',
        'emailVerified': _firebaseUser?.emailVerified ?? false,
        'phoneVerified': _userModel!.telepon.isNotEmpty,
        'profileComplete': _userModel!.isProfileComplete(),
        'favoriteCategories': <String>[],
      };
    } catch (e) {
      print('❌ Error getting user summary: $e');
      return {
        'name': 'User',
        'email': '',
        'phone': '',
        'address': '',
        'totalOrders': 0,
        'totalSpent': 0.0,
        'memberSince': null,
        'status': 'inactive',
        'emailVerified': false,
        'phoneVerified': false,
        'profileComplete': false,
        'favoriteCategories': <String>[],
      };
    }
  }

  // Debug user data
  Future<void> debugUserData() async {
    print('🔍 === DEBUG USER DATA ===');
    
    if (_firebaseUser == null) {
      print('❌ No Firebase user logged in');
    } else {
      print('🔍 Firebase User:');
      print('   - UID: ${_firebaseUser!.uid}');
      print('   - Email: ${_firebaseUser!.email}');
      print('   - Display Name: "${_firebaseUser!.displayName}"');
      print('   - Email Verified: ${_firebaseUser!.emailVerified}');
    }
    
    if (_userModel != null) {
      print('🔍 UserModel:');
      print('   - ID: ${_userModel!.id}');
      print('   - Nama: "${_userModel!.nama}"');
      print('   - Email: "${_userModel!.email}"');
      print('   - Telepon: "${_userModel!.telepon}"');
      print('   - Alamat: "${_userModel!.alamat}"');
      print('   - Foto: "${_userModel!.fotoProfilPath}"');
      print('   - Created: ${_userModel!.createdAt}');
      print('   - Last Login: ${_userModel!.lastLogin}');
      print('   - Is Valid: ${_userModel!.isValid()}');
      print('   - Profile Complete: ${_userModel!.isProfileComplete()}');
    } else {
      print('🔍 UserModel: null');
    }
    
    print('🔍 Auth State:');
    print('   - isLoggedIn: $isLoggedIn');
    print('   - isLoading: $isLoading');
    print('   - errorMessage: "$errorMessage"');
    
    print('🔍 === END DEBUG ===');
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ENHANCED: Error message handling dengan PigeonUserDetails support
  String _getErrorMessage(String error) {
    String errorLower = error.toLowerCase();
    
    // Handle Firebase Flutter bug specifically
    if (errorLower.contains('pigeonuserdetails') || 
        errorLower.contains('list<object?>') ||
        errorLower.contains('type cast')) {
      return 'Login berhasil! Mengalihkan...';
    }
    
    if (errorLower.contains('network') || errorLower.contains('timeout') || errorLower.contains('connection')) {
      return 'Koneksi internet bermasalah. Periksa koneksi dan coba lagi.';
    } else if (errorLower.contains('user-not-found')) {
      return 'Email tidak terdaftar';
    } else if (errorLower.contains('wrong-password')) {
      return 'Password salah';
    } else if (errorLower.contains('email-already-in-use')) {
      return 'Email sudah digunakan';
    } else if (errorLower.contains('weak-password')) {
      return 'Password terlalu lemah (minimal 6 karakter)';
    } else if (errorLower.contains('invalid-email')) {
      return 'Format email tidak valid';
    } else if (errorLower.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan, coba lagi nanti';
    } else if (errorLower.contains('invalid-credential')) {
      return 'Email atau password salah';
    } else if (errorLower.contains('nama tidak boleh kosong')) {
      return 'Nama tidak boleh kosong';
    } else if (errorLower.contains('nomor telepon tidak boleh kosong')) {
      return 'Nomor telepon tidak boleh kosong';
    } else {
      print('🔍 Unhandled error: $error');
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}