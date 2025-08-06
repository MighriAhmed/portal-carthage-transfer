# Quick Setup Guide

## Prerequisites Check

Before starting, ensure you have:

- [ ] Flutter SDK installed (`flutter doctor`)
- [ ] Your React app running on `http://localhost:3000`
- [ ] Your backend API running on `http://localhost:8000`
- [ ] Android Studio / VS Code with Flutter extensions

## Quick Start

1. **Navigate to the Flutter app directory:**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API URLs** (if different from defaults):
   
   Edit `lib/utils/constants.dart`:
   ```dart
   static const String baseUrl = 'http://your-backend-url:8000';
   ```
   
   Edit `lib/screens/webview_screen.dart`:
   ```dart
   ..loadRequest(Uri.parse('http://your-react-app-url:3000'));
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Testing the App

1. **Login**: Use the same credentials as your React app
2. **Choose Experience**: Select between WebView and Native modes
3. **Test Features**: Try booking management, WhatsApp integration, etc.

## Common Issues & Solutions

### "Connection refused" error
- Ensure your backend is running on the correct port
- Check firewall settings
- Verify the API URL in `constants.dart`

### WebView not loading
- Ensure your React app is running
- Check the URL in `webview_screen.dart`
- Verify CORS settings on your React app

### Authentication issues
- Verify JWT token format matches your backend
- Check token expiration handling
- Ensure secure storage permissions

## Next Steps

1. **Customize the theme** in `lib/main.dart`
2. **Add your logo** to the assets folder
3. **Test on different devices** (Android/iOS)
4. **Build for production** when ready

## Support

If you encounter issues:
1. Check the main README.md for detailed documentation
2. Run `flutter doctor` to verify your setup
3. Check the troubleshooting section in the README 