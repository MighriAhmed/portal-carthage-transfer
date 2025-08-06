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
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with booking ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.bookingId,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith( // Reduced from headlineSmall
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced padding
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13, // Reduced from 14
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Booking details in a more compact format
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Pickup', dateFormat.format(booking.pickupDateTime)),
                _buildDetailRow('Route', booking.route),
                
                if (user?.isAdmin == true || user?.isSupplier == true) ...[
                  if (booking.supplier != null && booking.supplier!.isNotEmpty)
                    _buildDetailRow('Supplier', booking.supplier!),
                  if (booking.bookingFormName != null && booking.bookingFormName!.isNotEmpty)
                    _buildDetailRow('Form', booking.bookingFormName!),
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
              ],
            ),

            const SizedBox(height: 8),

            // Action buttons - more compact layout
            Column(
              children: [
                // First row of buttons - more compact
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16), // Reduced from 18
                        label: const Text('Edit', style: TextStyle(fontSize: 13)), // Reduced from 14
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 10
                        ),
                      ),
                    ),
                    if (user?.isAdmin == true) ...[
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _copyBookingDetails(context),
                          icon: const Icon(Icons.copy, size: 16), // Reduced from 18
                          label: const Text('Copy', style: TextStyle(fontSize: 13)), // Reduced from 14
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 10
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle view post
                            if (booking.bookingFormName == "CTR") {
                              // Open CTR post
                            } else if (booking.bookingFormName == "ATT") {
                              // Open ATT post
                            }
                          },
                          icon: const Icon(Icons.visibility, size: 16), // Reduced from 18
                          label: const Text('View', style: TextStyle(fontSize: 13)), // Reduced from 14
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 10
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 16), // Reduced from 18
                          label: const Text('Delete', style: TextStyle(fontSize: 13)), // Reduced from 14
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 10
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                
                // Second row of WhatsApp buttons - more compact
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onWhatsApp,
                        icon: const Icon(Icons.message, size: 16), // Reduced from 18
                        label: const Text('Client', style: TextStyle(fontSize: 13)), // Reduced from 14
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 10
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSupplierWhatsApp,
                        icon: const Icon(Icons.message, size: 16), // Reduced from 18
                        label: const Text('Supplier', style: TextStyle(fontSize: 13)), // Reduced from 14
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 10
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDriverWhatsApp,
                        icon: const Icon(Icons.message, size: 16), // Reduced from 18
                        label: const Text('Driver', style: TextStyle(fontSize: 13)), // Reduced from 14
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 10
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 3), // Reduced from 4
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75, // Reduced from 80
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14, // Reduced from 15
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14), // Reduced from 15
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