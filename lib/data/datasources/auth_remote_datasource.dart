import 'dart:convert';
import 'package:product_app/core/network/client_http.dart';

class AuthRemoteDatasource {
  final HttpClient client;
  static const _loginUrl = 'https://dummyjson.com/auth/login';

  AuthRemoteDatasource(this.client);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await client.post(
      _loginUrl,
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 30,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Usuário ou senha inválidos');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
