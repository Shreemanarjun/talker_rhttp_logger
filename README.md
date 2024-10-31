# 🚀 talker_rhttp_logger

A powerful HTTP logging interceptor for [rhttp](https://pub.dev/packages/rhttp) that seamlessly integrates with [Talker](https://pub.dev/packages/talker). Debug your HTTP traffic with detailed, customizable logging!

## ✨ Key Features

- 🔍 **Comprehensive HTTP Logging** - Log requests, responses, and errors
- 🎨 **Colorful Output** - Customizable colors for different log types
- ⚡ **Request/Response Filtering** - Control exactly what gets logged
- 🛠 **Flexible Configuration** - Fine-tune every aspect of logging
- 🎯 **Performance Focused** - Minimal overhead logging

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  talker_rhttp_logger: ^latest_version  # Replace with latest version
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

```dart
import 'package:talker_rhttp_logger/talker_rhttp_logger.dart';
import 'package:talker/talker.dart';
import 'package:rhttp/rhttp.dart';

void main() {
  // Initialize Talker
  final talker = Talker();
  
  // Create HTTP client with logging
  final client = RHttpClient(
    interceptors: [
      TalkerRHttpLoggerInterceptor(
        talker: talker,
      ),
    ],
  );

  // Make requests - logs will appear automatically!
}
```

## ⚙️ Configuration Options

### Basic Configuration

```dart
final settings = TalkerRhttpLoggerSettings(
  // Response logging options
  printResponseData: true,      // Log response body
  printResponseHeaders: false,  // Log response headers
  printResponseMessage: true,   // Log response status message
  
  // Request logging options
  printRequestData: true,       // Log request body
  printRequestHeaders: false,   // Log request headers
  
  // Error logging options
  printErrorData: true,         // Log error response body
  printErrorHeaders: true,      // Log error response headers
  printErrorMessage: true,      // Log error messages
);

final logger = TalkerRHttpLoggerInterceptor(
  talker: talker,
  settings: settings,
);
```

### 🎨 Custom Colors

Make your logs visually distinctive with custom colors:

```dart
final settings = TalkerRhttpLoggerSettings(
  // Blue for requests
  requestPen: AnsiPen()..blue(),
  
  // Green for successful responses
  responsePen: AnsiPen()..green(),
  
  // Red for errors
  errorPen: AnsiPen()..red(),
);
```

### 🎯 Selective Logging

Control exactly what gets logged using filter functions:

```dart
final settings = TalkerRhttpLoggerSettings(
  // Filter requests
  requestFilter: (request) {
    // Only log API requests
    return request.url.path.startsWith('/api/');
  },
  
  // Filter responses
  responseFilter: (response) {
    // Only log non-200 responses
    return response.statusCode != 200;
  },
  
  // Filter errors
  errorFilter: (error) {
    // Only log timeout errors
    return error.type == RhttpExceptionType.connectTimeout;
  },
);
```

## 🔒 Security Best Practices

1. **Minimize Sensitive Data Logging**
```dart
final settings = TalkerRhttpLoggerSettings(
  // Disable headers and body logging
  printRequestHeaders: false,
  printResponseHeaders: false,
  printRequestData: false,
  printResponseData: false,
);
```

2. **Filter Sensitive Endpoints**
```dart
final settings = TalkerRhttpLoggerSettings(
  requestFilter: (request) {
    // Skip logging of sensitive endpoints
    final sensitiveEndpoints = ['/auth', '/payment', '/users'];
    return !sensitiveEndpoints.any(
      (endpoint) => request.url.path.contains(endpoint),
    );
  },
);
```

3. **Selective Error Logging**
```dart
final settings = TalkerRhttpLoggerSettings(
  // Only log error messages, not full error data
  printErrorData: false,
  printErrorHeaders: false,
  printErrorMessage: true,
);
```

## 📝 Full Settings Reference

```dart
TalkerRhttpLoggerSettings({
  // Response Settings
  bool printResponseData = true,
  bool printResponseHeaders = false,
  bool printResponseMessage = true,
  
  // Error Settings
  bool printErrorData = true,
  bool printErrorHeaders = true,
  bool printErrorMessage = true,
  
  // Request Settings
  bool printRequestData = true,
  bool printRequestHeaders = false,
  
  // Custom Colors
  AnsiPen? requestPen,
  AnsiPen? responsePen,
  AnsiPen? errorPen,
  
  // Custom Filters
  bool Function(HttpRequest request)? requestFilter,
  bool Function(HttpResponse response)? responseFilter,
  bool Function(RhttpException exception)? errorFilter,
});
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to your branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- 🐛 **Found a bug?** [Open an issue](https://github.com/Shreemanarjun/talker_rhttp_logger/issues)
- 💡 **Have a suggestion?** [Create a feature request](https://github.com/Shreemanarjun/talker_rhttp_logger/issues/new)
- 📖 **Need help?** [Check out our discussions](https://github.com/Shreemanarjun/talker_rhttp_logger/discussions)

---

Built with ❤️ for the Flutter community by ShreemanArjun