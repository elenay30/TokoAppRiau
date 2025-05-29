// File: lib/screens/setting_screen.dart
import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Menggunakan AuthProvider langsung

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2D7BEE);
    final secondaryColor = const Color(0xFFFF8C00);

    // Menggunakan Consumer untuk AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Jika pengguna belum login, tampilkan UI loading atau pesan
        // Ini seharusnya sudah dihandle di MainScreen, tapi sebagai fallback
        if (!authProvider.isLoggedIn) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text('Settings', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Memuat data pengguna..."),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Positioned(top: -100, right: -100, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.05)))),
              Positioned(bottom: -100, left: -100, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: secondaryColor.withOpacity(0.05)))),
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  const SizedBox(height: 16),
                  _buildProfileCard(context, primaryColor, authProvider),
                  const SizedBox(height: 24),
                  _buildSectionHeader(primaryColor, 'Account'),
                  const SizedBox(height: 12),
                  _buildSettingItem(context, Icons.person_outline_rounded, 'Edit Profile', primaryColor, onTap: () { // Icon diperbarui
                    Navigator.pushNamed(context, '/edit_profile');
                  }),
                  _buildSettingItem(context, Icons.brush_outlined, 'Profile Creator', primaryColor, onTap: () { // Icon diperbarui
                    Navigator.pushNamed(context, '/creator_profile');
                  }),
                  const SizedBox(height: 24),
                  _buildSectionHeader(secondaryColor, 'More'),
                  const SizedBox(height: 12),
                  _buildSettingItem(context, Icons.help_outline_rounded, 'Help', secondaryColor, onTap: () {
                    _showHelpDialog(context);
                  }),
                  _buildSettingItem(context, Icons.star_outline_rounded, 'Review App', secondaryColor, onTap: () { // Icon diperbarui
                    _launchAppReview(context);
                  }),
                  _buildSettingItem(context, Icons.info_outline_rounded, 'About App', secondaryColor, onTap: () { // Icon diperbarui
                    Navigator.pushNamed(context, '/about');
                  }),
                  _buildAppVersionSection(primaryColor),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context, authProvider),
                  const SizedBox(height: 80),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(BuildContext context, Color primaryColor, AuthProvider authProvider) {
    // Menggunakan getter currentUserName dan mendapatkan foto profil dari userModel atau firebaseUser
    String userName = authProvider.currentUserName;
    String userEmail = authProvider.firebaseUser?.email ?? 'Email tidak tersedia';
    
    // FIXED: Mendapatkan foto profil dari userModel atau firebaseUser yang tersedia di AuthProvider
    String? photoPathOrUrl;
    if (authProvider.userModel?.fotoProfilPath != null && authProvider.userModel!.fotoProfilPath!.isNotEmpty) {
      photoPathOrUrl = authProvider.userModel!.fotoProfilPath;
    } else if (authProvider.firebaseUser?.photoURL != null && authProvider.firebaseUser!.photoURL!.isNotEmpty) {
      photoPathOrUrl = authProvider.firebaseUser!.photoURL;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            height: 70, width: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor, width: 2)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: _buildDynamicProfileImage(photoPathOrUrl, userName, primaryColor, 70),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
                Text(userEmail, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicProfileImage(String? photoPathOrUrl, String userName, Color primaryColor, double size) {
    // Jika photoPathOrUrl null atau kosong, langsung generate avatar
    if (photoPathOrUrl == null || photoPathOrUrl.isEmpty) {
      return _generateAvatar(userName, size, primaryColor.withOpacity(0.2));
    }

    if (photoPathOrUrl.startsWith('http')) {
      return Image.network(
        photoPathOrUrl,
        fit: BoxFit.cover, width: size, height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
        },
        errorBuilder: (context, error, stackTrace) => _generateAvatar(userName, size, primaryColor.withOpacity(0.2)),
      );
    } else if (photoPathOrUrl.startsWith('assets/')) {
      return Image.asset(
        photoPathOrUrl,
        fit: BoxFit.cover, width: size, height: size,
        errorBuilder: (context, error, stackTrace) => _generateAvatar(userName, size, primaryColor.withOpacity(0.2)),
      );
    } else {
      File imageFile = File(photoPathOrUrl);
      // Cek apakah file ada sebelum mencoba memuatnya
      // Ini bisa jadi operasi synchronous yang kurang ideal di build method,
      // namun untuk path file lokal, dampaknya mungkin kecil.
      // Untuk kasus yang lebih kompleks, pertimbangkan FutureBuilder jika pengecekan file lambat.
      if (imageFile.existsSync()) {
          try {
            return Image.file(
                imageFile,
                fit: BoxFit.cover, width: size, height: size,
                errorBuilder: (context, error, stackTrace) => _generateAvatar(userName, size, primaryColor.withOpacity(0.2)),
            );
          } catch (e) {
            // Jika error saat memuat file (meskipun existsSync true)
            print("Error loading file image: $e");
            return _generateAvatar(userName, size, primaryColor.withOpacity(0.2));
          }
      } else {
          // Jika file tidak ditemukan
          return _generateAvatar(userName, size, primaryColor.withOpacity(0.2));
      }
    }
  }

  Widget _generateAvatar(String name, double size, Color backgroundColor) {
    String initials = name.isNotEmpty ? name.trim().split(' ').map((l) => l.isNotEmpty ? l[0] : '').join().toUpperCase() : '?';
    if (initials.length > 2) {
      initials = initials.substring(0, 2);
    } else if (initials.isEmpty) {
      initials = "?";
    }
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(child: Text(initials, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: size * 0.4))),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, Color iconColor, {VoidCallback? onTap, bool showBadge = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 22)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black87)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBadge) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), child: Text('New', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500))),
            const SizedBox(width: 8), // Selalu ada SizedBox untuk konsistensi spacing
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionHeader(Color color, String title) {
    return Row(children: [Container(height: 24, width: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 8), Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87))]);
  }

  Widget _buildAppVersionSection(Color primaryColor) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Image.asset('assets/images/LogoTokoKu.png', width: 60, height: 60,
              errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.shopping_bag_rounded, size: 30, color: primaryColor)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Version 1.0.0', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    // Implementasi UI Dialog Bantuan (tetap sama)
    showDialog(context: context, builder: (BuildContext context) { /* ... kode dialog ... */ return AlertDialog(title: Row(children: [Icon(Icons.help_outline_rounded, color: const Color(0xFFFF8C00), size: 24), const SizedBox(width: 10), Text('Help Center', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18))]), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHelpItem('Getting Started', 'Learn the basics of navigating and using our app', Icons.play_arrow_rounded), const Divider(), _buildHelpItem('Account Issues', 'Help with login, registration, and profile settings', Icons.person_rounded), const Divider(), _buildHelpItem('Payment Problems', 'Assistance with payment methods and transactions', Icons.payment_rounded), const Divider(), _buildHelpItem('Contact Support', 'Get in touch with our customer service team', Icons.support_agent_rounded), const SizedBox(height: 20), Text('Frequently Asked Questions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)), const SizedBox(height: 10), _buildFAQItem('How do I reset my password?'), _buildFAQItem('How to update my shipping address?'), _buildFAQItem('Can I cancel my order?'), _buildFAQItem('How to track my order?')])), actions: [ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D7BEE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text('Close', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)))], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));});
  }

  Widget _buildHelpItem(String title, String subtitle, IconData icon) {
    // Implementasi UI Item Bantuan (tetap sama)
    return ListTile(contentPadding: EdgeInsets.zero, leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2D7BEE).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF2D7BEE), size: 20)), title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)), subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])), onTap: () {});
  }

  Widget _buildFAQItem(String question) {
    // Implementasi UI Item FAQ (tetap sama)
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.circle, size: 8, color: const Color(0xFFFF8C00)), const SizedBox(width: 8), Expanded(child: Text(question, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)))]));
  }

  void _launchAppReview(BuildContext context) {
    // Implementasi UI Dialog Review (tetap sama)
    showDialog(context: context, builder: (BuildContext context) { /* ... kode dialog ... */ double rating = 0; return AlertDialog(title: Text('Rate Our App', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Your feedback helps us improve!', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center), const SizedBox(height: 20), StatefulBuilder(builder: (context, setState) { return Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => IconButton(icon: Icon(index < rating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFF8C00), size: 30), onPressed: () => setState(() => rating = index + 1.0)))); }), const SizedBox(height: 20), TextField(decoration: InputDecoration(hintText: 'Write your review here...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(10)), maxLines: 4)])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[600]))), ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanks for your feedback!', style: GoogleFonts.poppins()), backgroundColor: const Color(0xFF2D7BEE), duration: const Duration(seconds: 2))); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D7BEE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)))], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));});
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 2))]),
      child: ElevatedButton(
        onPressed: () async {
          await authProvider.signOut();
          // Gunakan context.mounted untuk keamanan setelah operasi async
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red[700], size: 20),
            const SizedBox(width: 8),
            Text('Log out', style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}