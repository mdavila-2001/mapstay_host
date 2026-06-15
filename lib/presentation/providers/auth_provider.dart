import 'package:flutter/material.dart';
import 'package:mapstay_host/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository}) {
    _loadSession();
  }

  bool _isLoading = false;
  String? _errorMessage;
  int? _userId;
  String? _userName;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get userId => _userId;
  String? get userName => _userName;
  bool get isAuthenticated => _userId != null;

  Future<void> _loadSession() async {
    try {
      final user = await authRepository.getCurrentSession();
      if (user != null) {
        _userId = user.id;
        _userName = user.nombreCompleto;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await authRepository.login(email, password);
      if (user != null) {
        _userId = user.id;
        _userName = user.nombreCompleto;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Credenciales de inicio de sesión inválidas';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await authRepository.register(
        nombreCompleto: nombreCompleto,
        email: email,
        telefono: telefono,
        password: password,
      );
      if (user != null) {
        _userId = user.id;
        _userName = user.nombreCompleto;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Error al registrar los datos del host';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
    } catch (_) {}
    _userId = null;
    _userName = null;
    notifyListeners();
  }
}
