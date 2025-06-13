// File: lib/screens/transaction_screen.dart - MANUAL REFRESH VERSION
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart' as models;
import '../providers/cart_provider.dart';
import '../screens/main_screen.dart';

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
  int _selectedFilterIndex = 0;
  bool _isRefreshing = false;

  final List<List<models.TransactionStatus>> _filterStatusMap = [
    [], // Semua
    [models.TransactionStatus.pending, models.TransactionStatus.paid, models.TransactionStatus.shipped], // Sedang Proses
    [models.TransactionStatus.delivered], // Selesai
    [models.TransactionStatus.cancelled], // Dibatalkan
  ];

  @override
  void initState() {
    super.initState();
    print('🔄 TransactionScreen initState - NO auto refresh');
    
    // REMOVED: Auto refresh on init
    // Sekarang hanya menampilkan data yang sudah ada di service
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // OPTIONAL: Hanya refresh jika diminta melalui route arguments
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['forceRefresh'] == true) {
      print('🔄 Force refresh requested from route arguments');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshTransactions();
        }
      });
    }
  }

  // SIMPLIFIED: Method untuk refresh manual saja
  Future<void> _refreshTransactions() async {
    if (!mounted || _isRefreshing) return;
    
    print('🔄 Manual refresh started...');
    setState(() {
      _isRefreshing = true;
    });

    try {
      final transactionService = Provider.of<TransactionService>(context, listen: false);
      
      // Simple fetch tanpa streaming
      await transactionService.fetchUserTransactions();
      
      print('✅ Transactions refreshed: ${transactionService.transactions.length} found');
      
      // Debug: Print semua transaksi yang ditemukan
      for (int i = 0; i < transactionService.transactions.length; i++) {
        final tx = transactionService.transactions[i];
        print('Transaction $i: ID=${tx.id.substring(0, 8)}..., Status=${tx.statusString}, Items=${tx.items.length}, Total=${tx.totalAmount}');
      }
      
    } catch (e) {
      print('❌ Error refreshing transactions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gagal memuat pesanan: ${e.toString()}',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  // Safe currency formatting
  String _formatCurrency(double amount) {
    try {
      final formatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: '',
        decimalDigits: 0,
      );
      return formatter.format(amount).replaceAll(',', '.');
    } catch (e) {
      print('❌ Currency format error: $e');
      return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }
  }

  // Safe date formatting
  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      print('❌ Date format error: $e');
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Safe date time formatting
  String _formatDateTime(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      print('❌ DateTime format error: $e');
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2D7BEE);
    final secondaryColor = const Color(0xFFFF8C00);

    return Consumer2<TransactionService, CartProvider>(
      builder: (context, transactionService, cartProvider, child) {
        // SIMPLIFIED: Langsung ambil data dari service tanpa loading state yang kompleks
        List<models.Transaction> allTransactions = transactionService.transactions;
        bool isServiceLoading = transactionService.isLoading;
        bool isManualRefreshing = _isRefreshing;

        // Filter transaksi berdasarkan _selectedFilterIndex
        List<models.Transaction> displayedTransactions;
        if (_selectedFilterIndex == 0) {
          displayedTransactions = allTransactions;
        } else {
          displayedTransactions = allTransactions
              .where((t) => _filterStatusMap[_selectedFilterIndex].contains(t.status))
              .toList();
        }

        // Debug info
        print('🔍 Total transactions: ${allTransactions.length}');
        print('🔍 Displayed transactions: ${displayedTransactions.length}');
        print('🔍 Selected filter: $_selectedFilterIndex');
        print('🔍 Service loading: $isServiceLoading, Manual refreshing: $isManualRefreshing');

        // Cek apakah ada item di cart
        bool hasCartItems = cartProvider.itemCount > 0;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              'Pesanan Saya', 
              style: GoogleFonts.poppins(
                color: Colors.black87, 
                fontSize: 18, 
                fontWeight: FontWeight.w600
              )
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: widget.showBackButton
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100, 
                        shape: BoxShape.circle
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded, 
                        color: primaryColor, 
                        size: 16
                      ),
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } else {
                        Navigator.pushReplacementNamed(context, '/main');
                      }
                    },
                  )
                : null,
            // Refresh button di app bar
            actions: [
              IconButton(
                onPressed: isManualRefreshing ? null : _refreshTransactions,
                icon: isManualRefreshing 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: primaryColor,
                      ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshTransactions,
            color: primaryColor,
            child: Stack(
              children: [
                // Background decoration
                Positioned(
                  top: -100, 
                  right: -100, 
                  child: Container(
                    width: 200, 
                    height: 200, 
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      color: primaryColor.withOpacity(0.05)
                    )
                  )
                ),
                Positioned(
                  bottom: -100, 
                  left: -100, 
                  child: Container(
                    width: 200, 
                    height: 200, 
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      color: secondaryColor.withOpacity(0.05)
                    )
                  )
                ),
                
                // Main content
                Column(
                  children: [
                    // IMPROVED: Info panel untuk user guidance
                    if (allTransactions.isEmpty && !isServiceLoading && !isManualRefreshing) ...[
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tarik ke bawah atau tekan tombol refresh untuk memuat pesanan terbaru',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Filter chips - tampilkan jika ada transaksi
                    if (allTransactions.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('Semua (${allTransactions.length})', 0, primaryColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Sedang Proses (${allTransactions.where((t) => _filterStatusMap[1].contains(t.status)).length})', 1, primaryColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Selesai (${allTransactions.where((t) => _filterStatusMap[2].contains(t.status)).length})', 2, primaryColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Dibatalkan (${allTransactions.where((t) => _filterStatusMap[3].contains(t.status)).length})', 3, primaryColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Content area
                    Expanded(
                      child: isManualRefreshing
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: primaryColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Memuat pesanan...',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : allTransactions.isEmpty
                              ? _buildEmptyStateWithCartRedirect(context, primaryColor, hasCartItems, cartProvider)
                              : displayedTransactions.isEmpty
                                  ? _buildEmptyFilterState(context, primaryColor)
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      itemCount: displayedTransactions.length,
                                      itemBuilder: (context, index) {
                                        final transaction = displayedTransactions[index];
                                        String imageUrl = transaction.items.isNotEmpty && 
                                            transaction.items.first.imageUrl.isNotEmpty
                                            ? transaction.items.first.imageUrl
                                            : 'assets/images/placeholder.png';

                                        String description = transaction.items.isNotEmpty
                                            ? (transaction.items.length > 1
                                                ? '${transaction.items.first.name} & ${transaction.items.length - 1} lainnya'
                                                : transaction.items.first.name)
                                            : 'Tidak ada item dalam pesanan ini';

                                        return _buildModernTransactionCard(
                                          context,
                                          transaction: transaction,
                                          imageUrl: imageUrl,
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
          ),
        );
      },
    );
  }

  // Rest of the methods tetap sama...
  Widget _buildEmptyFilterState(BuildContext context, Color primaryColor) {
    String filterName = '';
    switch (_selectedFilterIndex) {
      case 1:
        filterName = 'Sedang Proses';
        break;
      case 2:
        filterName = 'Selesai';
        break;
      case 3:
        filterName = 'Dibatalkan';
        break;
      default:
        filterName = 'Semua';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.filter_list_off_rounded,
              size: 64,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak Ada Pesanan $filterName',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada pesanan dengan status $filterName',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilterIndex = 0;
              });
            },
            child: Text(
              'Lihat Semua Pesanan',
              style: GoogleFonts.poppins(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWithCartRedirect(
    BuildContext context, 
    Color primaryColor, 
    bool hasCartItems, 
    CartProvider cartProvider
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasCartItems ? Icons.shopping_cart : Icons.receipt_long_rounded,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasCartItems ? 'Selesaikan Pesanan Anda' : 'Belum Ada Pesanan',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasCartItems 
                  ? 'Anda memiliki ${cartProvider.itemCount} item di keranjang.\nSelesaikan pembayaran untuk melihat riwayat pesanan.'
                  : 'Selesaikan pembayaran pertamamu\nuntuk melihat pesanan di sini',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (hasCartItems) ...[
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  label: Text(
                    'Lihat Keranjang (${cartProvider.itemCount})',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ),
                    (route) => false,
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  label: Text(
                    'Mulai Belanja',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ),
              
              // TAMBAHAN: Manual refresh button untuk empty state
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _refreshTransactions,
                icon: Icon(Icons.refresh, color: primaryColor, size: 18),
                label: Text(
                  'Muat Pesanan',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: primaryColor.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            _selectedFilterIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedFilterIndex == index ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedFilterIndex == index ? primaryColor : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: _selectedFilterIndex == index ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernTransactionCard(
    BuildContext context, {
    required models.Transaction transaction,
    required String imageUrl,
    required String description,
    required Color primaryColor,
  }) {
    final statusString = transaction.statusString;
    final statusColor = _getStatusColor(transaction.status, primaryColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header dengan ID dan tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Pesanan #${transaction.id.length > 8 ? transaction.id.substring(0, 8) : transaction.id}...',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(transaction.createdAt),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Product info dengan gambar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildTransactionItemImage(imageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: Rp ${_formatCurrency(transaction.totalAmount)}',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusString,
                          style: GoogleFonts.poppins(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showTrackingPopup(context, primaryColor, transaction),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Lacak Pesanan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: transaction.status == models.TransactionStatus.delivered
                        ? () => _showReviewPopup(context, primaryColor, transaction)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Beri Ulasan',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItemImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: Colors.grey.shade200,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey[400],
            size: 24,
          ),
        ),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: Colors.grey.shade200,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey[400],
            size: 24,
          ),
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[400],
        size: 24,
      ),
    );
  }

  Color _getStatusColor(models.TransactionStatus status, Color defaultColor) {
    switch (status) {
      case models.TransactionStatus.pending:
        return Colors.orange[700]!;
      case models.TransactionStatus.paid:
        return Colors.blue[700]!;
      case models.TransactionStatus.shipped:
        return Colors.teal[700]!;
      case models.TransactionStatus.delivered:
        return Colors.green[700]!;
      case models.TransactionStatus.cancelled:
        return Colors.red[700]!;
      default:
        return defaultColor;
    }
  }

  void _showTrackingPopup(BuildContext context, Color primaryColor, models.Transaction transaction) {
    bool isCreated = true;
    bool isProcessed = transaction.status != models.TransactionStatus.pending;
    bool isShipped = transaction.status == models.TransactionStatus.shipped || 
                     transaction.status == models.TransactionStatus.delivered;
    bool isDelivered = transaction.status == models.TransactionStatus.delivered;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Lacak Pesanan #${transaction.id.length > 8 ? transaction.id.substring(0, 8) : transaction.id}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTrackingStep('Pesanan Dibuat', isCreated, primaryColor, transaction.createdAt),
            _buildTrackingStep('Pesanan Diproses', isProcessed, primaryColor, 
                isProcessed ? (transaction.updatedAt ?? transaction.createdAt) : null),
            _buildTrackingStep('Sedang Dikirim', isShipped, primaryColor, 
                isShipped ? (transaction.updatedAt ?? transaction.createdAt) : null),
            _buildTrackingStep('Pesanan Sampai', isDelivered, primaryColor, 
                isDelivered ? (transaction.updatedAt ?? transaction.createdAt) : null),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? primaryColor : Colors.grey[300],
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: isCompleted ? Colors.black87 : Colors.grey[600],
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (date != null && isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      _formatDateTime(date),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
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
    double rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Beri Ulasan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: primaryColor,
                      size: 36,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis ulasan Anda...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: rating > 0
                  ? () {
                      print('Review untuk transaksi ${transaction.id}: Rating $rating, Teks "${reviewController.text}"');
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Terima kasih atas ulasan Anda!',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: primaryColor,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                'Kirim',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}