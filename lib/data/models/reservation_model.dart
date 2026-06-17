import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  ReservationModel({
    super.id,
    required super.cantNoches,
    required super.fechaLlegada,
    required super.fechaSalida,
    required super.nombreCliente,
    required super.precioTotal,
    required super.lugarFoto,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
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

    String? parsedPhoto;
    if (json['lugarFoto'] != null) {
      final String photoStr = json['lugarFoto'].toString();
      if (photoStr.isNotEmpty) {
        final domainPattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
        if (photoStr.startsWith('http://') || photoStr.startsWith('https://') || photoStr.startsWith('assets/')) {
          parsedPhoto = photoStr;
        } else if (domainPattern.hasMatch(photoStr)) {
          parsedPhoto = photoStr;
        } else if (photoStr.startsWith('/')) {
          parsedPhoto = '$domain$photoStr';
        } else if (photoStr.startsWith('storage/')) {
          parsedPhoto = '$domain/$photoStr';
        } else if (photoStr.startsWith('public/')) {
          parsedPhoto = '$domain/${photoStr.replaceFirst('public/', '')}';
        } else {
          parsedPhoto = '$domain/storage/$photoStr';
        }
      }
    }

    if (parsedPhoto == null || parsedPhoto.isEmpty) {
      parsedPhoto = 'assets/no_pic.png';
    }

    DateTime checkIn;
    try {
      final String? rawCheckIn = json['fechaLlegada']?.toString() ??
          json['fechaInicio']?.toString() ??
          json['fecha_llegada']?.toString() ??
          json['fecha_inicio']?.toString();
      checkIn = rawCheckIn != null && rawCheckIn != 'null' && rawCheckIn.isNotEmpty
          ? DateTime.parse(rawCheckIn)
          : DateTime.now();
    } catch (_) {
      checkIn = DateTime.now();
    }

    DateTime checkOut;
    try {
      final String? rawCheckOut = json['fechaSalida']?.toString() ??
          json['fechaFin']?.toString() ??
          json['fecha_salida']?.toString() ??
          json['fecha_fin']?.toString();
      checkOut = rawCheckOut != null && rawCheckOut != 'null' && rawCheckOut.isNotEmpty
          ? DateTime.parse(rawCheckOut)
          : DateTime.now().add(const Duration(days: 1));
    } catch (_) {
      checkOut = DateTime.now().add(const Duration(days: 1));
    }

    // Auto-correct year typos in checkout dates if they are before checkin
    if (checkOut.isBefore(checkIn)) {
      final DateTime adjustedCheckOut = DateTime(checkIn.year, checkOut.month, checkOut.day, checkOut.hour, checkOut.minute);
      if (adjustedCheckOut.isAfter(checkIn)) {
        checkOut = adjustedCheckOut;
      } else {
        // If it's still before checkin (e.g. checkin: Dec 31, checkout: Jan 2), it belongs to next year
        checkOut = DateTime(checkIn.year + 1, checkOut.month, checkOut.day, checkOut.hour, checkOut.minute);
      }
    }

    final int calculatedNights = DateTime(checkOut.year, checkOut.month, checkOut.day)
        .difference(DateTime(checkIn.year, checkIn.month, checkIn.day))
        .inDays;
    final int nights = calculatedNights > 0 ? calculatedNights : 1;

    final String clientName = json['cliente']?['nombrecompleto']?.toString() ??
        json['cliente']?['nombreCompleto']?.toString() ??
        json['nombreCliente']?.toString() ??
        'Cliente sin nombre';
        
    final double totalPrice = double.tryParse(json['precioTotal']?.toString() ?? '') ?? 0.0;
    final int? resId = json['id'] as int?;

    return ReservationModel(
      id: resId,
      cantNoches: nights,
      fechaLlegada: checkIn,
      fechaSalida: checkOut,
      nombreCliente: clientName,
      precioTotal: totalPrice,
      lugarFoto: parsedPhoto,
    );
  }
}
