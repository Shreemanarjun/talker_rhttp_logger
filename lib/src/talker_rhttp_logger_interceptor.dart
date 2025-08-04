import 'package:rhttp/rhttp.dart';
import 'package:talker/talker.dart';

import 'package:talker_rhttp_logger/talker_rhttp_logger.dart';

class TalkerRhttpLogger extends Interceptor {
  TalkerRhttpLogger({
    Talker? talker,
    this.settings = const TalkerRhttpLoggerSettings(),
    this.addonId,
  }) {
    _talker = talker ?? Talker();
  }

  late Talker _talker;

  /// [TalkerRhttpLogger] settings and customization
  TalkerRhttpLoggerSettings settings;

  /// Talker addon functionality
  /// addon id for create a lot of addons
  final String? addonId;

  /// Method to update [settings] of [TalkerRhttpLogger]
  void configure({
    bool? printResponseData,
    bool? printResponseHeaders,
    bool? printResponseMessage,
    bool? printErrorData,
    bool? printErrorHeaders,
    bool? printErrorMessage,
    bool? printRequestData,
    bool? printRequestHeaders,
    AnsiPen? requestPen,
    AnsiPen? responsePen,
    AnsiPen? errorPen,
  }) {
    settings = settings.copyWith(
      printRequestData: printRequestData,
      printRequestHeaders: printRequestHeaders,
      printResponseData: printResponseData,
      printErrorData: printErrorData,
      printErrorHeaders: printErrorHeaders,
      printErrorMessage: printErrorMessage,
      printResponseHeaders: printResponseHeaders,
      printResponseMessage: printResponseMessage,
      requestPen: requestPen,
      responsePen: responsePen,
      errorPen: errorPen,
    );
  }

  @override
  Future<InterceptorResult<HttpRequest>> beforeRequest(
      HttpRequest request) async {
    super.beforeRequest(request);
    final accepted = settings.requestFilter?.call(request) ?? true;
    if (!accepted) {
      return Interceptor.stop();
    }
    try {
      final message = "${request.settings?.baseUrl ?? ""}${request.url}";
      final httpLog = RhttpRequestLog(
        message,
        httpRequest: request,
        settings: settings,
        dataBody: await request.body?.readableData(),
      );
      _talker.logCustom(httpLog);
    } catch (e) {
      _talker.error("Interceptor beforeRequest error", e);
    }
    return Interceptor.next(request);
  }

  @override
  Future<InterceptorResult<HttpResponse>> afterResponse(
      HttpResponse response) async {
    final accepted = settings.responseFilter?.call(response) ?? true;
    if (!accepted) {
      return Interceptor.stop();
    }
    try {
      final message =
          "${response.request.settings?.baseUrl ?? ""}${response.request.url} ";
      final httpLog = RhttpResponseLog(message,
          settings: settings,
          response: response,
          responseData: (await response.readableData()));
      _talker.logCustom(httpLog);
      if (settings.printCurlCommand) {
        final curllog = RhttpCurlLog(
          message,
          httpRequest: response.request,
          httpResponse: response,
          settings: settings,
          requestBody: await response.request.body?.readableData(indent: false),
          responseBody: await response.readableData(indent: false),
        );
        _talker.logCustom(curllog);
      }
    } catch (e) {
      _talker.error("Interceptor afterResponse error", e);
    }
    return Interceptor.next(response);
  }

  @override
  Future<InterceptorResult<RhttpException>> onError(
      RhttpException exception) async {
    final accepted = settings.errorFilter?.call(exception) ?? true;
    if (!accepted) {
      return Interceptor.stop();
    }
    try {
      final message =
          "${exception.request.settings?.baseUrl ?? ""}${exception.request.url}";
      final httpErrorLog = RhttpErrorLog(
        message,
        rhttpException: exception,
        settings: settings,
      );
      _talker.logCustom(httpErrorLog);
      if (settings.printCurlCommand) {
        final Object? data = switch (exception) {
          RhttpStatusCodeException(:final Object? body) => body,
          _ => null
        };
        final curllog = RhttpCurlLog(
          message,
          httpRequest: exception.request,
          settings: settings,
          requestBody:
              await exception.request.body?.readableData(indent: false),
          responseBody: data?.toString(),
          httpResponse: switch (exception) {
            RhttpStatusCodeException(
              :final statusCode,
              :final headers,
              :final body,
            ) =>
              HttpTextResponse(
                body: body?.toString() ?? "",
                request: exception.request,
                version: HttpVersion.other,
                statusCode: statusCode,
                headers: headers,
                remoteIp: null
              ),
            _ => null
          },
        );
        _talker.logCustom(curllog);
      }
    } catch (e) {
      _talker.error("Interceptor onError error", e);
    }
    super.onError(exception);
    return Interceptor.next(exception);
  }
}
