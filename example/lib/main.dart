import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_rhttp_logger/talker_rhttp_logger.dart';

void main() async {
  await Rhttp.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RhttpLoggerUi(),
    );
  }
}

class RhttpLoggerUi extends StatefulWidget {
  const RhttpLoggerUi({super.key});

  @override
  State<RhttpLoggerUi> createState() => _RhttpLoggerUiState();
}

class _RhttpLoggerUiState extends State<RhttpLoggerUi> {
  late RhttpClient rhttpClient;
  String response = '';

  @override
  void dispose() {
    rhttpClient.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<String> getComments() async {
    rhttpClient = await RhttpClient.create(
      settings: const ClientSettings(
        baseUrl: "https://run.mocky.io/v3/0ea76d29-90e5-4dca-a2c1-6a9aacaa6a96",
      ),
      interceptors: [
        TalkerRhttpLogger(
          talker: TalkerFlutter.init(),
          settings: const TalkerRhttpLoggerSettings(
            printRequestHeaders: true,
            printResponseHeaders: true,
            printCurlCommand: true,
          ),
        )
      ],
    );
    final response = await rhttpClient.post(
      '',
      body: const HttpBody.json(
        {},
      ),
      headers: const HttpHeaders.rawMap({
        'Accept': 'application/json',
      }),
    );
    return response.body;
  }

  Future<void> fetchComments() async {
    try {
      final result = await getComments();
      setState(() {
        response = result.isEmpty ? "No Data" : result.toString();
      });
    } catch (e) {
      setState(() {
        response = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rhttp Logger UI'),
      ),
      body: Center(
        child: response.isEmpty
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(response),
              ),
      ),
    );
  }
}
