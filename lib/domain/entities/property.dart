class Property {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioNoche;
  final double costoLimpieza;
  final int cantPersonas;
  final int cantCamas;
  final int cantBanios;
  final int cantHabitaciones;
  final int cantVehiculosParqueo;
  final bool tieneWifi;
  final String latitud;
  final String longitud;
  final String ciudad;
  final int hostId;
  final bool activo;
  final String firstPhoto;
  final List<String> fotos;

  Property({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioNoche,
    required this.costoLimpieza,
    required this.cantPersonas,
    required this.cantCamas,
    required this.cantBanios,
    required this.cantHabitaciones,
    required this.cantVehiculosParqueo,
    required this.tieneWifi,
    required this.latitud,
    required this.longitud,
    required this.ciudad,
    required this.hostId,
    required this.activo,
    required this.firstPhoto,
    required this.fotos,
  });
}
