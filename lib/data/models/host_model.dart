import '../../domain/entities/host.dart';

class HostModel extends Host {
  HostModel({
    required super.id,
    required super.nombreCompleto,
    required super.email,
    required super.telefono,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      id: json['id'] as int? ?? 0,
      nombreCompleto: json['nombrecompleto'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombrecompleto': nombreCompleto,
      'email': email,
      'telefono': telefono,
    };
  }
}
