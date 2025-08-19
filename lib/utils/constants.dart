class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://192.168.1.5:8000'; // Direct connection to backend
  static const String apiUrl = baseUrl;
  
  // API Endpoints
  static const String loginEndpoint = '/token';
  static const String bookingsEndpoint = '/bookings';
  static const String allBookingsEndpoint = '/all_bookings';
  static const String latestBookingsEndpoint = '/latest_bookings';
  static const String poolBookingsEndpoint = '/pool_bookings'; // New endpoint for unassigned bookings
  static const String suppliersEndpoint = '/suppliers';
  
  // WordPress Admin URLs
  static const String ctrWordPressAdminUrl = 'https://carthage-transfer.com/wp-admin/post.php?action=edit&post=';
  static const String attWordPressAdminUrl = 'https://airporttransfertunisia.com/wp-admin/post.php?action=edit&post=';
  
  // App Configuration
  static const String appName = 'Carthage Transfer';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  
  // Status Colors
  static const Map<String, int> statusColors = {
    'Pending': 0xFFFFA500,
    'Confirmed': 0xFF4CAF50,
    'Completed': 0xFF2196F3,
    'Approved': 0xFF9C27B0,
    'Canceled': 0xFFF44336,
    'Refund': 0xFF607D8B,
  };
  
  // WhatsApp Configuration
  static const String whatsappBaseUrl = 'https://wa.me/';
  
  // Default date format
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
} 