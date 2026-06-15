class Property {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioNoche;
  final String ciudad;
  final int hostId;
  final bool activo;
  final String firstPhoto;

  Property({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioNoche,
    required this.ciudad,
    required this.hostId,
    required this.activo,
    required this.firstPhoto,
  });
}
