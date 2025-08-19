import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:portal_carthage_transfer/models/booking.dart';
import 'package:portal_carthage_transfer/providers/auth_provider.dart';
import 'package:portal_carthage_transfer/utils/constants.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  List<Map<String, dynamic>> _suppliers = [];
  bool _isLoading = false;
  String? _error;
  bool _isLatest = false;

  List<Booking> get bookings => _bookings;
  List<Map<String, dynamic>> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLatest => _isLatest;

  // Fetch bookings with filters
  Future<void> fetchBookings(
    BuildContext context, {
    String? bookingId,
    String? status,
    String? supplier,
    DateTime? startDate,
    DateTime? endDate,
    bool setLoading = true,
    bool isSupplier = false,
  }) async {
    
    // Special handling for suppliers to get all bookings
    if (isSupplier) {
      await _fetchAllBookingsForSupplier(context, bookingId, status, setLoading);
      return;
    }
    try {
      if (setLoading) {
        _isLoading = true;
        _error = null;
        if (context.mounted) {
          notifyListeners();
        }
      }

      final queryParams = <String, String>{};
      if (bookingId != null && bookingId.isNotEmpty) {
        queryParams['booking_id'] = bookingId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (supplier != null && supplier.isNotEmpty) {
        queryParams['supplier'] = supplier;
      }
      if (startDate != null) {
        queryParams['start_date'] = _formatDateForBackend(startDate);
      }
      if (endDate != null) {
        queryParams['end_date'] = _formatDateForBackend(endDate);
      }
      
      // For suppliers, try to get all bookings by adding special parameters
      if (isSupplier) {
        queryParams['all_bookings'] = 'true';
        queryParams['show_all'] = 'true';
        queryParams['include_all'] = 'true';
      }

      // Use different endpoint for suppliers to get all bookings
      String endpoint = AppConstants.bookingsEndpoint;
      if (isSupplier) {
        endpoint = AppConstants.allBookingsEndpoint;
      }
      
      final uri = Uri.parse('${AppConstants.apiUrl}$endpoint')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getAuthHeaders(context));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        
        // Handle different response formats
        List<dynamic> data;
        if (responseData is List) {
          // Direct list response
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Object response with data property
          if (responseData.containsKey('data')) {
            data = responseData['data'] is List ? responseData['data'] : [];
          } else if (responseData.containsKey('bookings')) {
            data = responseData['bookings'] is List ? responseData['bookings'] : [];
          } else if (responseData.containsKey('results')) {
            data = responseData['results'] is List ? responseData['results'] : [];
          } else {
            // Single object or empty response
            data = [];
          }
        } else {
          data = [];
        }
        
        _bookings = data.map((json) => Booking.fromJson(json)).toList();
        _isLatest = false;
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
        _bookings = [];
      } else {
        _error = 'Failed to load bookings (Status: ${response.statusCode})';
        _bookings = [];
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _bookings = [];
    } finally {
      if (setLoading) {
        _isLoading = false;
        if (context.mounted) {
          notifyListeners();
        }
      }
    }
  }

  // Fetch latest bookings
  Future<void> fetchLatestBookings(
    BuildContext context, {
    DateTime? fromDate,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final queryParams = <String, String>{};
      if (fromDate != null) {
        queryParams['from_date'] = _formatDateForBackend(fromDate);
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('${AppConstants.apiUrl}${AppConstants.latestBookingsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getAuthHeaders(context));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        
        // Handle different response formats
        List<dynamic> data;
        if (responseData is List) {
          // Direct list response
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Object response with data property
          if (responseData.containsKey('data')) {
            data = responseData['data'] is List ? responseData['data'] : [];
          } else if (responseData.containsKey('bookings')) {
            data = responseData['bookings'] is List ? responseData['bookings'] : [];
          } else if (responseData.containsKey('results')) {
            data = responseData['results'] is List ? responseData['results'] : [];
          } else {
            // Single object or empty response
            data = [];
          }
        } else {
          data = [];
        }
        
        _bookings = data.map((json) => Booking.fromJson(json)).toList();
        _isLatest = true;
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
        _bookings = [];
      } else {
        _error = 'Failed to load latest bookings (Status: ${response.statusCode})';
        _bookings = [];
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _bookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch pool bookings (unassigned bookings for suppliers)
  Future<void> fetchPoolBookings(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      _isLatest = false;
      if (context.mounted) {
        notifyListeners();
      }

      final uri = Uri.parse('${AppConstants.apiUrl}${AppConstants.poolBookingsEndpoint}');
      final response = await http.get(uri, headers: _getAuthHeaders(context));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        
        List<dynamic> data;
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            data = responseData['data'] is List ? responseData['data'] : [];
          } else if (responseData.containsKey('bookings')) {
            data = responseData['bookings'] is List ? responseData['bookings'] : [];
          } else if (responseData.containsKey('results')) {
            data = responseData['results'] is List ? responseData['results'] : [];
          } else {
            data = [];
          }
        } else {
          data = [];
        }

        _bookings = data.map((json) => Booking.fromJson(json)).toList();
        _error = null;
      } else {
        _error = 'Failed to load pool bookings: ${response.statusCode}';
        _bookings = [];
      }
    } catch (e) {
      _error = 'Error loading pool bookings: $e';
      _bookings = [];
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  // Accept a pool booking (assign to supplier)
  Future<bool> acceptPoolBooking(BuildContext context, String bookingId) async {
    try {
      _isLoading = true;
      if (context.mounted) {
        notifyListeners();
      }

      final uri = Uri.parse('${AppConstants.apiUrl}${AppConstants.bookingsEndpoint}/$bookingId/accept');
      final response = await http.post(uri, headers: _getAuthHeaders(context));

      if (response.statusCode == 200) {
        // Remove the accepted booking from the pool
        _bookings.removeWhere((booking) => booking.id == bookingId);
        if (context.mounted) {
          notifyListeners();
        }
        return true;
      } else {
        _error = 'Failed to accept booking: ${response.statusCode}';
        if (context.mounted) {
          notifyListeners();
        }
        return false;
      }
    } catch (e) {
      _error = 'Error accepting booking: $e';
      if (context.mounted) {
        notifyListeners();
      }
      return false;
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  // Fetch suppliers (admin only)
  Future<void> fetchSuppliers(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiUrl}${AppConstants.suppliersEndpoint}'),
        headers: _getAuthHeaders(context),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _suppliers = List<Map<String, dynamic>>.from(data['suppliers'] ?? []);
        // Notify listeners that suppliers data has changed
        if (context.mounted) {
          notifyListeners();
        }
      }
    } catch (e) {
      // Don't show error for suppliers fetch
    }
  }

  // Update booking
  Future<bool> updateBooking(BuildContext context, String bookingId, Map<String, dynamic> updateData) async {
    try {
      _isLoading = true;
      if (context.mounted) {
        notifyListeners();
      }
      
      final response = await http.put(
        Uri.parse('${AppConstants.apiUrl}${AppConstants.bookingsEndpoint}/$bookingId'),
        headers: _getAuthHeaders(context),
        body: jsonEncode(updateData),
      );
      


      if (response.statusCode == 200) {
        // Refresh the current list
        if (context.mounted) {
          if (_isLatest) {
            await fetchLatestBookings(context);
          } else {
            await fetchBookings(context);
          }
        }
        return true;
      } else {
        _error = 'Failed to update booking';
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  // Add new booking
  Future<bool> addBooking(BuildContext context, Map<String, dynamic> bookingData) async {
    try {
      _isLoading = true;
      if (context.mounted) {
        notifyListeners();
      }

      final response = await http.post(
        Uri.parse('${AppConstants.apiUrl}${AppConstants.bookingsEndpoint}'),
        headers: _getAuthHeaders(context),
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (context.mounted) {
          await fetchBookings(context);
        }
        return true;
      } else {
        _error = 'Failed to add booking';
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  // Delete booking
  Future<bool> deleteBooking(BuildContext context, String bookingId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.delete(
        Uri.parse('${AppConstants.apiUrl}${AppConstants.bookingsEndpoint}/$bookingId'),
        headers: _getAuthHeaders(context),
      );



      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove the booking from the local list immediately
        _bookings.removeWhere((booking) => booking.id == bookingId);
        _error = null; // Clear any previous errors
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete booking (Status: ${response.statusCode})';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add supplier
  Future<bool> addSupplier(BuildContext context, Map<String, dynamic> supplierData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${AppConstants.apiUrl}${AppConstants.suppliersEndpoint}'),
        headers: _getAuthHeaders(context),
        body: jsonEncode(supplierData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchSuppliers(context);
        return true;
      } else {
        // Parse error response for better error message
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('detail')) {
              _error = 'Failed to add supplier: ${errorData['detail']}';
            } else if (errorData.containsKey('message')) {
              _error = 'Failed to add supplier: ${errorData['message']}';
            } else {
              _error = 'Failed to add supplier (Status: ${response.statusCode})';
            }
          } else {
            _error = 'Failed to add supplier (Status: ${response.statusCode})';
          }
        } catch (e) {
          _error = 'Failed to add supplier (Status: ${response.statusCode})';
        }
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update supplier
  Future<bool> updateSupplier(BuildContext context, String supplierName, Map<String, dynamic> updateData) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get auth headers and add Content-Type
      final headers = Map<String, String>.from(_getAuthHeaders(context));
      headers['Content-Type'] = 'application/json';

      // Create the update data with the supplier name as identifier
      final dataToSend = Map<String, dynamic>.from(updateData);
      
      // Use PUT method on /suppliers/{id} endpoint
      final url = '${AppConstants.apiUrl}${AppConstants.suppliersEndpoint}/$supplierName';
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(dataToSend),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Refresh the suppliers list
        await fetchSuppliers(context);
        return true;
      } else {
        // Parse error response for better error message
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic>) {
            if (errorData.containsKey('detail')) {
              _error = 'Failed to update supplier: ${errorData['detail']}';
            } else if (errorData.containsKey('message')) {
              _error = 'Failed to update supplier: ${errorData['message']}';
            } else {
              _error = 'Failed to update supplier (Status: ${response.statusCode})';
            }
          } else {
            _error = 'Failed to update supplier (Status: ${response.statusCode})';
          }
        } catch (e) {
          _error = 'Failed to update supplier (Status: ${response.statusCode})';
        }
        
        // Show error to user
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_error ?? 'Failed to update supplier'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }



  // Helper methods
  String _formatDateForBackend(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Map<String, String> _getAuthHeaders(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.authHeaders;
  }

  // Get supplier phone number
  String? getSupplierPhone(String supplierName) {
    if (supplierName.isEmpty) return null;
    
    final normalized = supplierName.trim().toLowerCase();
    final supplier = _suppliers.firstWhere(
      (s) {
        final name = s['supplier_name']?.toString().toLowerCase() ?? '';
        final username = s['username']?.toString().toLowerCase() ?? '';
        return name == normalized || username == normalized;
      },
      orElse: () => <String, dynamic>{},
    );
    
    return supplier['phone_number'];
  }

  // Special method for suppliers to fetch all bookings
  Future<void> _fetchAllBookingsForSupplier(
    BuildContext context,
    String? bookingId,
    String? status,
    bool setLoading,
  ) async {
    try {
      if (setLoading) {
        _isLoading = true;
        _error = null;
        if (context.mounted) {
          notifyListeners();
        }
      }

      // Try multiple endpoints and parameters to get all bookings
      final endpoints = [
        '/bookings',
        '/all_bookings',
        '/bookings/all',
        '/admin/bookings',
        '/bookings?all=true',
        '/bookings?supplier=all',
        '/bookings?view=all',
      ];

      final queryParams = <String, String>{};
      if (bookingId != null && bookingId.isNotEmpty) {
        queryParams['booking_id'] = bookingId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // Try different parameter combinations
      final parameterSets = [
        <String, String>{}, // No additional parameters
        <String, String>{'all_bookings': 'true'},
        <String, String>{'show_all': 'true'},
        <String, String>{'include_all': 'true'},
        <String, String>{'admin_view': 'true'},
        <String, String>{'force_all': 'true'},
        <String, String>{'supplier': 'all'},
        <String, String>{'view': 'all'},
        <String, String>{'all': 'true'},
        <String, String>{'filter': 'none'},
        <String, String>{'supplier_filter': 'none'},
      ];

      for (final endpoint in endpoints) {
        for (final params in parameterSets) {
          final testParams = Map<String, String>.from(queryParams);
          testParams.addAll(params);
          
          final uri = Uri.parse('${AppConstants.apiUrl}$endpoint')
              .replace(queryParameters: testParams);
          
          try {
            final response = await http.get(uri, headers: _getAuthHeaders(context));
            
            if (response.statusCode == 200) {
              final dynamic responseData = jsonDecode(response.body);
              
              // Handle different response formats
              List<dynamic> data;
              if (responseData is List) {
                data = responseData;
              } else if (responseData is Map<String, dynamic>) {
                if (responseData.containsKey('data')) {
                  data = responseData['data'] is List ? responseData['data'] : [];
                } else if (responseData.containsKey('bookings')) {
                  data = responseData['bookings'] is List ? responseData['bookings'] : [];
                } else if (responseData.containsKey('results')) {
                  data = responseData['results'] is List ? responseData['results'] : [];
                } else {
                  data = [];
                }
              } else {
                data = [];
              }
              
              if (data.isNotEmpty) {
                _bookings = data.map((json) => Booking.fromJson(json)).toList();
                _isLatest = false;
                _error = null;
                if (context.mounted) {
                  notifyListeners();
                }
                return; // Success, exit
              }
            }
          } catch (e) {
            // Continue to next endpoint/parameter combination
          }
        }
      }
      
      // If we get here, no endpoint worked
      _bookings = [];
      _error = 'No bookings found for supplier. Please contact administrator.';
      if (context.mounted) {
        notifyListeners();
      }
      
    } catch (e) {
      _error = 'Error fetching bookings for supplier: ${e.toString()}';
      _bookings = [];
      if (context.mounted) {
        notifyListeners();
      }
    } finally {
      if (setLoading) {
        _isLoading = false;
        if (context.mounted) {
          notifyListeners();
        }
      }
    }
  }



} 