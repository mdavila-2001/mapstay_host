import '../entities/host.dart';

abstract class AuthRepository {
  Future<Host?> login(String email, String password);
  Future<Host?> register({
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String password,
  });
  Future<void> logout();
  Future<Host?> getCurrentSession();
}
