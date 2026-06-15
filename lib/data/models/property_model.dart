import '../../domain/entities/property.dart';

class PropertyModel extends Property {
  PropertyModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.precioNoche,
    required super.ciudad,
    required super.hostId,
    required super.activo,
    required super.firstPhoto,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    // Parsea el precio por noche de forma segura
    double parsedPrice = 0.0;
    if (json['precioNoche'] != null) {
      parsedPrice = double.tryParse(json['precioNoche'].toString()) ?? 0.0;
    } else if (json['precio_noche'] != null) {
      parsedPrice = double.tryParse(json['precio_noche'].toString()) ?? 0.0;
    }

    // Parsea si está activo de forma segura (soporta bool o int)
    bool isActive = true;
    if (json['activo'] != null) {
      if (json['activo'] is bool) {
        isActive = json['activo'];
      } else if (json['activo'] is int) {
        isActive = json['activo'] == 1;
      }
    }

    // Parsea el ID de arrendatario (remoto usa arrendatario_id / arrendatarioId)
    int parsedHostId = 0;
    if (json['arrendatario_id'] != null) {
      parsedHostId = int.tryParse(json['arrendatario_id'].toString()) ?? 0;
    } else if (json['arrendatarioId'] != null) {
      parsedHostId = int.tryParse(json['arrendatarioId'].toString()) ?? 0;
    }

    // Parsea la imagen de forma inteligente (soporta listado de fotos o campo único)
    String parsedPhoto = '';
    if (json['fotos'] != null && json['fotos'] is List && (json['fotos'] as List).isNotEmpty) {
      final first = (json['fotos'] as List).first;
      if (first is Map && first['foto'] != null) {
        parsedPhoto = first['foto'].toString();
      } else if (first is String) {
        parsedPhoto = first;
      }
    } else if (json['foto'] != null) {
      parsedPhoto = json['foto'].toString();
    }

    // Normaliza rutas relativas del backend convirtiéndolas en URLs absolutas válidas
    if (parsedPhoto.isNotEmpty && !parsedPhoto.startsWith('http://') && !parsedPhoto.startsWith('https://')) {
      const defaultApiBaseUrl = 'http://67.205.172.167/api';
      String domain = 'http://67.205.172.167';
      try {
        const envUrl = String.fromEnvironment('PUBLIC_API_URL');
        if (envUrl.isNotEmpty) {
          domain = Uri.parse(envUrl).origin;
        } else {
          domain = Uri.parse(defaultApiBaseUrl).origin;
        }
      } catch (_) {}

      if (parsedPhoto.startsWith('/')) {
        parsedPhoto = '$domain$parsedPhoto';
      } else if (parsedPhoto.startsWith('storage/')) {
        parsedPhoto = '$domain/$parsedPhoto';
      } else if (parsedPhoto.startsWith('public/')) {
        parsedPhoto = '$domain/${parsedPhoto.replaceFirst('public/', '')}';
      } else {
        parsedPhoto = '$domain/storage/$parsedPhoto';
      }
    }

    // Fallback de imagen en caso de no contar con foto
    if (parsedPhoto.isEmpty) {
      parsedPhoto = 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=600&q=80';
    }

    return PropertyModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? 'Alojamiento sin nombre',
      descripcion: json['descripcion'] as String? ?? '',
      precioNoche: parsedPrice,
      ciudad: json['ciudad'] as String? ?? 'Santa Cruz',
      hostId: parsedHostId,
      activo: isActive,
      firstPhoto: parsedPhoto,
    );
  }
}
