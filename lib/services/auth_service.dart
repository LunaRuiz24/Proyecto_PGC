import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Cambia esto por tu URL real de Render
  final String baseUrl = "https://pgc-backend.onrender.com/api"; 
  
  // Instancia para guardar los tokens de forma segura en el celular
  final _storage = const FlutterSecureStorage();

  // Función para iniciar sesión
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/token/'); // O la ruta exacta que definiste en tu urls.py para JWT
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardamos los tokens en el almacenamiento seguro del teléfono
        await _storage.write(key: 'access_token', value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);
        
        print("Login exitoso. Tokens guardados.");
        return true;
      } else {
        print("Error en las credenciales: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // Función para obtener el token guardado cuando vayas a hacer peticiones a tus otras apps (tareas, calendario)
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Función para cerrar sesión
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}