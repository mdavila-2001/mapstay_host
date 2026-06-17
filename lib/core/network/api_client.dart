import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'PUBLIC_API_URL',
    defaultValue: 'http://67.205.172.167/api',
  );

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );
  }

  Future<http.Response> getRequest(String path) => ApiClient.get(path);
  Future<http.Response> postRequest(String path, Map<String, dynamic> body) => ApiClient.post(path, body);
  Future<http.Response> putRequest(String path, Map<String, dynamic> body) => ApiClient.put(path, body);
}