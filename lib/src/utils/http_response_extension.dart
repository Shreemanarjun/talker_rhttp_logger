import 'dart:typed_data';
import 'dart:convert'; // For jsonEncode and utf8.decode
import 'dart:async'; // For Stream handling

import 'package:rhttp/rhttp.dart';

extension HttpResponseExtension on HttpResponse? {
  Future<String?> readableData() async {
    try {
      return switch (this) {
        null => "",
        HttpTextResponse(:final String body, :final dynamic bodyToJson) =>
          _tryJsonEncode(bodyToJson) ?? bodyToJson?.toString() ?? body,
        HttpBytesResponse(:final Uint8List body) => utf8.decode(body),
        HttpStreamResponse(:final Stream<Uint8List> body) =>
          await _streamToString(body),
      };
    } catch (e) {
      return null;
    }
  }

  Future<String> _streamToString(Stream<Uint8List> stream) async {
    final bytes = await stream.expand((chunk) => chunk).toList();
    return utf8.decode(bytes);
  }

  String? _tryJsonEncode(dynamic bodyToJson) {
    try {
      return jsonEncode(bodyToJson);
    } catch (e) {
      return null; // Return null if jsonEncode fails
    }
  }
}
