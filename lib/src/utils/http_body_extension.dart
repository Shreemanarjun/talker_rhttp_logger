import 'dart:convert';
import 'dart:typed_data';
import 'dart:async'; // Import for Stream handling
import 'package:rhttp/rhttp.dart';

extension HttpBodyExtension on HttpBody? {
  Future<String?> readableData() async {
    try {
      return switch (this) {
        HttpBodyText(:final text) => text,
        HttpBodyJson(:final json) => jsonEncode(json),
        HttpBodyBytes(:final Uint8List bytes) => bytes.toString(),
        HttpBodyBytesStream(:final Stream<List<int>> stream) =>
          await _streamToString(stream),
        HttpBodyForm(:final Map<String, String> form) =>
          form.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
        HttpBodyMultipart(:final List<(String, MultipartItem)> parts) =>
          parts.map((part) => '${part.$1}: ${part.$2}').join('\n'),
        _ => toString(),
      };
    } catch (e) {
      return null;
    }
  }

  Future<String> _streamToString(Stream<List<int>> stream) async {
    final bytes = await stream.expand((chunk) => chunk).toList();
    return utf8.decode(bytes);
  }
}
