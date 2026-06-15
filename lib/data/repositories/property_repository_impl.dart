import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../models/property_model.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  PropertyRepositoryImpl();

  @override
  Future<List<Property>> getProperties(int hostId) async {
    final response = await ApiClient.get('/lugares/arrendatario/$hostId');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      List<dynamic> rawList = [];
      
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map) {
        rawList = decoded['data'] ?? decoded['lugares'] ?? decoded['places'] ?? [];
      }

      return rawList.map((item) => PropertyModel.fromJson(item)).toList();
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Error al obtener los alojamientos del servidor';
      throw Exception(errorMsg);
    }
  }
}
