// user_provider.dart
// Simple in-memory user management (replace with Firebase/backend in production)

class AppUser {
  String nombre;
  String carrera;
  String email;
  String password;
  String hobbies;

  AppUser({
    required this.nombre,
    required this.carrera,
    required this.email,
    required this.password,
    required this.hobbies,
  });
}

class UserProvider {
  UserProvider._();
  static final UserProvider instance = UserProvider._();

  final List<AppUser> _users = [];
  AppUser? _current;

  AppUser? get currentUser => _current;
  bool get isLoggedIn => _current != null;

  bool register({
    required String nombre,
    required String carrera,
    required String email,
    required String password,
    required String hobbies,
  }) {
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) return false;
    final user = AppUser(nombre: nombre, carrera: carrera, email: email, password: password, hobbies: hobbies);
    _users.add(user);
    _current = user;
    return true;
  }

  AppUser? login(String email, String password) {
    try {
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );
      _current = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  void logout() => _current = null;

  void updateProfile({String? nombre, String? carrera, String? hobbies}) {
    if (_current == null) return;
    if (nombre != null) _current!.nombre = nombre;
    if (carrera != null) _current!.carrera = carrera;
    if (hobbies != null) _current!.hobbies = hobbies;
  }
}
