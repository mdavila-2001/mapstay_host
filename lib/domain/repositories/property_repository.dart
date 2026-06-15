import 'dart:io';
import '../entities/property.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties(int hostId);
  Future<Property> createProperty(Map<String, dynamic> data);
  Future<Property> updateProperty(int id, Map<String, dynamic> data);
  Future<void> uploadPropertyPhoto(int propertyId, File photoFile);
}
