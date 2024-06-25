import 'package:dio/dio.dart';
import 'package:love_code/constants.dart';

class HttpHandler {
  static final dio = Dio();
  static const String baseUrl = Constants.apiUrl;
  static Future<void> post(String command, dynamic body) async {
    await dio.post('$baseUrl/$command', data: body);
  }
}
