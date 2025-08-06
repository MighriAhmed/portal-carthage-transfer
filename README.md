# Carthage Transfer Mobile App

A Flutter mobile application for the Carthage Transfer booking management system. This app provides two different approaches to interact with your existing React web application and backend API.

## Features

### 🔄 Dual Approach Architecture

1. **WebView Experience**: Embed your existing React web app in a mobile-optimized WebView
2. **Native Flutter Experience**: Fully native mobile interface with direct API integration

### 📱 Core Features

- **Authentication**: JWT-based login with secure token storage
- **Booking Management**: View, filter, add, edit, and delete bookings
- **Supplier Management**: Add and manage suppliers (admin only)
- **WhatsApp Integration**: Send messages to clients, suppliers, and drivers
- **Multi-language Support**: English, French, and German WhatsApp messages
- **Role-based Access**: Different features for admin and supplier users
- **Real-time Updates**: Live data synchronization with your backend

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Your existing React app running on `http://localhost:3000`
- Your backend API running on `http://localhost:8000`

## Installation

1. **Clone or navigate to the Flutter app directory:**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints:**
   Edit `lib/utils/constants.dart` and update the URLs:
   ```dart
   static const String baseUrl = 'http://your-backend-url:8000';
   ```

4. **For WebView mode, update the React app URL:**
   Edit `lib/screens/webview_screen.dart`:
   ```dart
   ..loadRequest(Uri.parse('http://your-react-app-url:3000'));
   ```

## Configuration

### API Configuration

Update the following in `lib/utils/constants.dart`:

```dart
// Change these to match your backend URLs
static const String baseUrl = 'http://localhost:8000';
static const String reactAppUrl = 'http://localhost:3000';
```

### Authentication Headers

The app automatically handles authentication headers. Make sure your backend accepts the same JWT token format as your React app.

## Usage

### Starting the App

```bash
flutter run
```

### App Flow

1. **Splash Screen**: Checks authentication status
2. **Login Screen**: Enter credentials (same as your React app)
3. **Home Screen**: Choose between WebView and Native experiences
4. **WebView Mode**: Full React app experience in mobile
5. **Native Mode**: Optimized mobile interface

### WebView Mode

- Embeds your existing React application
- Maintains all existing functionality
- Automatic token injection for seamless authentication
- Mobile-optimized navigation

### Native Mode

- **Booking List**: View all bookings with filtering options
- **Search**: Search by booking ID
- **Filters**: Filter by status, supplier, and date range
- **Actions**: Edit, delete, and manage bookings
- **WhatsApp**: Send messages in multiple languages
- **Add Booking**: Create new bookings with full form
- **Add Supplier**: Manage suppliers (admin only)

## Architecture

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   └── booking.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── booking_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── webview_screen.dart
│   └── booking_list_screen.dart
├── widgets/                  # Reusable widgets
│   ├── booking_card.dart
│   ├── filter_dialog.dart
│   ├── booking_form_dialog.dart
│   └── supplier_form_dialog.dart
└── utils/
    └── constants.dart        # App constants
```

### State Management

- **Provider Pattern**: Used for state management
- **AuthProvider**: Handles authentication and user state
- **BookingProvider**: Manages booking data and API calls

### API Integration

The app uses the same API endpoints as your React application:

- `POST /token` - Authentication
- `GET /bookings` - Fetch bookings
- `GET /latest_bookings` - Fetch latest bookings
- `PUT /bookings/{id}` - Update booking
- `POST /bookings` - Create booking
- `DELETE /bookings/{id}` - Delete booking
- `GET /suppliers` - Fetch suppliers
- `POST /suppliers` - Add supplier

## Key Features Explained

### Authentication

- JWT token storage using `flutter_secure_storage`
- Automatic token validation and refresh
- Secure logout functionality

### WhatsApp Integration

- Multi-language message templates
- Direct WhatsApp app integration
- Support for client, supplier, and driver contacts

### Booking Management

- Full CRUD operations
- Advanced filtering and search
- Real-time status updates
- Print functionality (web only)

### Responsive Design

- Material Design 3 components
- Mobile-optimized layouts
- Touch-friendly interfaces

## Customization

### Theme

Update the theme in `lib/main.dart`:

```dart
theme: ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: const Color(0xFF7B7D7D),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF7B7D7D),
    secondary: const Color(0xFFE4B454),
  ),
  // ... more theme customization
),
```

### API Endpoints

Modify `lib/utils/constants.dart` to match your backend:

```dart
static const String baseUrl = 'https://your-api-domain.com';
static const String apiUrl = '$baseUrl';
```

### WhatsApp Messages

Customize message templates in `lib/screens/booking_list_screen.dart`:

```dart
String message = '';
switch (language) {
  case 'en':
    message = 'Your English message template';
    break;
  case 'fr':
    message = 'Your French message template';
    break;
  case 'de':
    message = 'Your German message template';
    break;
}
```

## Building for Production

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web (Optional)

```bash
flutter build web
```

## Troubleshooting

### Common Issues

1. **API Connection Error**
   - Check if your backend is running
   - Verify API URLs in `constants.dart`
   - Ensure CORS is properly configured

2. **Authentication Issues**
   - Verify JWT token format matches your backend
   - Check token expiration handling
   - Ensure secure storage permissions

3. **WebView Issues**
   - Verify React app is running
   - Check WebView permissions
   - Ensure proper URL configuration

### Debug Mode

Run in debug mode for detailed logs:

```bash
flutter run --debug
```

## Dependencies

Key dependencies used:

- `webview_flutter`: WebView integration
- `http`: API communication
- `provider`: State management
- `flutter_secure_storage`: Secure token storage
- `jwt_decoder`: JWT token handling
- `url_launcher`: WhatsApp integration
- `intl`: Date formatting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the Carthage Transfer booking management system.

## Support

For support and questions:
- Check the troubleshooting section
- Review the API documentation
- Contact the development team

---

**Note**: This Flutter app is designed to work seamlessly with your existing React application and backend API. Make sure both your React app and backend are running before testing the mobile app. 