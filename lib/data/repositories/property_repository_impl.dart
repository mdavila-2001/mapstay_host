import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../models/property_model.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  PropertyRepositoryImpl();

  @override
  Future<List<Property>> getProperties(int hostId) async {

    var response = await ApiClient.get('/lugares/arrendatario/$hostId');


    if (response.statusCode == 404) {
      response = await ApiClient.get('/lugar/arrendatario/$hostId');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      List<dynamic> rawList = [];
      
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map) {
        rawList = decoded['data'] ?? decoded['lugares'] ?? decoded['places'] ?? decoded['lugar'] ?? [];
      }

      return rawList.map((item) => PropertyModel.fromJson(item)).toList();
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Error al obtener los alojamientos del servidor';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<Property> createProperty(Map<String, dynamic> data) async {

    var response = await ApiClient.post('/lugares', data);


    if (response.statusCode == 404 || response.statusCode == 405) {
      response = await ApiClient.post('/lugar', data);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      Map<String, dynamic> resultJson = {};
      if (decoded is Map) {
        if (decoded.containsKey('data')) {
          resultJson = decoded['data'];
        } else if (decoded.containsKey('lugar')) {
          resultJson = decoded['lugar'];
        } else {
          resultJson = Map<String, dynamic>.from(decoded);
        }
      }
      return PropertyModel.fromJson(resultJson);
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Error al crear el alojamiento en el servidor';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<Property> updateProperty(int id, Map<String, dynamic> data) async {
    final Map<String, dynamic> payload = Map.from(data)..['id'] = id;
    
    var response = await ApiClient.put('/lugares/$id', payload);

    if (response.statusCode == 404 || response.statusCode == 405) {
      response = await ApiClient.put('/lugar/$id', payload);
    }

    if (response.statusCode == 404 || response.statusCode == 405) {
      response = await ApiClient.post('/lugar', payload);
    }
    if (response.statusCode == 404 || response.statusCode == 405) {
      response = await ApiClient.post('/lugares', payload);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      Map<String, dynamic> resultJson = {};
      if (decoded is Map) {
        if (decoded.containsKey('data')) {
          resultJson = decoded['data'];
        } else if (decoded.containsKey('lugar')) {
          resultJson = decoded['lugar'];
        } else {
          resultJson = Map<String, dynamic>.from(decoded);
        }
      }
      return PropertyModel.fromJson(resultJson);
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Error al actualizar el alojamiento en el servidor';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<void> uploadPropertyPhoto(int propertyId, File photoFile) async {

    var uri = Uri.parse('${ApiClient.baseUrl}/lugares/$propertyId/foto');
    var request = http.MultipartRequest('POST', uri);
    var multipartFile = await http.MultipartFile.fromPath('foto', photoFile.path);
    request.files.add(multipartFile);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);


    if (response.statusCode == 404 || response.statusCode == 405) {
      uri = Uri.parse('${ApiClient.baseUrl}/lugar/$propertyId/foto');
      request = http.MultipartRequest('POST', uri);
      multipartFile = await http.MultipartFile.fromPath('foto', photoFile.path);
      request.files.add(multipartFile);
      streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Error al subir foto del alojamiento';
      throw Exception(errorMsg);
    }
  }
}
