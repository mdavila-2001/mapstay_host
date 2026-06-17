class Reservation {
  final int cantNoches;
  final DateTime fechaLlegada;
  final DateTime fechaSalida;
  final String nombreCliente;
  final double precioTotal;
  final String? lugarFoto;

  Reservation({
    required this.cantNoches,
    required this.fechaLlegada,
    required this.fechaSalida,
    required this.nombreCliente,
    required this.precioTotal,
    required this.lugarFoto,
  });
}
