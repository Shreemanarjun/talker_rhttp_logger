import 'dart:convert';

import 'package:talker/talker.dart';
import 'package:rhttp/rhttp.dart';
import 'package:talker_rhttp_logger/src/utils/curl_command_generator.dart';

import 'package:talker_rhttp_logger/talker_rhttp_logger.dart';

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
    required this.dataBody,
  });

  final HttpRequest httpRequest;
  final TalkerRhttpLoggerSettings settings;

  /// AS generateTextMessage not supoorts asynchronous generation
  final String? dataBody;

  @override
  AnsiPen get pen => settings.requestPen ?? (AnsiPen()..xterm(219));

  @override
  String get key => TalkerLogType.httpRequest.key;

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
    var msg = '[$title]\n${httpRequest.method.value} $message';

    final headers = switch (httpRequest.headers) {
      null => null,
      HttpHeaderMap(:final map) => map,
      HttpHeaderRawMap(:final map) => map,
      HttpHeaderList(:final list) => list.asMap(),
    };

    try {
      if (settings.printRequestData && dataBody != null) {
        msg += '\nData:\n$dataBody';
      }
      if (settings.printRequestHeaders && headers != null) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
    } catch (e) {
      msg += '\nError converting data: Unable to format data properly';
      // Optionally log the error
      msg += '\nConversion error: ${e.toString()}';
      // Or provide raw data instead
      if (dataBody != null) {
        msg += '\nRaw data:\n$dataBody';
      }
      if (headers != null) {
        msg += '\nRaw headers: $headers';
      }
    }
    return msg;
  }
}

class RhttpResponseLog extends TalkerLog {
  RhttpResponseLog(
    String super.message, {
    required this.response,
    required this.settings,
    required this.responseData,
  });

  final HttpResponse response;
  final TalkerRhttpLoggerSettings settings;
  final String? responseData;

  @override
  AnsiPen get pen => settings.responsePen ?? (AnsiPen()..xterm(46));

  @override
  String get key => TalkerLogType.httpResponse.key;

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
    var msg =
        '[$title]\n${response.request.method.value} $message';

    final responseMessage = getStatusMessage(response.statusCode);

    final headers = response.headerMap;

    msg += '\nStatus: ${response.statusCode}';

    if (settings.printResponseMessage) {
      msg += '\nMessage: $responseMessage';
    }

    try {
      if (settings.printResponseData && responseData != null) {
        msg += '\nData: \n$responseData';
      }
      if (settings.printResponseHeaders && headers.isNotEmpty) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
    } catch (e) {
      msg += '\nError converting data: Unable to format data properly';
      // Optionally log the error
      msg += '\nConversion error: ${e.toString()}';
      // Or provide raw data instead
      msg += '\nRaw data:\n $responseData';
      msg += '\nRaw headers: $headers';
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
  AnsiPen get pen => settings.errorPen ?? (AnsiPen()..xterm(196));

  @override
  String get key => TalkerLogType.httpError.key;

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
    var msg =
        '[$title]\n${rhttpException.request.method.value} $message';

    try {
      final responseMessage = switch (rhttpException) {
        RhttpInvalidCertificateException() => rhttpException.toString(),
        RhttpConnectionException() => rhttpException.toString(),
        RhttpStatusCodeException(:final statusCode) =>
          getStatusMessage(statusCode),
        RhttpUnknownException() => rhttpException.toString(),
        _ => null,
      };
      final statusCode = switch (rhttpException) {
        RhttpStatusCodeException(:final statusCode) => statusCode,
        _ => null
      };
      final Object? data = switch (rhttpException) {
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

      if (settings.printErrorMessage && responseMessage != null) {
        msg += '\nMessage: $responseMessage';
      }

      if (settings.printErrorData &&
          data != null &&
          data.toString().isNotEmpty) {
        msg += '\nData:\n$data';
      }
      if (settings.printErrorHeaders && headers != null && headers.isNotEmpty) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
    } catch (e) {
      msg += '\nError converting data: Unable to format data properly';
      // Optionally log the error
      msg += '\nConversion error: ${e.toString()}';
      // Or provide raw data instead
    }
    return msg;
  }
}

class RhttpCurlLog extends TalkerLog {
  RhttpCurlLog(
    String super.message, {
    required this.httpRequest,
    required this.httpResponse,
    required this.settings,
    required this.requestBody,
    required this.responseBody,
  });

  final HttpRequest httpRequest;
  final HttpResponse? httpResponse;
  final TalkerRhttpLoggerSettings settings;
  final String? requestBody;
  final String? responseBody;

  @override
  AnsiPen get pen => (AnsiPen()..xterm(214));

  @override
  String get key => "Curl";

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
    var msg = '[$title]\n${httpRequest.method.value} $message';

    try {
      // Generate a single cURL command that includes both request and response
      final curlCommand = generateCurlCommand(
        request: httpRequest,
        response: httpResponse,
        responseBody: responseBody,
        dataBody: requestBody,
      );
      msg += '\n$curlCommand';
    } catch (e) {
      msg += '\nError generating cURL command: ${e.toString()}';
    }

    return msg;
  }
}
