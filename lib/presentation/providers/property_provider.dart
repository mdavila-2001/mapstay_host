import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapstay_host/domain/entities/property.dart';
import 'package:mapstay_host/domain/repositories/property_repository.dart';

class PropertyProvider extends ChangeNotifier {
  final PropertyRepository propertyRepository;

  PropertyProvider({required this.propertyRepository});

  List<Property> _properties = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProperties(int hostId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _properties = await propertyRepository.getProperties(hostId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProperty({
    int? id,
    required String nombre,
    required String descripcion,
    required double precioNoche,
    required double costoLimpieza,
    required int cantPersonas,
    required int cantCamas,
    required int cantBanios,
    required int cantHabitaciones,
    required int cantVehiculosParqueo,
    required bool tieneWifi,
    required String latitud,
    required String longitud,
    required String ciudad,
    required int hostId,
    required List<File> imageFiles,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> payload = {
        'nombre': nombre,
        'descripcion': descripcion,
        'precioNoche': precioNoche.toStringAsFixed(2),
        'costoLimpieza': costoLimpieza.toStringAsFixed(2),
        'cantPersonas': cantPersonas,
        'cantCamas': cantCamas,
        'cantBanios': cantBanios,
        'cantHabitaciones': cantHabitaciones,
        'cantVehiculosParqueo': cantVehiculosParqueo,
        'tieneWifi': tieneWifi ? 1 : 0,
        'latitud': latitud,
        'longitud': longitud,
        'ciudad': ciudad,
        'arrendatario_id': hostId,
      };

      final Property property;
      if (id == null) {
        property = await propertyRepository.createProperty(payload);
      } else {
        property = await propertyRepository.updateProperty(id, payload);
      }

      if (imageFiles.isNotEmpty) {
        for (var file in imageFiles) {
          if (file.existsSync()) {
            await propertyRepository.uploadPropertyPhoto(property.id, file);
          }
        }
      }

      await fetchProperties(hostId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
