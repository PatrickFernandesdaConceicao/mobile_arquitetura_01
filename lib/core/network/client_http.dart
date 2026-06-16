import 'package:http/http.dart' as http;

class HttpClient {
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  Future<http.Response> get(String path) async {
    return await _client.get(Uri.parse(path));
  }

  Future<http.Response> post(String path, {String? body}) async {
    return await _client.post(
      Uri.parse(path),
      headers: _headers,
      body: body,
    );
  }

  Future<http.Response> put(String path, {String? body}) async {
    return await _client.put(
      Uri.parse(path),
      headers: _headers,
      body: body,
    );
  }

  Future<http.Response> patch(String path, {String? body}) async {
    return await _client.patch(
      Uri.parse(path),
      headers: _headers,
      body: body,
    );
  }

  Future<http.Response> delete(String path) async {
    return await _client.delete(Uri.parse(path), headers: _headers);
  }
}