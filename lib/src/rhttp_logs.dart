import 'dart:convert';

import 'package:talker/talker.dart';
import 'package:rhttp/rhttp.dart';
import 'package:talker_rhttp_logger/src/talker_rhttp_logger_settings.dart';

// Define a map for status codes and messages
final Map<int, String> statusMessages = {
  100: "100 Continue",
  101: "101 Switching Protocols",
  102: "102 Processing",
  103: "103 Early Hints",
  200: "200 OK",
  201: "201 Created",
  202: "202 Accepted",
  203: "203 Non-Authoritative Information",
  204: "204 No Content",
  205: "205 Reset Content",
  206: "206 Partial Content",
  207: "207 Multi-Status",
  208: "208 Already Reported",
  209: "209 IM Used",
  210: "210 Content Different",
  226: "226 IM Used",
  300: "300 Multiple Choices",
  301: "301 Moved Permanently",
  302: "302 Found",
  303: "303 See Other",
  304: "304 Not Modified",
  305: "305 Use Proxy",
  306: "306 Switch Proxy",
  307: "307 Temporary Redirect",
  308: "308 Permanent Redirect",
  400: "400 Bad Request",
  401: "401 Unauthorized",
  402: "402 Payment Required",
  403: "403 Forbidden",
  404: "404 Not Found",
  405: "405 Method Not Allowed",
  406: "406 Not Acceptable",
  407: "407 Proxy Authentication Required",
  408: "408 Request Timeout",
  409: "409 Conflict",
  410: "410 Gone",
  411: "411 Length Required",
  412: "412 Precondition Failed",
  413: "413 Payload Too Large",
  414: "414 URI Too Long",
  415: "415 Unsupported Media Type",
  416: "416 Range Not Satisfiable",
  417: "417 Expectation Failed",
  418: "418 I'm a teapot",
  421: "421 Misdirected Request",
  422: "422 Unprocessable Entity",
  423: "423 Locked",
  424: "424 Failed Dependency",
  425: "425 Too Early",
  426: "426 Upgrade Required",
  428: "428 Precondition Required",
  429: "429 Too Many Requests",
  431: "431 Request Header Fields Too Large",
  451: "451 Unavailable For Legal Reasons",
  500: "500 Internal Server Error",
  501: "501 Not Implemented",
  502: "502 Bad Gateway",
  503: "503 Service Unavailable",
  504: "504 Gateway Timeout",
  505: "505 HTTP Version Not Supported",
  506: "506 Variant Also Negotiates",
  507: "507 Insufficient Storage",
  508: "508 Loop Detected",
  509: "509 Bandwidth Limit Exceeded",
  510: "510 Not Extended",
  511: "511 Network Authentication Required",
};

// Function to get the status message from the map
String getStatusMessage(int statusCode) {
  return statusMessages[statusCode] ?? "$statusCode Unknown";
}

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
    var msg = '[$title] [${httpRequest.method.name.toUpperCase()}] $message';

    final data = httpRequest.body;
    final headers = httpRequest.headers;

    try {
      if (settings.printRequestData && data != null) {
        msg += '\nData: $data';
      }
      if (settings.printRequestHeaders && headers != null) {
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
    var msg =
        '[$title] [${response.request.method.name.toUpperCase()}] $message';

    final responseMessage = getStatusMessage(response.statusCode);
    final data = switch (response) {
      HttpTextResponse(:final body) => body,
      HttpBytesResponse(:final body) => body,
      HttpStreamResponse(:final body) => body,
    };
    final headers = response.headers.map(
      (e) => e,
    );

    msg += '\nStatus: ${response.statusCode}';

    if (settings.printResponseMessage) {
      msg += '\nMessage: $responseMessage';
    }

    try {
      if (settings.printResponseData) {
        msg += '\nData: $data';
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
    var msg =
        '[$title] [${rhttpException.request.method.name.toUpperCase()}] $message';

    final responseMessage = switch (rhttpException) {
      RhttpInvalidCertificateException(:final message) => message,
      RhttpConnectionException(:final message) => message,
      RhttpStatusCodeException(:final statusCode) =>
        getStatusMessage(statusCode),
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
      RhttpStatusCodeException(:final headerMap) => headerMap,
      _ => null
    };

    if (statusCode != null) {
      msg += '\nStatus: $statusCode';
    }

    if (settings.printErrorMessage) {
      msg += '\nMessage: $responseMessage';
    }

    if (settings.printErrorData) {
      msg += '\nData: $data';
    }
    if (settings.printErrorHeaders) {
      final prettyHeaders = encoder.convert(headers);
      msg += '\nHeaders: $prettyHeaders';
    }
    return msg;
  }
}
