// File: lib/screens/main_screen.dart - COMPLETE FIXED VERSION
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart' as models;
// Import screen yang diperlukan
import 'home_screen.dart';  
import 'news_screen.dart';
import 'transaction_screen.dart';
import 'setting_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _hasHandledInitialArgs = false;
  
  // Daftar halaman yang akan ditampilkan
  final List<Widget> _screens = [
    const HomeScreen(),       // Index 0
    const NewsScreen(),       // Index 1
    const TransactionScreen(showBackButton: false), // Index 2
    const SettingScreen(),    // Index 3
  ];

  @override
  void initState() {
    super.initState();
    print('🔄 MainScreen initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Handle arguments dari navigation hanya sekali dan dengan guard
    if (!_hasHandledInitialArgs) {
      _hasHandledInitialArgs = true;
      
      // Delay handling untuk menghindari loop
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _handleInitialArguments();
        }
      });
    }
  }

  // FIXED: MainScreen _handleInitialArguments method
// Ganti method ini di MainScreen

void _handleInitialArguments() {
  if (!mounted) return;
  
  final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  
  if (arguments != null) {
    print('🔄 MainScreen received arguments: $arguments');
    
    // Handle selectedIndex dengan validation
    if (arguments.containsKey('selectedIndex')) {
      final newIndex = arguments['selectedIndex'] as int;
      print('🔄 Setting selected index to: $newIndex');
      
      if (newIndex >= 0 && newIndex < 4 && mounted) {
        setState(() {
          _selectedIndex = newIndex;
        });
        
        // FIXED: Force refresh jika ke Orders tab
        if (newIndex == 2) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              try {
                final transactionService = Provider.of<TransactionService>(context, listen: false);
                transactionService.fetchUserTransactions().then((_) {
                  print('✅ Transactions refreshed after tab switch');
                });
              } catch (e) {
                print('❌ Error refreshing transactions: $e');
              }
            }
          });
        }
      }
    }
    
    // Handle force refresh
    if (arguments.containsKey('forceRefresh') && arguments['forceRefresh'] == true) {
      print('🔄 Force refresh requested');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          try {
            final transactionService = Provider.of<TransactionService>(context, listen: false);
            transactionService.fetchUserTransactions().then((_) {
              print('✅ Force refresh completed');
            });
          } catch (e) {
            print('❌ Error in force refresh: $e');
          }
        }
      });
    }
  }
}

  void _onNavItemTapped(int index) {
    print('🔄 Tab changed to index: $index');
    
    // Navigasi normal ke semua tab, termasuk Orders (TransactionScreen)
    setState(() {
      _selectedIndex = index;
    });
    
    // Jika navigate ke TransactionScreen, refresh data
    if (index == 2 && mounted) {
      print('🔄 Navigating to TransactionScreen, refreshing data...');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          try {
            final transactionService = Provider.of<TransactionService>(context, listen: false);
            transactionService.fetchUserTransactions();
          } catch (e) {
            print('❌ Error refreshing transactions on tab switch: $e');
          }
        }
      });
    }
  }

  // Safe method untuk get pending transactions count
  int _getPendingTransactionsCount(TransactionService transactionService) {
    try {
      return transactionService.transactions.where((t) => 
        t.status == models.TransactionStatus.pending || 
        t.status == models.TransactionStatus.paid || 
        t.status == models.TransactionStatus.shipped
      ).length;
    } catch (e) {
      print('❌ Error getting pending transactions count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, CartProvider, TransactionService>(
      builder: (context, authProvider, cartProvider, transactionService, child) {
        // Debug print untuk melihat status user dan cart
        print('🏠 MainScreen - Auth Status:');
        print('  - isLoggedIn: ${authProvider.isLoggedIn}');
        print('  - Firebase User: ${authProvider.firebaseUser?.email}');
        print('  - Display Name: ${authProvider.firebaseUser?.displayName}');
        print('  - UserModel: ${authProvider.userModel?.nama}');
        print('  - Current User Name: ${authProvider.currentUserName}');
        print('🛒 MainScreen - Cart Status:');
        print('  - Cart items: ${cartProvider.items.length}');
        print('  - Item count: ${cartProvider.itemCount}');
        print('  - Is loading: ${cartProvider.isLoading}');
        print('📋 MainScreen - Transaction Status:');
        print('  - Transaction count: ${transactionService.transactions.length}');
        print('  - Is loading: ${transactionService.isLoading}');
        
        // Jika user belum login dengan benar, redirect ke login
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // FAB tetap untuk ke cart
              Navigator.pushNamed(context, '/cart');
            },
            backgroundColor: Colors.orange,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                // Cart badge dengan data real dari CartProvider
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D7BEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        cartProvider.itemCount > 99 ? '99+' : '${cartProvider.itemCount}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            elevation: 6,
            shape: const CircleBorder(),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            color: const Color(0xFF2D7BEE),
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Dua item kiri
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onNavItemTapped(0),
                            child: NavItem(
                              icon: Icons.home, 
                              label: "Home", 
                              selected: _selectedIndex == 0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onNavItemTapped(1),
                            child: NavItem(
                              icon: Icons.notifications_none, 
                              label: "News",
                              selected: _selectedIndex == 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Ruang untuk FAB
                  const SizedBox(width: 60),
                  
                  // Dua item kanan
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onNavItemTapped(2),
                            child: NavItemWithBadge(
                              icon: Icons.receipt_long, 
                              label: "Orders",
                              selected: _selectedIndex == 2,
                              badgeCount: _getPendingTransactionsCount(transactionService),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onNavItemTapped(3),
                            child: NavItem(
                              icon: Icons.person_outline, 
                              label: "Setting",
                              selected: _selectedIndex == 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// STANDARD NAV ITEM
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  
  const NavItem({
    Key? key,
    required this.icon,
    required this.label,
    this.selected = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: selected ? Colors.white : Colors.white70,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// NAV ITEM DENGAN BADGE UNTUK ORDERS
class NavItemWithBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badgeCount;
  
  const NavItemWithBadge({
    Key? key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.badgeCount = 0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.white70,
              size: 22,
            ),
            if (badgeCount > 0)
              Positioned(
                right: -8,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2D7BEE), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}