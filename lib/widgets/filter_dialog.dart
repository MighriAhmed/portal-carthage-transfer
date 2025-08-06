import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portal_carthage_transfer/providers/booking_provider.dart';
import 'package:portal_carthage_transfer/providers/auth_provider.dart';

class FilterDialog extends StatefulWidget {
  final String selectedStatus;
  final String selectedSupplier;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String, String, DateTime?, DateTime?) onApply;

  const FilterDialog({
    super.key,
    required this.selectedStatus,
    required this.selectedSupplier,
    required this.startDate,
    required this.endDate,
    required this.onApply,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String _selectedStatus;
  late String _selectedSupplier;
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
    _selectedSupplier = widget.selectedSupplier;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = authProvider.user;

    return AlertDialog(
      title: const Text('Filter Bookings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status filter
            DropdownButtonFormField<String>(
              value: _selectedStatus.isEmpty ? null : _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('All Statuses'),
                ),
                if (user?.isAdmin == true) ...[
                  const DropdownMenuItem<String>(
                    value: 'Pending',
                    child: Text('Pending'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Confirmed',
                    child: Text('Confirmed'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Approved',
                    child: Text('Approved'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Canceled',
                    child: Text('Canceled'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Refund',
                    child: Text('Refund'),
                  ),
                ] else ...[
                  const DropdownMenuItem<String>(
                    value: 'Confirmed',
                    child: Text('Confirmed'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Approved',
                    child: Text('Approved'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                ],
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),

            // Supplier filter (admin only)
            if (user?.isAdmin == true) ...[
              DropdownButtonFormField<String>(
                value: _selectedSupplier.isEmpty ? null : _selectedSupplier,
                decoration: const InputDecoration(
                  labelText: 'Supplier',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('All Suppliers'),
                  ),
                  ...bookingProvider.suppliers.map((supplier) {
                    final name = supplier['supplier_name'] ?? supplier['username'] ?? supplier.toString();
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSupplier = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Start date
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(
                _startDate != null
                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                    : 'Select date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              },
            ),

            // End date
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(
                _endDate != null
                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                    : 'Select date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedStatus = '';
              _selectedSupplier = '';
              _startDate = null;
              _endDate = null;
            });
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_selectedStatus, _selectedSupplier, _startDate, _endDate);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
} 