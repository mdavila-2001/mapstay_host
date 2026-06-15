import '../../domain/entities/property.dart';

class PropertyModel extends Property {
  PropertyModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.precioNoche,
    required super.costoLimpieza,
    required super.cantPersonas,
    required super.cantCamas,
    required super.cantBanios,
    required super.cantHabitaciones,
    required super.cantVehiculosParqueo,
    required super.tieneWifi,
    required super.latitud,
    required super.longitud,
    required super.ciudad,
    required super.hostId,
    required super.activo,
    required super.firstPhoto,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    if (json['precioNoche'] != null) {
      parsedPrice = double.tryParse(json['precioNoche'].toString()) ?? 0.0;
    } else if (json['precio_noche'] != null) {
      parsedPrice = double.tryParse(json['precio_noche'].toString()) ?? 0.0;
    }

    double parsedCleaningFee = 0.0;
    if (json['costoLimpieza'] != null) {
      parsedCleaningFee = double.tryParse(json['costoLimpieza'].toString()) ?? 0.0;
    } else if (json['costo_limpieza'] != null) {
      parsedCleaningFee = double.tryParse(json['costo_limpieza'].toString()) ?? 0.0;
    }

    bool isActive = true;
    if (json['activo'] != null) {
      if (json['activo'] is bool) {
        isActive = json['activo'];
      } else if (json['activo'] is int) {
        isActive = json['activo'] == 1;
      }
    }

    bool parsedWifi = false;
    if (json['tieneWifi'] != null) {
      if (json['tieneWifi'] is bool) {
        parsedWifi = json['tieneWifi'];
      } else if (json['tieneWifi'] is int) {
        parsedWifi = json['tieneWifi'] == 1;
      }
    } else if (json['tiene_wifi'] != null) {
      if (json['tiene_wifi'] is bool) {
        parsedWifi = json['tiene_wifi'];
      } else if (json['tiene_wifi'] is int) {
        parsedWifi = json['tiene_wifi'] == 1;
      }
    }

    int parsedHostId = 0;
    if (json['arrendatario_id'] != null) {
      parsedHostId = int.tryParse(json['arrendatario_id'].toString()) ?? 0;
    } else if (json['arrendatarioId'] != null) {
      parsedHostId = int.tryParse(json['arrendatarioId'].toString()) ?? 0;
    }

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

    if (parsedPhoto.isEmpty) {
      parsedPhoto = 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=600&q=80';
    }

    return PropertyModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? 'Alojamiento sin nombre',
      descripcion: json['descripcion'] as String? ?? '',
      precioNoche: parsedPrice,
      costoLimpieza: parsedCleaningFee,
      cantPersonas: int.tryParse(json['cantPersonas']?.toString() ?? json['cant_personas']?.toString() ?? '') ?? 1,
      cantCamas: int.tryParse(json['cantCamas']?.toString() ?? json['cant_camas']?.toString() ?? '') ?? 1,
      cantBanios: int.tryParse(json['cantBanios']?.toString() ?? json['cant_banios']?.toString() ?? '') ?? 1,
      cantHabitaciones: int.tryParse(json['cantHabitaciones']?.toString() ?? json['cant_habitaciones']?.toString() ?? '') ?? 1,
      cantVehiculosParqueo: int.tryParse(json['cantVehiculosParqueo']?.toString() ?? json['cant_vehiculos_parqueo']?.toString() ?? '') ?? 0,
      tieneWifi: parsedWifi,
      latitud: json['latitud']?.toString() ?? json['lat_itud']?.toString() ?? '0.0',
      longitud: json['longitud']?.toString() ?? json['long_itud']?.toString() ?? '0.0',
      ciudad: json['ciudad'] as String? ?? 'Santa Cruz',
      hostId: parsedHostId,
      activo: isActive,
      firstPhoto: parsedPhoto,
    );
  }
}
