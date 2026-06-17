import 'package:flutter/material.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationRepository reservationRepository;

  ReservationProvider({required this.reservationRepository});

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReservationsByPlace(int placeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reservations = await reservationRepository.getReservationsByPlace(placeId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
