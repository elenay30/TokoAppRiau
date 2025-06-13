// File: lib/screens/news_screen.dart - Real-time Firebase Version with Auto Sample Data
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';
import '../utils/sample_notifications.dart'; // Import sample notifications utils

class NewsScreen extends StatefulWidget {
  final bool showBackButton;

  const NewsScreen({Key? key, this.showBackButton = false}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Transaction', 'Order', 'Promo', 'System'];
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    final provider = context.read<NotificationProvider>();
    
    // Initialize provider streams
    provider.initializeNotifications();
    
    // Wait for initial data load
    await Future.delayed(const Duration(seconds: 2));
    
    // Auto-create sample data if no notifications exist
    if (provider.notifications.isEmpty) {
      try {
        print('🔄 Auto-creating sample notifications...');
        
        // Create sample notifications secara otomatis
        await SampleNotifications.createSampleNotifications();
        await SampleNotifications.createShoppingScenarioNotifications();
        await SampleNotifications.createTimeBasedNotifications();
        await SampleNotifications.createCategoryBasedNotifications();
        await SampleNotifications.createSeasonalNotifications();
        
        print('✅ Sample notifications created automatically');
        
        // Optional: Show subtle notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome! Sample notifications loaded.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('❌ Error creating sample notifications: $e');
      }
    } else {
      print('📋 Found ${provider.notifications.length} existing notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 16.0;
    final primaryColor = const Color(0xFF2D7BEE);
    final secondaryColor = const Color(0xFFFF8C00);
    
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Notifications',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: widget.showBackButton,
            leading: widget.showBackButton 
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
            actions: [
              // Mark all as read button
              if (notificationProvider.unreadCount > 0)
                IconButton(
                  onPressed: () => notificationProvider.markAllAsRead(),
                  icon: Icon(Icons.done_all, color: primaryColor),
                  tooltip: 'Mark all as read',
                ),
            ],
          ),
          body: Stack(
            children: [
              // Background decorations
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: secondaryColor.withOpacity(0.05),
                  ),
                ),
              ),
              
              Column(
                children: [
                  // Filter chips
                  Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterOptions.map((filter) {
                          int count = 0;
                          switch (filter) {
                            case 'All':
                              count = notificationProvider.notifications.length;
                              break;
                            case 'Transaction':
                              count = notificationProvider.getNotificationsByType('transaction').length;
                              break;
                            case 'Order':
                              count = notificationProvider.getNotificationsByType('order').length;
                              break;
                            case 'Promo':
                              count = notificationProvider.getNotificationsByType('promo').length;
                              break;
                            case 'System':
                              count = notificationProvider.getNotificationsByType('system').length;
                              break;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(
                              '$filter ($count)', 
                              _selectedFilter == filter, 
                              primaryColor,
                              () => setState(() => _selectedFilter = filter),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: notificationProvider.isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: primaryColor),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading notifications...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildNotificationsList(
                            notificationProvider, 
                            primaryColor,
                            horizontalPadding,
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

  Widget _buildNotificationsList(
    NotificationProvider provider, 
    Color primaryColor,
    double horizontalPadding,
  ) {
    // Filter notifications based on selected filter
    List<AppNotification> filteredNotifications;
    switch (_selectedFilter) {
      case 'Transaction':
        filteredNotifications = provider.getNotificationsByType('transaction');
        break;
      case 'Order':
        filteredNotifications = provider.getNotificationsByType('order');
        break;
      case 'Promo':
        filteredNotifications = provider.getNotificationsByType('promo');
        break;
      case 'System':
        filteredNotifications = provider.getNotificationsByType('system');
        break;
      default:
        filteredNotifications = provider.notifications;
    }

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState(primaryColor);
    }

    // Group notifications by date
    final groupedNotifications = _groupNotificationsByDate(filteredNotifications);
    
    return ListView.builder(
      padding: EdgeInsets.only(top: 20, bottom: 20),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        final dateKey = groupedNotifications.keys.elementAt(index);
        final notifications = groupedNotifications[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 12),
              child: Row(
                children: [
                  Container(
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dateKey == 'Today' ? primaryColor : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateKey,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: dateKey == 'Today' ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Notifications for this date
            ...notifications.map((notification) => 
              _buildNotificationCard(context, notification, primaryColor, provider)
            ).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
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
              Icons.notifications_off,
              size: 64,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak Ada Notifikasi',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All' 
                ? 'Belum ada notifikasi untuk ditampilkan'
                : 'Tidak ada notifikasi ${_selectedFilter.toLowerCase()}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    Color primaryColor,
    NotificationProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead 
              ? null 
              : Border.all(color: primaryColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNotificationTap(context, notification, provider),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon/image
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: notification.imageUrl != null && notification.imageUrl!.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              notification.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  _getNotificationIcon(notification.type),
                                  color: _getNotificationColor(notification.type),
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Icon(
                            _getNotificationIcon(notification.type),
                            color: _getNotificationColor(notification.type),
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with new badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: GoogleFonts.poppins(
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'NEW',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        // Message
                        Text(
                          notification.message,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Time and action button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Time indicator
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notification.timeAgo,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Action buttons
                            Row(
                              children: [
                                if (!notification.isRead)
                                  InkWell(
                                    onTap: () => provider.markAsRead(notification.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Mark Read',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showDeleteDialog(context, notification, provider),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color primaryColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Helper methods
  Map<String, List<AppNotification>> _groupNotificationsByDate(List<AppNotification> notifications) {
    final Map<String, List<AppNotification>> grouped = {};
    final now = DateTime.now();
    
    for (final notification in notifications) {
      final notificationDate = notification.createdAt;
      
      String dateKey;
      if (notificationDate.year == now.year &&
          notificationDate.month == now.month &&
          notificationDate.day == now.day) {
        dateKey = 'Today';
      } else if (notificationDate.year == now.year &&
                 notificationDate.month == now.month &&
                 notificationDate.day == now.day - 1) {
        dateKey = 'Yesterday';
      } else if (now.difference(notificationDate).inDays < 7) {
        dateKey = 'This Week';
      } else {
        dateKey = 'Older';
      }
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }
    
    // Sort the keys to maintain order
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        const order = ['Today', 'Yesterday', 'This Week', 'Older'];
        return order.indexOf(a).compareTo(order.indexOf(b));
      });
    
    final sortedGrouped = <String, List<AppNotification>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    
    return sortedGrouped;
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'transaction':
        return Icons.payment;
      case 'order':
        return Icons.local_shipping;
      case 'promo':
        return Icons.local_offer;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'transaction':
        return Colors.green;
      case 'order':
        return Colors.blue;
      case 'promo':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification, NotificationProvider provider) {
    // Mark as read if not already
    if (!notification.isRead) {
      provider.markAsRead(notification.id);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'transaction':
      case 'order':
        // Navigate to transaction screen
        Navigator.pushNamed(context, '/main', arguments: {
          'selectedIndex': 2, // Orders tab
          'forceRefresh': true,
        });
        break;
      case 'promo':
        // Navigate to product or promo screen
        if (notification.productId != null) {
          // Navigate to specific product
          Navigator.pushNamed(context, '/product_detail', arguments: {
            'productId': notification.productId,
          });
        } else {
          // Navigate to home screen
          Navigator.pushNamed(context, '/main', arguments: {
            'selectedIndex': 0,
          });
        }
        break;
      case 'system':
        // Show system notification details or navigate to appropriate screen
        _showNotificationDetails(context, notification);
        break;
    }
  }

  void _showNotificationDetails(BuildContext context, AppNotification notification) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.type.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getNotificationColor(notification.type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notification.message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Time info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(notification.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      notification.timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Close button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D7BEE),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppNotification notification, NotificationProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Hapus Notifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Content
              Text(
                'Apakah Anda yakin ingin menghapus notifikasi ini? Tindakan ini tidak dapat dibatalkan.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: Container(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Delete button
                  Expanded(
                    child: Container(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.deleteNotification(notification.id);
                          Navigator.pop(context);
                          
                          // Custom snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Notifikasi berhasil dihapus',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Hapus',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}