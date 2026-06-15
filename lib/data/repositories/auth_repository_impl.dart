import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/host.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/host_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  @override
  Future<Host?> login(String email, String password) async {
    final response = await ApiClient.post('/arrendatario/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final userJson = data['user'] ?? data;
      final model = HostModel.fromJson(userJson);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('host_id', model.id);
      await prefs.setString('nombrecompleto', model.nombreCompleto);
      await prefs.setString('email', model.email);

      return model;
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Credenciales de inicio de sesión inválidas';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<Host?> register({
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String password,
  }) async {
    final response = await ApiClient.post('/arrendatario/registro', {
      'nombrecompleto': nombreCompleto,
      'email': email,
      'password': password,
      'telefono': telefono,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final userJson = data['user'] ?? data;
      final model = HostModel.fromJson(userJson);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('host_id', model.id);
      await prefs.setString('nombrecompleto', model.nombreCompleto);
      await prefs.setString('email', model.email);

      return model;
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Error al registrar los datos del host';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('host_id');
    await prefs.remove('nombrecompleto');
    await prefs.remove('email');
  }

  @override
  Future<Host?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Fallback temporarily to 'arrendatario_id' if 'host_id' is not set yet, so existing sessions don't get lost
    int? id = prefs.getInt('host_id') ?? prefs.getInt('arrendatario_id');
    final name = prefs.getString('nombrecompleto');
    final email = prefs.getString('email');

    if (id != null && name != null && email != null) {
      return Host(
        id: id,
        nombreCompleto: name,
        email: email,
        telefono: '',
      );
    }
    return null;
  }
}
