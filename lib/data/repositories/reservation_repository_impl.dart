import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation.dart';
import '../models/reservation_model.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ApiClient apiClient;

  ReservationRepositoryImpl({required this.apiClient});

  @override
  Future<List<Reservation>> getReservationsByPlace(int placeId) async {
    final response = await apiClient.getRequest('/reservas/lugar/$placeId');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      List<dynamic> rawList = [];

      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map) {
        rawList = decoded['data'] ??
            decoded['reservas'] ??
            decoded['reservations'] ??
            decoded['reserva'] ??
            [];
      }

      return rawList.map((item) => ReservationModel.fromJson(item)).toList();
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ??
          decoded['error'] ??
          'Error al obtener el historial de reservas';
      throw Exception(errorMsg);
    }
  }
}
