import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppUser {
  String id;
  String nombre;
  String carrera;
  String email;
  String password;
  String hobbies;

  AppUser({
    required this.id,
    required this.nombre,
    required this.carrera,
    required this.email,
    required this.password,
    required this.hobbies,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'carrera': carrera,
    'email': email,
    'password': password,
    'hobbies': hobbies,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'],
    nombre: json['nombre'],
    carrera: json['carrera'],
    email: json['email'],
    password: json['password'],
    hobbies: json['hobbies'],
  );
}

class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();
  factory UserProvider() => _instance;
  UserProvider._internal();
  
  static UserProvider get instance => _instance;
  
  final StorageService _storage = StorageService();
  List<AppUser> _users = [];
  AppUser? _current;

  List<AppUser> get users => _users;
  AppUser? get currentUser => _current;

  void loadAllUsers() {
    _users.clear();
    final allKeys = _storage.getAllKeys();
    
    for (final key in allKeys) {
      if (key.endsWith('_profile')) {
        final userData = _storage.load(key);
        if (userData != null) {
          _users.add(AppUser.fromJson(userData));
        }
      }
    }
    print('👥 Usuarios cargados: ${_users.length}');
    notifyListeners();
  }

  Future<bool> register({
    required String nombre,
    required String carrera,
    required String email,
    required String password,
    required String hobbies,
  }) async {
    for (var user in _users) {
      if (user.email.toLowerCase() == email.toLowerCase()) {
        return false;
      }
    }
    
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newUser = AppUser(
      id: id,
      nombre: nombre,
      carrera: carrera,
      email: email,
      password: password,
      hobbies: hobbies,
    );
    
    _users.add(newUser);
    _current = newUser;
    
    _storage.save('${id}_profile', newUser.toJson());
    
    notifyListeners();
    return true;
  }

  AppUser? login(String email, String password) {
    for (var user in _users) {
      if (user.email.toLowerCase() == email.toLowerCase() && user.password == password) {
        _current = user;
        notifyListeners();
        return user;
      }
    }
    return null;
  }

  AppUser? loginByFullName(String fullName, String password) {
    for (var user in _users) {
      if (user.nombre.toLowerCase() == fullName.toLowerCase() && user.password == password) {
        _current = user;
        notifyListeners();
        return user;
      }
    }
    return null;
  }

  void logout() {
    _current = null;
    notifyListeners();
  }

  void updateProfile({String? nombre, String? carrera, String? hobbies}) {
    if (_current == null) return;
    
    if (nombre != null) _current!.nombre = nombre;
    if (carrera != null) _current!.carrera = carrera;
    if (hobbies != null) _current!.hobbies = hobbies;
    
    _storage.save('${_current!.id}_profile', _current!.toJson());
    notifyListeners();
  }
}