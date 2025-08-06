import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portal_carthage_transfer/providers/auth_provider.dart';
import 'package:portal_carthage_transfer/providers/booking_provider.dart';
import 'package:portal_carthage_transfer/models/booking.dart';
import 'package:portal_carthage_transfer/utils/constants.dart';
import 'package:portal_carthage_transfer/widgets/booking_card.dart';
import 'package:portal_carthage_transfer/widgets/filter_dialog.dart';
import 'package:portal_carthage_transfer/widgets/booking_form_dialog.dart';
import 'package:portal_carthage_transfer/widgets/supplier_form_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = '';
  String _selectedSupplier = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      // Redirect to login if not authenticated
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }
    
    // Set default dates
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate!.add(const Duration(days: 1));

    // Load initial data - suppliers can see all bookings, admins can see filtered bookings
    if (mounted) {
      if (authProvider.user?.isSupplier == true) {
        // Suppliers see all bookings without any filters
        await bookingProvider.fetchBookings(context, setLoading: true, isSupplier: true);
      } else {
        // Admins see bookings with date filters
        await bookingProvider.fetchBookings(
          context,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
    }

    // Load suppliers if admin
    if (mounted && authProvider.user?.isAdmin == true) {
      await bookingProvider.fetchSuppliers(context);
    }
  }

  Future<void> _applyFilters() async {
    if (!mounted) return;
    
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (mounted) {
      if (authProvider.user?.isSupplier == true) {
        // Suppliers can filter by status and search, but see all bookings
        await bookingProvider.fetchBookings(
          context,
          bookingId: _searchController.text.trim(),
          status: _selectedStatus,
          setLoading: true,
          isSupplier: true,
        );
      } else {
        // Admins can use all filters including date and supplier
        await bookingProvider.fetchBookings(
          context,
          bookingId: _searchController.text.trim(),
          status: _selectedStatus,
          supplier: _selectedSupplier,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
    }
  }

  Future<void> _loadLatestBookings() async {
    if (!mounted) return;
    
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (mounted) {
      if (authProvider.user?.isSupplier == true) {
        // Suppliers see all latest bookings without date filter
        await bookingProvider.fetchLatestBookings(
          context,
          status: _selectedStatus,
        );
      } else {
        // Admins see latest bookings with date filter
        await bookingProvider.fetchLatestBookings(
          context,
          fromDate: _startDate,
          status: _selectedStatus,
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        selectedStatus: _selectedStatus,
        selectedSupplier: _selectedSupplier,
        startDate: _startDate,
        endDate: _endDate,
        onApply: (status, supplier, startDate, endDate) {
          setState(() {
            _selectedStatus = status;
            _selectedSupplier = supplier;
            _startDate = startDate;
            _endDate = endDate;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showAddBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => const BookingFormDialog(),
    );
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => const SupplierFormDialog(),
    );
  }

  void _showWhatsAppLanguageDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => LanguageSelectionDialog(booking: booking),
    );
  }

  void _showEditBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => BookingFormDialog(booking: booking),
    );
  }

  void _printBookings() {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printing is only available on web'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
  }

  void _printDetailedOrder() {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printing is only available on web'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
  }



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _applyFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Booking ID...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedStatus = '';
                            _selectedSupplier = '';
                          });
                          _applyFilters();
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('All Bookings'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadLatestBookings,
                        icon: const Icon(Icons.new_releases),
                        label: const Text('Latest'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                if (user?.isAdmin == true) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showAddBookingDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Booking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF4C542),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showAddSupplierDialog,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Supplier'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF4C542),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Bookings list
          Expanded(
            child: bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookingProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              bookingProvider.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _applyFilters,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : bookingProvider.bookings.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No bookings found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: bookingProvider.bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookingProvider.bookings[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: BookingCard(
                                  booking: booking,
                                  user: user,
                                  onEdit: () {
                                    _showEditBookingDialog(booking);
                                  },
                                  onDelete: () async {
                                    // Capture the provider reference before async operation
                                    final provider = Provider.of<BookingProvider>(context, listen: false);
                                    final bookingId = booking.id;
                                    
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: Text('Are you sure you want to delete booking ${booking.bookingId}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true && mounted) {
                                      final success = await provider.deleteBooking(context, bookingId);
                                      if (success) {
                                        // Success - the booking was deleted from the list
                                      }
                                    }
                                  },
                                  onWhatsApp: () => _showWhatsAppLanguageDialog(booking),
                                  onSupplierWhatsApp: () {
                                    final phone = bookingProvider.getSupplierPhone(booking.supplier ?? '');
                                    if (phone != null) {
                                      final whatsappUrl = '${AppConstants.whatsappBaseUrl}${phone.replaceAll(RegExp(r'[^0-9]'), '')}';
                                      launchUrl(Uri.parse(whatsappUrl));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No supplier phone number available.')),
                                      );
                                    }
                                  },
                                  onDriverWhatsApp: () {
                                    if (booking.driverContact != null && booking.driverContact!.isNotEmpty) {
                                      final whatsappUrl = '${AppConstants.whatsappBaseUrl}${booking.driverContact!.replaceAll(RegExp(r'[^0-9]'), '')}';
                                      launchUrl(Uri.parse(whatsappUrl));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No driver contact available.')),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class LanguageSelectionDialog extends StatefulWidget {
  final Booking booking;

  const LanguageSelectionDialog({
    super.key,
    required this.booking,
  });

  @override
  State<LanguageSelectionDialog> createState() => _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  String _selectedLanguage = 'en';

  void _sendWhatsAppMessage(String language) {
    if (widget.booking.phoneNumber == null || widget.booking.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available for this booking.')),
      );
      return;
    }

    final formattedNumber = widget.booking.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    String message = '';
    
    switch (language) {
      case 'en':
        message = '''Hello! Your transfer booking #${widget.booking.bookingId} has been confirmed.

📅 Date: ${dateFormat.format(widget.booking.pickupDateTime)}
🕐 Time: ${timeFormat.format(widget.booking.pickupDateTime)}
📍 Pickup: ${widget.booking.addresses.isNotEmpty ? widget.booking.addresses.first : 'TBD'}
👥 Passengers: ${widget.booking.passengersNumber}
🚗 Vehicle: ${widget.booking.vehicleName?.isNotEmpty == true ? widget.booking.vehicleName : 'TBD'}

For any questions, please contact us.
Thank you!''';
        break;
      case 'fr':
        message = '''Bonjour ! Votre réservation de transfert #${widget.booking.bookingId} a été confirmée.

📅 Date : ${dateFormat.format(widget.booking.pickupDateTime)}
🕐 Heure : ${timeFormat.format(widget.booking.pickupDateTime)}
📍 Prise en charge : ${widget.booking.addresses.isNotEmpty ? widget.booking.addresses.first : 'À confirmer'}
👥 Passagers : ${widget.booking.passengersNumber}
🚗 Véhicule : ${widget.booking.vehicleName?.isNotEmpty == true ? widget.booking.vehicleName : 'À confirmer'}

Pour toute question, contactez-nous.
Merci !''';
        break;
      case 'de':
        message = '''Hallo! Ihre Transferbuchung #${widget.booking.bookingId} wurde bestätigt.

📅 Datum: ${dateFormat.format(widget.booking.pickupDateTime)}
🕐 Uhrzeit: ${timeFormat.format(widget.booking.pickupDateTime)}
📍 Abholung: ${widget.booking.addresses.isNotEmpty ? widget.booking.addresses.first : 'TBD'}
👥 Passagiere: ${widget.booking.passengersNumber}
🚗 Fahrzeug: ${widget.booking.vehicleName?.isNotEmpty == true ? widget.booking.vehicleName : 'TBD'}

Bei Fragen kontaktieren Sie uns bitte.
Vielen Dank!''';
        break;
    }
    
    final whatsappUrl = '${AppConstants.whatsappBaseUrl}$formattedNumber?text=${Uri.encodeComponent(message)}';
    
    if (kIsWeb) {
      // Open in new tab for web
      launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      // Use url_launcher for mobile
      launchUrl(Uri.parse(whatsappUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Language for WhatsApp Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('French'),
            value: 'fr',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('German'),
            value: 'de',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _sendWhatsAppMessage(_selectedLanguage);
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
} 