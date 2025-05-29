// File: lib/screens/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:intl/intl.dart'; // Untuk formatting tanggal
import '../services/transaction_service.dart'; // Service yang sudah terintegrasi Firebase
import '../models/transaction.dart' as models; // Model Transaction global
import '../screens/main_screen.dart'; // Untuk navigasi

class TransactionScreen extends StatefulWidget {
  final bool showBackButton;

  const TransactionScreen({
    Key? key,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int _selectedFilterIndex = 0; // 0: Semua, 1: Sedang Proses, 2: Selesai

  // Daftar status yang sesuai dengan filter.
  // Sesuaikan ini dengan enum TransactionStatus di model Transaction kamu.
  final List<List<models.TransactionStatus>> _filterStatusMap = [
    [], // Untuk "Semua" (kosong berarti tidak ada filter status spesifik)
    [models.TransactionStatus.pending, models.TransactionStatus.paid, models.TransactionStatus.shipped], // Sedang Proses
    [models.TransactionStatus.delivered], // Selesai
    [models.TransactionStatus.cancelled], // Mungkin perlu filter "Dibatalkan"
  ];

  @override
  void initState() {
    super.initState();
    // Panggil fetchUserTransactions saat layar pertama kali dibuka.
    // listen: false karena ini adalah aksi, bukan untuk rebuild UI di initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionService>(context, listen: false).fetchUserTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2D7BEE);
    final secondaryColor = const Color(0xFFFF8C00);

    // Menggunakan Consumer<TransactionService> untuk mendapatkan instance
    // dan rebuild UI saat TransactionService memanggil notifyListeners().
    return Consumer<TransactionService>(
      builder: (context, transactionService, child) {
        // Filter transaksi berdasarkan _selectedFilterIndex
        List<models.Transaction> displayedTransactions;
        if (_selectedFilterIndex == 0) { // Semua
          displayedTransactions = transactionService.transactions;
        } else {
          displayedTransactions = transactionService.transactions
              .where((t) => _filterStatusMap[_selectedFilterIndex].contains(t.status))
              .toList();
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text('Pesanan Saya', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false, // Kita handle leading secara manual
            leading: widget.showBackButton
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 16),
                    ),
                    onPressed: () {
                      // Jika bisa pop, pop. Jika tidak (misal ini root dari navigator),
                      // navigasi ke MainScreen atau HomeScreen.
                      if (Navigator.canPop(context)) {
                        // Jika dari checkout, mungkin kembali ke home/main
                         Navigator.of(context).popUntil((route) => route.isFirst);
                      } else {
                        // Fallback jika tidak bisa pop, misal langsung dari bottom nav
                        Navigator.pushReplacementNamed(context, '/main');
                      }
                    },
                  )
                : null, // Tidak ada tombol back jika showBackButton false
          ),
          body: Stack(
            children: [
              Positioned(top: -100, right: -100, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.05)))),
              Positioned(bottom: -100, left: -100, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: secondaryColor.withOpacity(0.05)))),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: SingleChildScrollView( // Agar bisa di-scroll jika chip terlalu banyak
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Semua', 0, primaryColor),
                          const SizedBox(width: 8),
                          _buildFilterChip('Sedang Proses', 1, primaryColor),
                          const SizedBox(width: 8),
                          _buildFilterChip('Selesai', 2, primaryColor),
                          // const SizedBox(width: 8),
                          // _buildFilterChip('Dibatalkan', 3, primaryColor), // Contoh filter tambahan
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: transactionService.isLoading
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : displayedTransactions.isEmpty
                            ? _buildEmptyTransactionView(context, primaryColor)
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                itemCount: displayedTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = displayedTransactions[index];
                                  // Ambil gambar dari item pertama jika ada
                                  String imageUrl = transaction.items.isNotEmpty && transaction.items.first.imageUrl.isNotEmpty
                                      ? transaction.items.first.imageUrl
                                      : 'assets/images/placeholder.png'; // Sediakan placeholder jika tidak ada gambar

                                  String description = transaction.items.isNotEmpty
                                      ? (transaction.items.length > 1
                                          ? '${transaction.items.first.name} & ${transaction.items.length - 1} lainnya'
                                          : transaction.items.first.name)
                                      : 'Tidak ada item dalam pesanan ini';

                                  return _buildModernTransactionCard(
                                    context,
                                    transaction: transaction,
                                    imageUrl: imageUrl, // Kirim imageUrl yang sudah dicek
                                    description: description,
                                    primaryColor: primaryColor,
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int index, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            _selectedFilterIndex = index;
            // Tidak perlu panggil fetch ulang di sini karena filter dilakukan pada data lokal
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: _selectedFilterIndex == index ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
        child: Text(label, style: GoogleFonts.poppins(color: _selectedFilterIndex == index ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildEmptyTransactionView(BuildContext context, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.receipt_long_rounded, size: 64, color: primaryColor)),
          const SizedBox(height: 24),
          Text('Belum Ada Pesanan', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Selesaikan pembayaran pertamamu\nuntuk melihat pesanan di sini', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14, height: 1.5)),
          const SizedBox(height: 32),
          Container(
            height: 50,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainScreen()), (route) => false),
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: Text('Mulai Belanja', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), padding: const EdgeInsets.symmetric(horizontal: 24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTransactionCard(
    BuildContext context, {
    required models.Transaction transaction,
    required String imageUrl, // Terima imageUrl yang sudah disiapkan
    required String description,
    required Color primaryColor,
  }) {
    final statusString = transaction.statusString; // Dari model Transaction
    final statusColor = _getStatusColor(transaction.status, primaryColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    // Tampilkan ID transaksi atau nomor order jika ada
                    Text('Pesanan #${transaction.id.length > 8 ? transaction.id.substring(0, 8) : transaction.id}...', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                  ],
                ),
                Text(DateFormat.yMMMMd('id_ID').format(transaction.createdAt), style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // Gunakan _buildProductImage dari CartScreen (atau buat versi serupa di sini)
                  child: _buildTransactionItemImage(imageUrl), // Ganti Image.asset jika imageUrl adalah URL
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description, style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Total: Rp ${transaction.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(statusString, style: GoogleFonts.poppins(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showTrackingPopup(context, primaryColor, transaction),
                    style: OutlinedButton.styleFrom(foregroundColor: primaryColor, side: BorderSide(color: primaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: Text('Lacak Pesanan', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: transaction.status == models.TransactionStatus.delivered
                        ? () => _showReviewPopup(context, primaryColor, transaction)
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, disabledBackgroundColor: Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: Text('Beri Ulasan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk menampilkan gambar item transaksi
  Widget _buildTransactionItemImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 80, height: 80, fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(width: 80, height: 80, color: Colors.grey.shade200, child: Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null)));
        },
        errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey.shade200, child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 24)),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl, // Jika ini path aset
        width: 80, height: 80, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey.shade200, child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 24)),
      );
    }
    // Fallback jika format tidak dikenali
    return Container(width: 80, height: 80, color: Colors.grey.shade200, child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 24));
  }


  Color _getStatusColor(models.TransactionStatus status, Color defaultColor) {
    switch (status) {
      case models.TransactionStatus.pending: return Colors.orange[700]!;
      case models.TransactionStatus.paid: return Colors.blue[700]!;
      case models.TransactionStatus.shipped: return Colors.teal[700]!;
      case models.TransactionStatus.delivered: return Colors.green[700]!;
      case models.TransactionStatus.cancelled: return Colors.red[700]!;
      default: return defaultColor; // Seharusnya tidak pernah terjadi jika semua status tercover
    }
  }

  void _showTrackingPopup(BuildContext context, Color primaryColor, models.Transaction transaction) {
    bool isCreated = true; // Pesanan pasti dibuat
    bool isProcessed = transaction.status != models.TransactionStatus.pending;
    bool isShipped = transaction.status == models.TransactionStatus.shipped || transaction.status == models.TransactionStatus.delivered;
    bool isDelivered = transaction.status == models.TransactionStatus.delivered;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Lacak Pesanan #${transaction.id.length > 8 ? transaction.id.substring(0,8) : transaction.id}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTrackingStep('Pesanan Dibuat', isCreated, primaryColor, transaction.createdAt), // Gunakan createdAt
            // Untuk tanggal proses, kirim, sampai, bisa gunakan updatedAt jika ada, atau null jika belum
            _buildTrackingStep('Pesanan Diproses', isProcessed, primaryColor, isProcessed ? (transaction.updatedAt ?? transaction.createdAt) : null),
            _buildTrackingStep('Sedang Dikirim', isShipped, primaryColor, isShipped ? (transaction.updatedAt ?? transaction.createdAt) : null),
            _buildTrackingStep('Pesanan Sampai', isDelivered, primaryColor, isDelivered ? (transaction.updatedAt ?? transaction.createdAt) : null),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup', style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String title, bool isCompleted, Color primaryColor, DateTime? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? primaryColor : Colors.grey[300]),
            child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
          ),
          const SizedBox(width: 12),
          Expanded( // Agar teks panjang tidak overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: isCompleted ? Colors.black87 : Colors.grey[600], fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal)),
                if (date != null && isCompleted) // Tampilkan tanggal jika ada dan sudah selesai
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(DateFormat.yMMMMd('id_ID').add_jm().format(date), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewPopup(BuildContext context, Color primaryColor, models.Transaction transaction) {
    final TextEditingController reviewController = TextEditingController();
    double rating = 0; // Inisialisasi rating

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Dibutuhkan untuk update rating bintang di dalam dialog
        builder: (context, setDialogState) => AlertDialog( // Ganti setState di sini menjadi setDialogState
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Beri Ulasan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(index < rating ? Icons.star_rounded : Icons.star_border_rounded, color: primaryColor, size: 36),
                    onPressed: () {
                      setDialogState(() { // Gunakan setDialogState
                        rating = index + 1.0; // Pastikan jadi double jika perlu desimal
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController, maxLines: 3,
                decoration: InputDecoration(hintText: 'Tulis ulasan Anda...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2))),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500))),
            ElevatedButton(
              onPressed: rating > 0 ? () {
                // TODO: Implementasi logika untuk menyimpan ulasan ke Firebase
                // Misalnya, panggil method di TransactionService:
                // transactionService.addReview(transactionId: transaction.id, rating: rating, reviewText: reviewController.text);
                print('Review untuk transaksi ${transaction.id}: Rating $rating, Teks "${reviewController.text}"');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terima kasih atas ulasan Anda!', style: GoogleFonts.poppins()), backgroundColor: primaryColor));
              } : null,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, disabledBackgroundColor: Colors.grey[300]),
              child: Text('Kirim', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}