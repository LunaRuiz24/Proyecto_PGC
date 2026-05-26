// lib/models/app_data.dart
class AppUserData {
  final String id;
  final String nombre;
  final String carrera;
  final String email;
  final String password;
  final String hobbies;
  final DateTime createdAt;

  AppUserData({
    required this.id,
    required this.nombre,
    required this.carrera,
    required this.email,
    required this.password,
    required this.hobbies,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'carrera': carrera,
    'email': email,
    'password': password,
    'hobbies': hobbies,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppUserData.fromJson(Map<String, dynamic> json) => AppUserData(
    id: json['id'],
    nombre: json['nombre'],
    carrera: json['carrera'],
    email: json['email'],
    password: json['password'],
    hobbies: json['hobbies'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class CalendarioEventData {
  final String id;
  final String titulo;
  final DateTime fecha;
  final String hora;
  final String duracion;
  final String tipo;

  CalendarioEventData({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.hora,
    required this.duracion,
    required this.tipo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'fecha': fecha.toIso8601String(),
    'hora': hora,
    'duracion': duracion,
    'tipo': tipo,
  };

  factory CalendarioEventData.fromJson(Map<String, dynamic> json) => CalendarioEventData(
    id: json['id'],
    titulo: json['titulo'],
    fecha: DateTime.parse(json['fecha']),
    hora: json['hora'],
    duracion: json['duracion'],
    tipo: json['tipo'],
  );
}

class RecordatorioData {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String hora;
  final bool completado;
  final String categoria;

  RecordatorioData({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.completado,
    required this.categoria,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'fecha': fecha.toIso8601String(),
    'hora': hora,
    'completado': completado,
    'categoria': categoria,
  };

  factory RecordatorioData.fromJson(Map<String, dynamic> json) => RecordatorioData(
    id: json['id'],
    titulo: json['titulo'],
    descripcion: json['descripcion'],
    fecha: DateTime.parse(json['fecha']),
    hora: json['hora'],
    completado: json['completado'],
    categoria: json['categoria'],
  );
}

class TareaData {
  final String id;
  final String titulo;
  final String categoria;
  final bool completada;
  final DateTime fecha;
  final int prioridad;

  TareaData({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.completada,
    required this.fecha,
    required this.prioridad,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'categoria': categoria,
    'completada': completada,
    'fecha': fecha.toIso8601String(),
    'prioridad': prioridad,
  };

  factory TareaData.fromJson(Map<String, dynamic> json) => TareaData(
    id: json['id'],
    titulo: json['titulo'],
    categoria: json['categoria'],
    completada: json['completada'],
    fecha: DateTime.parse(json['fecha']),
    prioridad: json['prioridad'],
  );
}