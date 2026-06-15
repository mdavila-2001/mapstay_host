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

  /// Carga reactiva de los alojamientos asociados al hostId desde el repositorio.
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
}
