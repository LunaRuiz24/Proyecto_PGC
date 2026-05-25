// lib/services/api_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // CAMBIA ESTA URL POR LA DE TU BACKEND EN RENDER
  static const String baseUrl = 'https://pgc-backend.onrender.com/api';

  // Obtener token guardado - CORREGIDO
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();  // ← CORREGIDO
    return prefs.getString('auth_token');
  }

  // Headers para peticiones autenticadas
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',  // ← Para DRF TokenAuth
      // Si usas JWT: 'Authorization': 'Bearer $token',
    };
  }

  // ========== AUTENTICACIÓN ==========

  // Registrar usuario
  static Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      print('📡 Register status: ${response.statusCode}');
      print('📦 Register response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return data['user'];
      }
      return null;
    } catch (e) {
      print('❌ Error en register: $e');
      return null;
    }
  }

  // Iniciar sesión
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': email,
          'password': password,
        }),
      );

      print('📡 Login status: ${response.statusCode}');
      print('📦 Login response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return data['user'];
      }
      return null;
    } catch (e) {
      print('❌ Error en login: $e');
      return null;
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ========== TAREAS ==========

  // Obtener todas las tareas
  static Future<List<dynamic>> getTareas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tareas/'),
        headers: await _getHeaders(),
      );

      print('📡 GetTareas status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('❌ Error getTareas: $e');
      return [];
    }
  }

  // Crear tarea
  static Future<Map<String, dynamic>?> createTarea(Map<String, dynamic> tareaData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tareas/'),
        headers: await _getHeaders(),
        body: json.encode(tareaData),
      );

      print('📡 CreateTarea status: ${response.statusCode}');
      print('📦 CreateTarea response: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('❌ Error createTarea: $e');
      return null;
    }
  }

  // Actualizar tarea
  static Future<Map<String, dynamic>?> updateTarea(String id, Map<String, dynamic> tareaData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tareas/$id/'),
        headers: await _getHeaders(),
        body: json.encode(tareaData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('❌ Error updateTarea: $e');
      return null;
    }
  }

  // Eliminar tarea
  static Future<bool> deleteTarea(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tareas/$id/'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('❌ Error deleteTarea: $e');
      return false;
    }
  }

  // ========== EVENTOS DEL CALENDARIO ==========

  static Future<List<dynamic>> getEventos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/eventos/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('❌ Error getEventos: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createEvento(Map<String, dynamic> eventoData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/eventos/'),
        headers: await _getHeaders(),
        body: json.encode(eventoData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('❌ Error createEvento: $e');
      return null;
    }
  }

  static Future<bool> deleteEvento(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/eventos/$id/'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 204;
    } catch (e) {
      print('❌ Error deleteEvento: $e');
      return false;
    }
  }

  // ========== RECORDATORIOS ==========

  static Future<List<dynamic>> getRecordatorios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recordatorios/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('❌ Error getRecordatorios: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createRecordatorio(Map<String, dynamic> recordatorioData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recordatorios/'),
        headers: await _getHeaders(),
        body: json.encode(recordatorioData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('❌ Error createRecordatorio: $e');
      return null;
    }
  }

  static Future<bool> deleteRecordatorio(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/recordatorios/$id/'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 204;
    } catch (e) {
      print('❌ Error deleteRecordatorio: $e');
      return false;
    }
  }
}