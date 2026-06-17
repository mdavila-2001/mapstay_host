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
    required super.fotos,
    super.hostNombre,
    super.hostTelefono,
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

    String normalizePhoto(String path) {
      if (path.isEmpty) return '';
      if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('assets/')) {
        return path;
      }
      final domainPattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
      if (domainPattern.hasMatch(path)) {
        return path;
      }
      if (path.startsWith('/')) {
        return '$domain$path';
      } else if (path.startsWith('storage/')) {
        return '$domain/$path';
      } else if (path.startsWith('public/')) {
        return '$domain/${path.replaceFirst('public/', '')}';
      } else {
        return '$domain/storage/$path';
      }
    }

    List<String> parsedPhotos = [];
    if (json['fotos'] != null && json['fotos'] is List) {
      for (var item in json['fotos']) {
        String p = '';
        if (item is Map) {
          p = (item['url'] ?? item['foto'] ?? '').toString();
        } else if (item is String) {
          p = item;
        }
        if (p.isNotEmpty) {
          parsedPhotos.add(normalizePhoto(p));
        }
      }
    } else if (json['foto'] != null) {
      parsedPhotos.add(normalizePhoto(json['foto'].toString()));
    }

    String parsedPhoto = '';
    if (parsedPhotos.isNotEmpty) {
      parsedPhoto = parsedPhotos.first;
    } else {
      parsedPhoto = 'assets/no_pic.png';
      parsedPhotos.add(parsedPhoto);
    }

    final String? hostNombre = json['arrendatario']?['nombrecompleto']?.toString() ??
        json['arrendatario']?['nombreCompleto']?.toString();
    final String? hostTelefono = json['arrendatario']?['telefono']?.toString();

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
      fotos: parsedPhotos,
      hostNombre: hostNombre,
      hostTelefono: hostTelefono,
    );
  }
}
