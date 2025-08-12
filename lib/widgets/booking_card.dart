import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:portal_carthage_transfer/models/booking.dart';
import 'package:portal_carthage_transfer/models/user.dart';
import 'package:portal_carthage_transfer/utils/constants.dart';


class BookingCard extends StatelessWidget {
  final Booking booking;
  final User? user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onWhatsApp;
  final VoidCallback onSupplierWhatsApp;
  final VoidCallback onDriverWhatsApp;

  const BookingCard({
    super.key,
    required this.booking,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onWhatsApp,
    required this.onSupplierWhatsApp,
    required this.onDriverWhatsApp,
  });

  Color _getStatusColor(String status) {
    return Color(AppConstants.statusColors[status] ?? 0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    // Check if user is admin - make it more explicit
    final isAdmin = user != null && user!.role == 'admin';
    

    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with booking ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.bookingId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    booking.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),

            // Booking details - compact layout
            _buildDetailRow('Pickup', dateFormat.format(booking.pickupDateTime)),
            _buildDetailRow('Route', booking.route),
            
            // Show supplier field for admin users only, hide it for supplier users
            if (user?.isAdmin == true) ...[
              if (booking.supplier != null && booking.supplier!.isNotEmpty)
                _buildDetailRow('Supplier', booking.supplier!),
            ],
            
            // Show form field for both admin and supplier users
            if (user?.isAdmin == true || user?.isSupplier == true) ...[
              if (booking.bookingFormName != null && booking.bookingFormName!.isNotEmpty)
                _buildDetailRow('Form', booking.bookingFormName!),
            ],
            
            // Only show Source and Price fields for admin users
            if (user?.isAdmin == true) ...[
              _buildDetailRow('Source', booking.isGoogleAds ? 'Google Ads' : 'Organic'),
              _buildDetailRow('Price', '${booking.price}'),
            ],
            
            _buildDetailRow('Payment', booking.paymentName ?? ''),
            _buildDetailRow('Earning', '${booking.earning}'),
            _buildDetailRow('Passengers', '${booking.passengersNumber}'),
            _buildDetailRow('Vehicle', booking.vehicleName ?? ''),
            _buildDetailRow('Name', booking.fullName),
            _buildDetailRow('Email', booking.emailAddress ?? ''),
            _buildDetailRow('Phone', booking.phoneNumber ?? ''),
            _buildDetailRow('WhatsApp', booking.whatsapp ?? ''),
            _buildDetailRow('Flight', booking.flightNumber ?? ''),
            
            if (booking.extras != null && booking.extras!.isNotEmpty)
              _buildDetailRow('Extras', booking.extras!.join(', ')),
            
            _buildDetailRow('Distance', booking.distance?.toString() ?? ''),
            
            if (booking.comment != null && booking.comment!.isNotEmpty)
              _buildDetailRow('Comment', booking.comment!),
            
            const SizedBox(height: 12),
            

            
            // Role-based button layout
            if (isAdmin) ...[
              // Admin sees all buttons - First row (4 buttons)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: Color(0xFF808080)),
                        foregroundColor: const Color(0xFF808080),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: null, // Disabled - does nothing
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF808080),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        disabledBackgroundColor: Colors.grey[400],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyBookingDetails(context),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Communication buttons - Second row (3 buttons)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onWhatsApp,
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onSupplierWhatsApp,
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Supplier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDriverWhatsApp,
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Driver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Supplier users see Edit button on first row, communication buttons on second row
              // First row - Edit button only
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: Color(0xFF808080)),
                        foregroundColor: const Color(0xFF808080),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Second row - Communication buttons (Client, Supplier, Driver)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onWhatsApp,
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onSupplierWhatsApp,
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Supplier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDriverWhatsApp,
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Driver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _copyBookingDetails(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    // Build the text to copy, excluding specified fields
    final List<String> details = [];
    
    // Add booking ID
    details.add('Booking ID: ${booking.bookingId}');
    
    // Add status
    details.add('Status: ${booking.status}');
    
    // Add pickup date/time
    details.add('Pickup: ${dateFormat.format(booking.pickupDateTime)}');
    
    // Add route
    details.add('Route: ${booking.route}');
    
    // Add payment
    if (booking.paymentName != null && booking.paymentName!.isNotEmpty) {
      details.add('Payment: ${booking.paymentName}');
    }
    
    // Add earning
    details.add('Earning: ${booking.earning}');
    
    // Add passengers
    details.add('Passengers: ${booking.passengersNumber}');
    
    // Add vehicle
    if (booking.vehicleName != null && booking.vehicleName!.isNotEmpty) {
      details.add('Vehicle: ${booking.vehicleName}');
    }
    
    // Add name
    details.add('Name: ${booking.fullName}');
    
    // Add email
    if (booking.emailAddress != null && booking.emailAddress!.isNotEmpty) {
      details.add('Email: ${booking.emailAddress}');
    }
    
    // Add phone
    if (booking.phoneNumber != null && booking.phoneNumber!.isNotEmpty) {
      details.add('Phone: ${booking.phoneNumber}');
    }
    
    // Add WhatsApp
    if (booking.whatsapp != null && booking.whatsapp!.isNotEmpty) {
      details.add('WhatsApp: ${booking.whatsapp}');
    }
    
    // Add flight
    if (booking.flightNumber != null && booking.flightNumber!.isNotEmpty) {
      details.add('Flight: ${booking.flightNumber}');
    }
    
    // Add extras
    if (booking.extras != null && booking.extras!.isNotEmpty) {
      details.add('Extras: ${booking.extras!.join(', ')}');
    }
    
    // Add distance
    if (booking.distance != null) {
      details.add('Distance: ${booking.distance}');
    }
    
    // Add comment
    if (booking.comment != null && booking.comment!.isNotEmpty) {
      details.add('Comment: ${booking.comment}');
    }
    
    // Note: Excluding Source, Price, Booking Form, and Supplier as requested
    
    // Join all details with line breaks
    final textToCopy = details.join('\n');
    
    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: textToCopy));
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking details copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
} 