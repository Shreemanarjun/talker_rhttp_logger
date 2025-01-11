import 'dart:convert';
import 'package:rhttp/rhttp.dart';

String generateCurlCommand({
  required HttpRequest request,
  HttpResponse? response,
  String? responseBody,
  String? dataBody,
}) {
  final method = request.method.name.toUpperCase();
  final url = request.url.toString();
  final headers = request.headers;

  var parts = <String>[];
  parts.add('curl');

  if (method != 'GET') {
    parts.add('-X $method');
  }

  parts.add(url);

  if (headers != null) {
    headers.toMapList().forEach((name, values) {
      for (var value in values) {
        parts.add('-H "$name: $value"');
      }
    });
  }

  if (dataBody != null && dataBody.isNotEmpty) {
    try {
      final jsonData = jsonDecode(dataBody);
      if (jsonData is Map<String, dynamic>) {
        // Handle Map objects differently
        String formattedJson = '';
        var entries = [];

        jsonData.forEach((key, value) {
          // Remove quotes from keys but keep values as-is
          if (value is String) {
            entries.add("""-d '$key="$value"' """);
          } else {
            entries.add("""-d '$key=$value' """);
          }
        });

        formattedJson += entries.join('');
        parts.add(formattedJson);
      } else {
        // Handle non-Map JSON as before
        String unquotedJson = jsonEncode(jsonData)
            .replaceAll('":', ':')
            .replaceAll('{"', '{')
            .replaceAll('"}', '}')
            .replaceAll('","', ',');
        parts.add("-d $unquotedJson");
      }
    } catch (_) {
      parts.add("-d $dataBody");
    }
  }

  return parts.join(' ');
}
