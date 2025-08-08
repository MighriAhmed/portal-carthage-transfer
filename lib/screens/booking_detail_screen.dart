import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        user = authProvider.user;
      });
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _copyBookingDetails() {
    final details = '''
Booking ID: ${widget.booking.bookingId}
Status: ${widget.booking.status}
Pickup: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.booking.pickupDateTime)}
Route: ${widget.booking.route}
Payment: ${widget.booking.paymentName ?? ''}
Earning: ${widget.booking.earning}
Passengers: ${widget.booking.passengersNumber}
Vehicle: ${widget.booking.vehicleName ?? ''}
Name: ${widget.booking.fullName}
Email: ${widget.booking.emailAddress ?? ''}
Phone: ${widget.booking.phoneNumber ?? ''}
WhatsApp: ${widget.booking.whatsapp ?? ''}
Flight: ${widget.booking.flightNumber ?? ''}
Extras: ${widget.booking.extras?.join(', ') ?? ''}
Distance: ${widget.booking.distance ?? ''}
Comment: ${widget.booking.comment ?? ''}
''';
    
    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: details));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking details copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendWhatsAppMessage(String phoneNumber, String message) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Format phone number with country code if needed
    String formattedPhone = phoneNumber;
    if (!phoneNumber.startsWith('+')) {
      formattedPhone = '+216$phoneNumber'; // Tunisia country code
    }

    final whatsappUrl = 'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}';
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vous Bookings'),
            Text(
              'Hier, 18:40',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by Booking ID...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.close),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filter buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.list, size: 16),
                        label: const Text('All Bookings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.priority_high, size: 16),
                        label: const Text('Latest'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Add buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('+ Add Booking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('+ Add Supplier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Booking details card
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking ID and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.booking.bookingId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.booking.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.booking.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Booking details
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Route', widget.booking.route),
                            _buildDetailRow('Form', widget.booking.bookingFormName ?? ''),
                            _buildDetailRow('Source', widget.booking.isGoogleAds ? 'Google Ads' : 'Organic'),
                            _buildDetailRow('Price', '${widget.booking.price}'),
                            _buildDetailRow('Payment', widget.booking.paymentName ?? ''),
                            _buildDetailRow('Earning', '${widget.booking.earning}'),
                            _buildDetailRow('Passengers', '${widget.booking.passengersNumber}'),
                            _buildDetailRow('Vehicle', widget.booking.vehicleName ?? ''),
                            _buildDetailRow('Name', widget.booking.fullName),
                            _buildDetailRow('Email', widget.booking.emailAddress ?? ''),
                            _buildDetailRow('Phone', widget.booking.phoneNumber ?? ''),
                            _buildDetailRow('WhatsApp', widget.booking.whatsapp ?? ''),
                            _buildDetailRow('Flight', widget.booking.flightNumber ?? ''),
                            if (widget.booking.extras != null && widget.booking.extras!.isNotEmpty)
                              _buildDetailRow('Extras', widget.booking.extras!.join(', ')),
                            _buildDetailRow('Distance', widget.booking.distance?.toString() ?? ''),
                            if (widget.booking.comment != null && widget.booking.comment!.isNotEmpty)
                              _buildDetailRow('Comment', widget.booking.comment!),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Action buttons - pinned to bottom
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Read-only view - only copy and WhatsApp buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copyBookingDetails,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(), // Empty space for layout balance
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(), // Empty space for layout balance
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Second row of WhatsApp buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendWhatsAppMessage(
                          widget.booking.phoneNumber ?? '',
                          'Hello ${widget.booking.fullName}, regarding your booking ${widget.booking.bookingId}...',
                        ),
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Client'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendWhatsAppMessage(
                          widget.booking.supplier ?? '',
                          'Hello, regarding booking ${widget.booking.bookingId}...',
                        ),
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Supplier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendWhatsAppMessage(
                          '', // Driver phone number would be needed
                          'Hello driver, regarding booking ${widget.booking.bookingId}...',
                        ),
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Driver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 