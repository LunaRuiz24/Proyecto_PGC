// lib/services/api_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // URL REAL DEL BACKEND
  static const String baseUrl =
      'https://pgc-backend-aew8.onrender.com/api';

  // ==========================
  // TOKEN JWT
  // ==========================

  static Future<String?> getToken() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('auth_token');
  }

  // HEADERS AUTENTICADOS
  static Future<Map<String, String>>
      _getHeaders() async {

    final token = await getToken();

    return {

      'Content-Type': 'application/json',

      'Accept': 'application/json',

      if (token != null)
        'Authorization': 'Bearer $token',
    };
  }

  // ==========================
  // AUTENTICACIÓN
  // ==========================

  // REGISTRO
  static Future<Map<String, dynamic>?>
      register(
          Map<String, dynamic> userData) async {

    try {

      final response = await http.post(

        Uri.parse('$baseUrl/register/'),

        headers: {
          'Content-Type': 'application/json'
        },

        body: json.encode(userData),
      );

      print(
          '📡 Register status: ${response.statusCode}');
      print(
          '📦 Register response: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final data =
            json.decode(response.body);

        return data;
      }

      return null;

    } catch (e) {

      print('❌ Error en register: $e');

      return null;
    }
  }

  // LOGIN JWT
  static Future<Map<String, dynamic>?>
      login(
          String username,
          String password) async {

    try {

      final response = await http.post(

        Uri.parse('$baseUrl/login/'),

        headers: {
          'Content-Type': 'application/json'
        },

        body: json.encode({

          'username': username,

          'password': password,
        }),
      );

      print(
          '📡 Login status: ${response.statusCode}');
      print(
          '📦 Login response: ${response.body}');

      if (response.statusCode == 200) {

        final data =
            json.decode(response.body);

        final prefs =
            await SharedPreferences
                .getInstance();

        // GUARDAR TOKEN JWT
        await prefs.setString(
          'auth_token',
          data['access'],
        );

        return data;
      }

      return null;

    } catch (e) {

      print('❌ Error en login: $e');

      return null;
    }
  }

  // CERRAR SESIÓN
  static Future<void> logout() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
  }

  // VERIFICAR LOGIN
  static Future<bool> isLoggedIn() async {

    final token = await getToken();

    return token != null &&
        token.isNotEmpty;
  }

  // ==========================
  // PERFIL
  // ==========================

  static Future<Map<String, dynamic>?>
      getPerfil() async {

    try {

      final response = await http.get(

        Uri.parse('$baseUrl/perfil/'),

        headers: await _getHeaders(),
      );

      print(
          '📡 Perfil status: ${response.statusCode}');

      if (response.statusCode == 200) {

        return json.decode(response.body);
      }

      return null;

    } catch (e) {

      print('❌ Error getPerfil: $e');

      return null;
    }
  }

  // ==========================
  // TAREAS
  // ==========================

  static Future<List<dynamic>>
      getTareas() async {

    try {

      final response = await http.get(

        Uri.parse('$baseUrl/tareas/'),

        headers: await _getHeaders(),
      );

      print(
          '📡 GetTareas status: ${response.statusCode}');

      if (response.statusCode == 200) {

        return json.decode(response.body);
      }

      return [];
    } catch (e) {

      print('❌ Error getTareas: $e');

      return [];
    }
  }

  // CREAR TAREA
  static Future<Map<String, dynamic>?>
      createTarea(
          Map<String, dynamic> tareaData) async {

    try {

      final response = await http.post(

        Uri.parse('$baseUrl/tareas/'),

        headers: await _getHeaders(),

        body: json.encode(tareaData),
      );

      print(
          '📡 CreateTarea status: ${response.statusCode}');
      print(
          '📦 CreateTarea response: ${response.body}');

      if (response.statusCode == 201) {

        return json.decode(response.body);
      }

      return null;

    } catch (e) {

      print('❌ Error createTarea: $e');

      return null;
    }
  }

  // ACTUALIZAR TAREA
  static Future<Map<String, dynamic>?>
      updateTarea(
          String id,
          Map<String, dynamic> tareaData) async {

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

  // ELIMINAR TAREA
  static Future<bool>
      deleteTarea(String id) async {

    try {

      final response = await http.delete(

        Uri.parse('$baseUrl/tareas/$id/'),

        headers: await _getHeaders(),
      );

      return response.statusCode == 204 ||
          response.statusCode == 200;

    } catch (e) {

      print('❌ Error deleteTarea: $e');

      return false;
    }
  }

  // ==========================
  // EVENTOS
  // ==========================

  static Future<List<dynamic>>
      getEventos() async {

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
static Future<Map<String, dynamic>?> createEvento(
    Map<String, dynamic> eventoData) async {
  try {
    print("🚀 createEvento llamado con: $eventoData");

    final response = await http.post(
      Uri.parse('$baseUrl/eventos/'),
      headers: await _getHeaders(),
      body: json.encode(eventoData),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 201) {
      return json.decode(response.body);
    }

    return null;
  } catch (e) {
    print('❌ Error createEvento: $e');
    return null;
  }
}

  static Future<bool>
      deleteEvento(String id) async {

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
}