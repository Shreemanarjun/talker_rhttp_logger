import 'package:flutter_test/flutter_test.dart';
import 'package:rhttp/rhttp.dart';
import 'package:talker/talker.dart';
import 'package:talker_rhttp_logger/talker_rhttp_logger.dart';

void main() {
  group('TalkerRhttpLogger tests', () {
    late TalkerRhttpLogger logger;
    late Talker talker;

    setUp(() {
      talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
      logger = TalkerRhttpLogger(talker: talker);
    });

    test('configure method should update logger settings', () {
      logger.configure(printRequestData: true);
      expect(logger.settings.printRequestData, true);
    });

    test('onRequest method should log http request', () {
      final options = HttpRequest.from(
        request: BaseHttpRequest(
          url: "/path",
          method: HttpMethod.get,
          query: {},
          headers: const HttpHeaders.map({}),
          body: null,
          cancelToken: null,
          expectBody: HttpExpectBody.text,
          onReceiveProgress: (count, total) {},
          onSendProgress: (count, total) {},
        ),
        client: null,
        interceptor: null,
        settings: null,
      );
      final logMessage = options.url;
      logger.beforeRequest(options);
      expect(talker.history.last.message, logMessage);
    });

    test('onResponse method should log http response', () {
      final options = HttpRequest.from(
        request: BaseHttpRequest(
          url: "/test",
          method: HttpMethod.get,
          query: {},
          headers: const HttpHeaders.map({}),
          body: null,
          cancelToken: null,
          expectBody: HttpExpectBody.text,
          onReceiveProgress: (count, total) {},
          onSendProgress: (count, total) {},
        ),
        client: null,
        interceptor: null,
        settings: null,
      );
      final response = HttpTextResponse(
          request: options,
          statusCode: 200,
          headers: List.empty(),
          body: "",
          version: HttpVersion.http1_1);
      final logMessage = response.request.url;
      logger.afterResponse(response);
      expect(talker.history.last.message, logMessage);
    });
  });
}
