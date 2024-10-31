import 'dart:convert';

import 'package:talker/talker.dart';
import 'package:rhttp/rhttp.dart';
import 'package:talker_rhttp_logger/src/talker_rhttp_logger_settings.dart';

const encoder = JsonEncoder.withIndent('  ');

class RhttpRequestLog extends TalkerLog {
  RhttpRequestLog(
    String super.message, {
    required this.httpRequest,
    required this.settings,
  });

  final HttpRequest httpRequest;
  final TalkerRhttpLoggerSettings settings;

  @override
  AnsiPen get pen => settings.requestPen ?? (AnsiPen()..xterm(219));

  @override
  String get key => TalkerLogType.httpRequest.key;

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
    var msg = '[$title] [${httpRequest.method}] $message';

    final data = httpRequest.body;
    final headers = httpRequest.headers;

    try {
      if (settings.printRequestData && data != null) {
        final prettyData = encoder.convert(data);
        msg += '\nData: $prettyData';
      }
      if (settings.printRequestHeaders) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
    } catch (_) {
      // TODO: add handling can`t convert
    }
    return msg;
  }
}

class RhttpResponseLog extends TalkerLog {
  RhttpResponseLog(
    String super.message, {
    required this.response,
    required this.settings,
  });

  final HttpResponse response;
  final TalkerRhttpLoggerSettings settings;

  @override
  AnsiPen get pen => settings.responsePen ?? (AnsiPen()..xterm(46));

  @override
  String get key => TalkerLogType.httpResponse.key;

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
    var msg = '[$title] [${response.request.method}] $message';

    final responseMessage = response.statusCode;
    final data = switch (response) {
      HttpTextResponse(:final body) => body,
      HttpBytesResponse(:final body) => body,
      HttpStreamResponse(:final body) => body,
    }
        .toString();
    final headers = response.headers.map(
      (e) => e,
    );

    msg += '\nStatus: ${response.statusCode}';

    if (settings.printResponseMessage) {
      msg += '\nMessage: $responseMessage';
    }

    try {
      if (settings.printResponseData) {
        final prettyData = encoder.convert(data);
        msg += '\nData: $prettyData';
      }
      if (settings.printResponseHeaders && headers.isNotEmpty) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
    } catch (_) {
      // TODO: add handling can`t convert
    }
    return msg;
  }
}

class RhttpErrorLog extends TalkerLog {
  RhttpErrorLog(
    String super.title, {
    required this.rhttpException,
    required this.settings,
  });

  final RhttpException rhttpException;
  final TalkerRhttpLoggerSettings settings;

  @override
  AnsiPen get pen => settings.errorPen ?? (AnsiPen()..red());

  @override
  String get key => TalkerLogType.httpError.key;

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
    var msg = '[$title] [${rhttpException.request.method}] $message';

    final responseMessage = switch (rhttpException) {
      RhttpInvalidCertificateException(:final message) => message,
      RhttpConnectionException(:final message) => message,
      RhttpUnknownException(:final message) => message,
      _ => null,
    };
    final statusCode = switch (rhttpException) {
      RhttpStatusCodeException(:final statusCode) => statusCode,
      _ => null
    };
    final data = switch (rhttpException) {
      RhttpStatusCodeException(:final body) => body,
      _ => null
    };
    final headers = switch (rhttpException) {
      RhttpStatusCodeException(:final headers) => headers,
      _ => null
    };

    if (statusCode != null) {
      msg += '\nStatus: $statusCode';
    }

    if (settings.printErrorMessage && responseMessage != null) {
      msg += '\nMessage: $responseMessage';
    }

    if (settings.printErrorData && data != null) {
      final prettyData = encoder.convert(data);
      msg += '\nData: $prettyData';
    }
    if (settings.printErrorHeaders && !(headers?.isEmpty ?? true)) {
      final prettyHeaders = encoder.convert(headers!.map);
      msg += '\nHeaders: $prettyHeaders';
    }
    return msg;
  }
}
