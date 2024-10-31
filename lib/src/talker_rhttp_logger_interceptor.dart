import 'package:rhttp/rhttp.dart';
import 'package:talker/talker.dart';
import 'package:talker_rhttp_logger/src/rhttp_logs.dart';
import 'package:talker_rhttp_logger/src/talker_rhttp_logger_settings.dart';

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
      final message = request.url;
      final httpLog = RhttpRequestLog(
        message,
        httpRequest: request,
        settings: settings,
      );
      _talker.logTyped(httpLog);
    } catch (e) {
      _talker.error(e);
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
      final message = response.request.url;
      final httpLog = RhttpResponseLog(
        message,
        settings: settings,
        response: response,
      );
      _talker.logTyped(httpLog);
    } catch (e) {
      _talker.error(e);
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
      final message = exception.request.url;
      final httpErrorLog = RhttpErrorLog(
        message,
        rhttpException: exception,
        settings: settings,
      );
      _talker.logTyped(httpErrorLog);
    } catch (e) {
      _talker.error(e);
      //pass
    }
    super.onError(exception);
    return Interceptor.next(exception);
  }
}
