import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  ReservationModel({
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
        if (photoStr.startsWith('http://') || photoStr.startsWith('https://') || photoStr.startsWith('assets/')) {
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

    final int nights = int.tryParse(json['cantNoches']?.toString() ?? '') ?? 1;
    final DateTime checkIn = DateTime.parse(json['fechaLlegada'].toString());
    final DateTime checkOut = DateTime.parse(json['fechaSalida'].toString());
    final String clientName = json['nombreCliente']?.toString() ?? 'Cliente sin nombre';
    final double totalPrice = double.tryParse(json['precioTotal']?.toString() ?? '') ?? 0.0;

    return ReservationModel(
      cantNoches: nights,
      fechaLlegada: checkIn,
      fechaSalida: checkOut,
      nombreCliente: clientName,
      precioTotal: totalPrice,
      lugarFoto: parsedPhoto,
    );
  }
}
