import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/photo_url_helper.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/reservation.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../providers/reservation_provider.dart';
import '../widgets/mapstay_app_bar.dart';
import '../widgets/mapstay_drawer.dart';
import '../widgets/mapstay_toast.dart';

class PlaceReservationsScreen extends StatefulWidget {
  final int? propertyId;

  const PlaceReservationsScreen({super.key, this.propertyId});

  @override
  State<PlaceReservationsScreen> createState() =>
      _PlaceReservationsScreenState();
}

class _PlaceReservationsScreenState extends State<PlaceReservationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedPropertyId;
  String _selectedFilter = 'Próximas';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final propertyProvider = Provider.of<PropertyProvider>(
        context,
        listen: false,
      );

      if (propertyProvider.properties.isEmpty && authProvider.userId != null) {
        propertyProvider.fetchProperties(authProvider.userId!).then((_) {
          _initializeWithProperties(propertyProvider.properties);
        });
      } else {
        _initializeWithProperties(propertyProvider.properties);
      }
    });
  }

  void _initializeWithProperties(List<Property> properties) {
    if (!mounted) return;
    int? targetId = widget.propertyId;
    if (targetId == null && properties.isNotEmpty) {
      targetId = properties.first.id;
    }
    if (targetId != null) {
      setState(() {
        _selectedPropertyId = targetId;
      });
      _fetchReservations(targetId);
    }
  }

  void _fetchReservations(int placeId) {
    Provider.of<ReservationProvider>(
      context,
      listen: false,
    ).fetchReservationsByPlace(placeId).then((_) {
      if (!mounted) return;
      final provider = Provider.of<ReservationProvider>(context, listen: false);
      if (provider.errorMessage != null) {
        MapStayToast.show(
          context,
          message: provider.errorMessage!,
          type: MapStayToastType.error,
        );
      }
    });
  }

  List<Reservation> _getFilteredReservations(List<Reservation> reservations) {
    final now = DateTime.now();
    return reservations.where((res) {
      if (_selectedFilter == 'Próximas') {
        return res.fechaLlegada.isAfter(now) ||
            (res.fechaLlegada.year == now.year &&
                res.fechaLlegada.month == now.month &&
                res.fechaLlegada.day == now.day);
      } else if (_selectedFilter == 'Pasadas') {
        return res.fechaSalida.isBefore(now);
      } else {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final reservationProvider = Provider.of<ReservationProvider>(context);

    final currentProperty = propertyProvider.properties
        .cast<Property>()
        .firstWhere(
          (p) => p.id == _selectedPropertyId,
          orElse: () => Property(
            id: 0,
            nombre: 'Elegir lugar',
            descripcion: '',
            precioNoche: 0,
            costoLimpieza: 0,
            cantPersonas: 0,
            cantCamas: 0,
            cantBanios: 0,
            cantHabitaciones: 0,
            cantVehiculosParqueo: 0,
            tieneWifi: false,
            latitud: '',
            longitud: '',
            ciudad: '',
            hostId: 0,
            activo: false,
            firstPhoto: '',
            fotos: [],
          ),
        );

    final filteredList = _getFilteredReservations(
      reservationProvider.reservations,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: MapStayAppBar(
        title: 'Ver Reservas Recibidas',
        isBackButton: widget.propertyId != null,
        onMenuPressed: () {
          if (widget.propertyId != null) {
            Navigator.of(context).pop();
          } else {
            _scaffoldKey.currentState?.openDrawer();
          }
        },
      ),
      drawer: MapStayDrawer(
        currentRoute: '/reservas',
        onNavigate: (route) {
          Navigator.of(context).pop();
          if (route == '/properties') {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          }
        },
        onLogout: () async {
          final navigator = Navigator.of(context);
          await authProvider.logout();
          navigator.pushReplacementNamed('/');
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedPropertyId != null) {
            _fetchReservations(_selectedPropertyId!);
          }
        },
        color: theme.colorScheme.secondary,
        backgroundColor: theme.colorScheme.surfaceContainer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.propertyId == null &&
                    propertyProvider.properties.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedPropertyId,
                        dropdownColor: theme.colorScheme.surfaceContainer,
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: theme.colorScheme.secondary,
                          size: 30,
                        ),
                        isExpanded: true,
                        items: propertyProvider.properties.map((property) {
                          return DropdownMenuItem<int>(
                            value: property.id,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child:
                                        property.firstPhoto.startsWith(
                                          'assets/',
                                        )
                                        ? Image.asset(
                                            property.firstPhoto,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            PhotoUrlHelper.ensureProtocol(property.firstPhoto),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                                      'assets/no_pic.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    property.nombre,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPropertyId = val;
                            });
                            _fetchReservations(val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Próximas', 'Pasadas', 'Canceladas'].map((
                      filter,
                    ) {
                      final isActive = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.colorScheme.surfaceContainerHigh
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? theme.colorScheme.secondary
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isActive
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                if (reservationProvider.isLoading)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        const _BookingSkeletonCard(),
                  )
                else if (filteredList.isEmpty)
                  _buildEmptyState(theme)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final reservation = filteredList[index];
                      return _BookingCard(
                        reservation: reservation,
                        propertyName: currentProperty.nombre,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF171F33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin Reservas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este lugar no tiene reservas todavia. Intenta ajustar los filtros o el rango de fechas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Reservation reservation;
  final String propertyName;

  const _BookingCard({required this.reservation, required this.propertyName});

  String _formatMonthDay(DateTime dt) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingId = 'BK-${reservation.id ?? ""}';

    final checkInTime =
        reservation.fechaLlegada.hour == 0 &&
            reservation.fechaLlegada.minute == 0
        ? '3:00 PM'
        : _formatTime(reservation.fechaLlegada);

    final checkOutTime =
        reservation.fechaSalida.hour == 0 && reservation.fechaSalida.minute == 0
        ? '11:00 AM'
        : _formatTime(reservation.fechaSalida);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.nombreCliente,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$propertyName · $bookingId',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      size: 14,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reservation.cantNoches} noches',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF060E20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.05),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 48,
                  right: 48,
                  child: Container(height: 2, color: const Color(0xFF334155)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LLEGADA',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatMonthDay(reservation.fechaLlegada),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            checkInTime,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'SALIDA',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatMonthDay(reservation.fechaSalida),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            checkOutTime,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '\$${reservation.precioTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingSkeletonCard extends StatelessWidget {
  const _BookingSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
