import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/core/network/client_http.dart';
import 'package:product_app/data/datasources/auth_remote_datasource.dart';
import 'package:product_app/domain/entities/user.dart';
import 'package:product_app/presentation/states/auth_state.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(HttpClient());
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDatasource datasource;

  AuthNotifier(this.datasource) : super(const AuthState());

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await datasource.login(username, password);
      final user = User(
        id: data['id'] as int,
        username: data['username'] as String,
        firstName: data['firstName'] as String,
        lastName: data['lastName'] as String,
        email: data['email'] as String,
        token: data['accessToken'] as String,
      );
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRemoteDatasourceProvider));
});
