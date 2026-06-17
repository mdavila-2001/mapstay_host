import 'package:mapstay_host/data/repositories/auth_repository_impl.dart';
import 'package:mapstay_host/data/repositories/property_repository_impl.dart';
import 'package:mapstay_host/data/repositories/reservation_repository_impl.dart';
import 'package:mapstay_host/domain/repositories/auth_repository.dart';
import 'package:mapstay_host/domain/repositories/property_repository.dart';
import 'package:mapstay_host/domain/repositories/reservation.dart';
import 'package:mapstay_host/core/network/api_client.dart';

class DI {
  static final DI instance = DI._();
  DI._();

  late final AuthRepository authRepository;
  late final PropertyRepository propertyRepository;
  late final ReservationRepository reservationRepository;

  Future<void> init() async {
    authRepository = AuthRepositoryImpl();
    propertyRepository = PropertyRepositoryImpl();
    reservationRepository = ReservationRepositoryImpl(apiClient: ApiClient());
  }
}
