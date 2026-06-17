import '../entities/reservation.dart';

abstract class ReservationRepository {
  Future<List<Reservation>> getReservationsByPlace(int placeId);
}
