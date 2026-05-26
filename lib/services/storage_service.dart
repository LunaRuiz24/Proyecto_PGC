import 'dart:html' as html;
import 'dart:convert';
import 'dart:js' as js;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  void save(String key, dynamic data) {
    final jsonString = jsonEncode(data);
    html.window.localStorage[key] = jsonString;
    print('✅ Guardado: $key');
  }

  dynamic load(String key) {
    final jsonString = html.window.localStorage[key];
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  void delete(String key) {
    html.window.localStorage.remove(key);
  }

  // ✅ MÉTODO QUE FUNCIONA SEGURO
  List<String> getAllKeys() {
    final keys = <String>[];
    try {
      // Usar JavaScript para obtener todas las keys
      final localStorage = js.context['localStorage'];
      final length = localStorage.callMethod('getItem', ['length']) ?? 0;
      
      for (var i = 0; i < length; i++) {
        final key = localStorage.callMethod('key', [i]);
        if (key != null && key.toString().isNotEmpty) {
          keys.add(key.toString());
        }
      }
    } catch (e) {
      print('Error obteniendo keys: $e');
    }
    return keys;
  }
}