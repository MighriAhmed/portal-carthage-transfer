import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portal_carthage_transfer/providers/auth_provider.dart';
import 'package:portal_carthage_transfer/providers/booking_provider.dart';
import 'package:portal_carthage_transfer/screens/booking_list_screen.dart';
import 'package:portal_carthage_transfer/utils/constants.dart';
import 'package:portal_carthage_transfer/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check user role and redirect if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRole();
    });
  }

  void _checkUserRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // If user is a supplier, redirect to booking list screen
    if (user?.isSupplier == true) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const BookingListScreen(),
        ),
      );
      return;
    }
    
    // If user is admin, load stats
    if (user?.isAdmin == true) {
      _loadStats();
    }
  }

  void _loadStats() {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user?.isAdmin == true) {
      // Load all bookings to calculate 24h stats
      bookingProvider.fetchBookings(context);
      // Load suppliers
      bookingProvider.fetchSuppliers(context);
    }
  }

  String _getDisplayName(User? user) {
    if (user == null) return 'User';
    
    // Try to get the best available name
    if (user.supplierName != null && user.supplierName!.isNotEmpty) {
      return user.supplierName!;
    }
    
    if (user.username != null && user.username!.isNotEmpty) {
      // Capitalize the first letter of username
      return user.username![0].toUpperCase() + user.username!.substring(1);
    }
    
    // If username is null or empty, try to get it from the JWT token
    // This is a fallback for cases where the JWT contains the username in 'sub' field
    if (user.username == null || user.username!.isEmpty) {
      // For now, we'll use a generic name based on role
      if (user.isAdmin) {
        return 'Administrator';
      } else if (user.isSupplier) {
        return 'Supplier';
      }
    }
    
    return 'User';
  }

  int _getBookingsLast24Hours(BookingProvider bookingProvider) {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    
    return bookingProvider.bookings.where((booking) {
      // Check if the booking was created within the last 24 hours
      // We'll use pickupDateTime as a proxy for creation time
      // In a real app, you might want to add a 'created_at' field to the booking model
      return booking.pickupDateTime.isAfter(twentyFourHoursAgo);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carthage Transfer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(
                            user?.isAdmin == true ? Icons.admin_panel_settings : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${_getDisplayName(user)}!',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Role: ${user?.role ?? 'Unknown'}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),



            // Native Flutter Option
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BookingListScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.phone_android,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Native Mobile Experience',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick stats (for admin users)
            if (user?.isAdmin == true) ...[
              Text(
                'Quick Stats',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment,
                              color: Theme.of(context).primaryColor,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bookingProvider.isLoading ? '...' : '${_getBookingsLast24Hours(bookingProvider)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bookings (24h)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bookingProvider.isLoading ? '...' : '${bookingProvider.suppliers.length}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Suppliers',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 