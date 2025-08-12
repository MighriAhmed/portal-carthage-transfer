import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portal_carthage_transfer/providers/booking_provider.dart';
import 'package:portal_carthage_transfer/providers/auth_provider.dart';
import 'package:portal_carthage_transfer/models/booking.dart';

class BookingFormDialog extends StatefulWidget {
  final Booking? booking; // null for new booking, not null for editing

  const BookingFormDialog({
    super.key,
    this.booking,
  });

  @override
  State<BookingFormDialog> createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends State<BookingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bookingIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _flightNumberController = TextEditingController();
  final _commentController = TextEditingController();
  final _vehicleNameController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverContactController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _addressesController = TextEditingController();
  final _extrasController = TextEditingController();

  String _selectedStatus = 'Pending';
  String _selectedSupplier = '';
  String _selectedPayment = '';
  DateTime? _pickupDateTime;
  double _price = 0.0;
  double _earning = 0.0;
  int _passengersNumber = 1;
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      _loadBookingData(widget.booking!);
    } else {
      _pickupDateTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _flightNumberController.dispose();
    _commentController.dispose();
    _vehicleNameController.dispose();
    _driverNameController.dispose();
    _driverContactController.dispose();
    _plateNumberController.dispose();
    _addressesController.dispose();
    _extrasController.dispose();
    super.dispose();
  }

  void _loadBookingData(Booking booking) {
    _bookingIdController.text = booking.bookingId;
    _firstNameController.text = booking.firstName;
    _lastNameController.text = booking.lastName;
    _emailController.text = booking.emailAddress ?? '';
    _phoneController.text = booking.phoneNumber ?? '';
    _whatsappController.text = booking.whatsapp ?? '';
    _flightNumberController.text = booking.flightNumber ?? '';
    _commentController.text = booking.comment ?? '';
    _vehicleNameController.text = booking.vehicleName ?? '';
    _driverNameController.text = booking.driverName ?? '';
    _driverContactController.text = booking.driverContact ?? '';
    _plateNumberController.text = booking.plateNumber ?? '';
    _addressesController.text = booking.addresses.join(' → ');
    _extrasController.text = booking.extras?.join(', ') ?? '';
    
    _selectedStatus = booking.status;
    _selectedSupplier = booking.supplier ?? '';
    _selectedPayment = booking.paymentName ?? '';
    _pickupDateTime = booking.pickupDateTime;
    _price = booking.price;
    _earning = booking.earning;
    _passengersNumber = booking.passengersNumber;
    _distance = booking.distance ?? 0.0;
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
                      data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF4C542),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_pickupDateTime ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF4C542),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (time != null) {
        setState(() {
          _pickupDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // For supplier users, preserve original supplier and price values
    String supplierValue = _selectedSupplier;
    double priceValue = _price;
    
    if (user?.isSupplier == true && widget.booking != null) {
      // Keep original values for suppliers editing existing bookings
      supplierValue = widget.booking!.supplier ?? '';
      priceValue = widget.booking!.price;
    }
    
    final bookingData = {
      'booking_id': _bookingIdController.text.trim(),
      'status': _selectedStatus,
      'pickup_datetime': _pickupDateTime!.toString().substring(0, 19).replaceAll('T', ' '),
      'addresses': _addressesController.text.split('→').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'supplier': supplierValue.isEmpty ? '' : supplierValue,
      'booking_form_name': widget.booking?.bookingFormName ?? '',
      'price': priceValue,
      'earning': _earning,
      'passengers_number': _passengersNumber,
      'vehicle_name': _vehicleNameController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email_address': _emailController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'comment': _commentController.text.trim(),
      'payment_name': _selectedPayment.isEmpty ? '' : _selectedPayment,
      'flight_number': _flightNumberController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
      'distance': _distance,
      'driver_name': _driverNameController.text.trim(),
      'driver_contact': _driverContactController.text.trim(),
      'plate_number': _plateNumberController.text.trim(),
      'extras': _extrasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).join(', '),
    };

    bool success;
    if (widget.booking != null) {
      success = await bookingProvider.updateBooking(context, widget.booking!.id, bookingData);
    } else {
      success = await bookingProvider.addBooking(context, bookingData);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.booking != null ? 'Booking updated successfully' : 'Booking added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _duplicateBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Generate a new booking ID (you might want to implement a more sophisticated ID generation)
    final newBookingId = '${_bookingIdController.text.trim()}_copy';
    
    // For supplier users, preserve original supplier and price values
    String supplierValue = _selectedSupplier;
    double priceValue = _price;
    
    if (user?.isSupplier == true && widget.booking != null) {
      // Keep original values for suppliers duplicating existing bookings
      supplierValue = widget.booking!.supplier ?? '';
      priceValue = widget.booking!.price;
    }
    
    final bookingData = {
      'booking_id': newBookingId,
      'status': 'Pending', // Reset status to Pending for new booking
      'pickup_datetime': _pickupDateTime!.toString().substring(0, 19).replaceAll('T', ' '),
      'addresses': _addressesController.text.split('→').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'supplier': supplierValue.isEmpty ? '' : supplierValue,
      'booking_form_name': widget.booking?.bookingFormName ?? '',
      'price': priceValue,
      'earning': _earning,
      'passengers_number': _passengersNumber,
      'vehicle_name': _vehicleNameController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email_address': _emailController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'comment': _commentController.text.trim(),
      'payment_name': _selectedPayment.isEmpty ? '' : _selectedPayment,
      'flight_number': _flightNumberController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
      'distance': _distance,
      'driver_name': _driverNameController.text.trim(),
      'driver_contact': _driverContactController.text.trim(),
      'plate_number': _plateNumberController.text.trim(),
      'extras': _extrasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).join(', '),
    };


    
    final success = await bookingProvider.addBooking(context, bookingData);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking duplicated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF808080),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLines,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF808080), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: const TextStyle(color: Color(0xFF808080)),
        ),
        validator: validator ?? (isRequired ? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        } : null),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF808080), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: const TextStyle(color: Color(0xFF808080)),
        ),
        items: items,
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF808080)),
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildDateTimeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: _selectDateTime,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF808080)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pickup Date & Time *',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF808080),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _pickupDateTime != null
                          ? '${_pickupDateTime!.day}/${_pickupDateTime!.month}/${_pickupDateTime!.year} ${_pickupDateTime!.hour}:${_pickupDateTime!.minute.toString().padLeft(2, '0')}'
                          : 'Select date and time',
                      style: TextStyle(
                        fontSize: 16,
                        color: _pickupDateTime != null ? Colors.black87 : Colors.grey[600],
                        fontWeight: _pickupDateTime != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF808080)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isMobile ? double.infinity : 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.booking != null ? 'Edit Booking' : 'Add Booking',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.black87),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionTitle('Basic Information'),
                      
                      _buildFormField(
                        label: 'Booking ID',
                        controller: _bookingIdController,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter booking ID';
                          }
                          return null;
                        },
                      ),

                      _buildDropdownField(
                        label: 'Status',
                        value: _selectedStatus,
                        items: const [
                          DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                          DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                          DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'Canceled', child: Text('Canceled')),
                          DropdownMenuItem(value: 'Refund', child: Text('Refund')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),

                      // Supplier Selection with clarification - hidden for supplier users
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.user;
                          // Only show supplier field for admin users, not for supplier users
                          if (user?.isAdmin == true) {
                            return Consumer<BookingProvider>(
                              builder: (context, bookingProvider, child) {
                                return _buildDropdownField(
                                  label: 'Supplier (Select existing or leave empty)',
                                  value: _selectedSupplier,
                                  items: [
                                    const DropdownMenuItem<String>(value: '', child: Text('No Supplier')),
                                    ...bookingProvider.suppliers.map<DropdownMenuItem<String>>((supplier) {
                                      final name = supplier['name'] ?? supplier['supplier_name'] ?? supplier['username'] ?? supplier.toString();
                                      return DropdownMenuItem<String>(
                                        value: name,
                                        child: Text(name),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSupplier = value ?? '';
                                    });
                                  },
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink(); // Hide the field for supplier users
                        },
                      ),

                      _buildDateTimeField(),

                      _buildFormField(
                        label: 'Route',
                        controller: _addressesController,
                        isRequired: true,
                        hintText: 'Address 1 → Address 2 → Address 3',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter route';
                          }
                          return null;
                        },
                      ),

                      // Customer Information Section
                      _buildSectionTitle('Customer Information'),
                      
                      _buildFormField(
                        label: 'First Name',
                        controller: _firstNameController,
                        isRequired: true,
                      ),

                      _buildFormField(
                        label: 'Last Name',
                        controller: _lastNameController,
                        isRequired: true,
                      ),

                      _buildFormField(
                        label: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      _buildFormField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),

                      _buildFormField(
                        label: 'WhatsApp',
                        controller: _whatsappController,
                        keyboardType: TextInputType.phone,
                      ),

                      _buildFormField(
                        label: 'Flight Number',
                        controller: _flightNumberController,
                      ),

                      // Vehicle & Payment Section
                      _buildSectionTitle('Vehicle & Payment'),
                      
                      _buildFormField(
                        label: 'Vehicle Name',
                        controller: _vehicleNameController,
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: TextEditingController(text: _passengersNumber.toString()),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Passengers *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF808080), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            labelStyle: const TextStyle(color: Color(0xFF808080)),
                          ),
                          onChanged: (value) {
                            _passengersNumber = int.tryParse(value) ?? 1;
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: TextEditingController(text: _distance.toString()),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Distance',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF808080), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            labelStyle: const TextStyle(color: Color(0xFF808080)),
                          ),
                          onChanged: (value) {
                            _distance = double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ),

                      // Price field - hidden for supplier users
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.user;
                          // Only show price field for admin users, not for supplier users
                          if (user?.isAdmin == true) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TextFormField(
                                controller: TextEditingController(text: _price.toString()),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF808080), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  labelStyle: const TextStyle(color: Color(0xFF808080)),
                                ),
                                onChanged: (value) {
                                  _price = double.tryParse(value) ?? 0.0;
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink(); // Hide the field for supplier users
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: TextEditingController(text: _earning.toString()),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Earning',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF808080), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            labelStyle: const TextStyle(color: Color(0xFF808080)),
                          ),
                          onChanged: (value) {
                            _earning = double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ),

                      _buildDropdownField(
                        label: 'Payment Method',
                        value: _selectedPayment,
                        items: const [
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'Online', child: Text('Online')),
                          DropdownMenuItem(value: 'Card', child: Text('Card')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPayment = value ?? '';
                          });
                        },
                      ),

                      // Driver Information Section
                      _buildSectionTitle('Driver Information'),
                      
                      _buildFormField(
                        label: 'Driver Name',
                        controller: _driverNameController,
                      ),

                      _buildFormField(
                        label: 'Driver Contact',
                        controller: _driverContactController,
                        keyboardType: TextInputType.phone,
                      ),

                      _buildFormField(
                        label: 'Plate Number',
                        controller: _plateNumberController,
                      ),

                      // Additional Information Section
                      _buildSectionTitle('Additional Information'),
                      
                      _buildFormField(
                        label: 'Extras',
                        controller: _extrasController,
                        hintText: 'Separate with commas (e.g., water, child seat)',
                      ),

                      _buildFormField(
                        label: 'Comments',
                        controller: _commentController,
                        maxLines: 3,
                        hintText: 'Additional notes or special requests',
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: widget.booking != null 
                ? Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final user = authProvider.user;
                      final isAdmin = user?.isAdmin == true;
                      
                      return Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Color(0xFF808080)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF808080),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          // Spacing between buttons
                          if (isAdmin) const SizedBox(width: 12),
                          
                          // Duplicate button - only for admin users
                          if (isAdmin)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: bookingProvider.isLoading ? null : _duplicateBooking,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF808080),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: bookingProvider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Duplicate',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          
                          // Spacing between buttons
                          const SizedBox(width: 12),
                          
                          // Update button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: bookingProvider.isLoading ? null : _saveBooking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF808080),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: bookingProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Update',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF808080)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF808080),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: bookingProvider.isLoading ? null : _saveBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF808080),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: bookingProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 