import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';
import 'dart:math' as math;

class Tarea {
  final String id;
  String titulo;
  String categoria;
  bool completada;
  DateTime fecha;
  int prioridad;

  Tarea({
    required this.id,
    required this.titulo,
    required this.categoria,
    this.completada = false,
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

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
    id: json['id'],
    titulo: json['titulo'],
    categoria: json['categoria'],
    completada: json['completada'],
    fecha: DateTime.parse(json['fecha']),
    prioridad: json['prioridad'],
  );
}

class SeguimientoScreen extends StatefulWidget {
  const SeguimientoScreen({super.key});

  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  bool _showAdd = false;
  bool _loading = true;
  List<Tarea> _tareas = [];

  final _tituloCtrl = TextEditingController();
  String _newCat = 'académico';
  int _newPri = 2;

  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );
    _cargarDatos();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _tituloCtrl.dispose();
    super.dispose();
  }

  // ✅ CORREGIDO - Usa load() en lugar de loadData(), sin async/await
  void _cargarDatos() {
    setState(() => _loading = true);
    
    final userId = UserProvider.instance.currentUser?.id;
    if (userId != null) {
      final tareasData = _storage.load('${userId}_tareas');
      if (tareasData != null && tareasData is List) {
        _tareas.clear();
        for (var t in tareasData) {
          _tareas.add(Tarea.fromJson(t));
        }
      }
    }
    
    setState(() => _loading = false);
    _animCtrl.forward();
  }

  // ✅ CORREGIDO - Usa save() en lugar de saveData(), sin async/await
  void _saveTareas() {
    final userId = UserProvider.instance.currentUser?.id;
    if (userId == null) return;
    
    final tareasJson = _tareas.map((t) => t.toJson()).toList();
    _storage.save('${userId}_tareas', tareasJson);
    print('💾 Tareas guardadas: ${_tareas.length}');
  }

  List<Tarea> get _semana {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return _tareas.where((t) {
      return t.fecha.isAfter(start.subtract(const Duration(days: 1))) &&
          t.fecha.isBefore(start.add(const Duration(days: 7)));
    }).toList();
  }

  double get _progresoSemana {
    if (_semana.isEmpty) return 0;
    return _semana.where((t) => t.completada).length / _semana.length;
  }

  Map<String, int> get _categoriasCompletadas {
    final Map<String, int> map = {};
    for (final t in _tareas.where((t) => t.completada)) {
      map[t.categoria] = (map[t.categoria] ?? 0) + 1;
    }
    return map;
  }

  Color _colorCat(String cat) {
    return {
      'académico': const Color(0xff6c63ff),
      'personal': const Color(0xff00d4aa),
      'trabajo': const Color(0xffff6b6b),
      'salud': const Color(0xffffb347),
    }[cat] ?? const Color(0xff6c63ff);
  }

  // ✅ CORREGIDO - sin async/await
  void _agregarTarea() {
    if (_tituloCtrl.text.trim().isEmpty) return;

    final tarea = Tarea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloCtrl.text.trim(),
      categoria: _newCat,
      prioridad: _newPri,
      fecha: DateTime.now(),
    );

    setState(() {
      _tareas.add(tarea);
      _showAdd = false;
      _tituloCtrl.clear();
    });

    _saveTareas();
    _animCtrl.reset();
    _animCtrl.forward();
  }

  // ✅ CORREGIDO - sin async/await
  void _toggleCompletada(Tarea t) {
    setState(() {
      t.completada = !t.completada;
    });
    _saveTareas();
    _animCtrl.reset();
    _animCtrl.forward();
  }

  // ✅ CORREGIDO - sin async/await
  void _deleteTarea(Tarea t) {
    setState(() {
      _tareas.remove(t);
    });
    _saveTareas();
    _animCtrl.reset();
    _animCtrl.forward();
  }

  String _estadoProductividad() {
    if (_tareas.isEmpty) return 'Sin datos';
    final pct = _progresoSemana;
    if (pct >= 0.8) return '🔥 Excelente';
    if (pct >= 0.6) return '⚡ Buena';
    if (pct >= 0.4) return '📈 Regular';
    return '💡 En progreso';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? Colors.white : const Color(0xff1a1a2e);
    final subColor = dark ? Colors.white54 : Colors.black45;
    final bgCard = dark ? const Color(0xff1a2535) : Colors.white;

    final completadas = _tareas.where((t) => t.completada).length;
    final total = _tareas.length;

    return Scaffold(
      backgroundColor: dark ? const Color(0xff0d1b2a) : const Color(0xfff0f4ff),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(dark),

            if (_showAdd) ...[
              const SizedBox(height: 16),
              _buildAddForm(dark, bgCard),
            ],

            const SizedBox(height: 16),
            _buildStatsRow(completadas, total, dark, bgCard),
            const SizedBox(height: 16),
            _buildProgresoSemanal(),
            const SizedBox(height: 16),
            _buildProductividad(dark, textColor, subColor, bgCard),
            const SizedBox(height: 16),
            _buildCategorias(dark, textColor, subColor, bgCard),
            const SizedBox(height: 16),

            if (_tareas.isEmpty)
              _buildEmptyState(dark, bgCard, textColor, subColor),

            if (_tareas.isNotEmpty)
              _buildListaTareas(dark, textColor, subColor, bgCard),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool dark) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: dark ? Colors.white70 : Colors.black54),
        ),
        const Spacer(),
        Text(
          '📊 Seguimiento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: dark ? Colors.white : const Color(0xff1a1a2e),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            setState(() {
              _showAdd = !_showAdd;
            });
          },
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_showAdd ? Icons.close : Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool dark, Color bgCard, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.task_alt, size: 60, color: const Color(0xff6c63ff).withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No tienes tareas', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Presiona + para crear tu primera tarea', style: TextStyle(color: subColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAddForm(bool dark, Color bgCard) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          TextField(
            controller: _tituloCtrl,
            style: TextStyle(color: dark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Título',
              filled: true,
              fillColor: dark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildDropdown(['académico', 'personal', 'trabajo', 'salud'], _newCat, (v) => _newCat = v!, dark)),
              const SizedBox(width: 10),
              Expanded(child: _buildDropdown(['Baja', 'Media', 'Alta'], 
                  _newPri == 1 ? 'Baja' : _newPri == 2 ? 'Media' : 'Alta', 
                  (v) { _newPri = v == 'Baja' ? 1 : v == 'Media' ? 2 : 3; }, dark)),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _agregarTarea,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6c63ff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: dark ? const Color(0xff1e2d40) : Colors.white,
          style: TextStyle(color: dark ? Colors.white : Colors.black),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatsRow(int completadas, int total, bool dark, Color bgCard) {
    return Row(
      children: [
        _StatCard('Completadas', '$completadas', Icons.check_circle, const Color(0xff00d4aa), dark, bgCard),
        const SizedBox(width: 12),
        _StatCard('Pendientes', '${total - completadas}', Icons.pending, const Color(0xffff6b6b), dark, bgCard),
        const SizedBox(width: 12),
        _StatCard('Total', '$total', Icons.list_alt, const Color(0xff6c63ff), dark, bgCard),
      ],
    );
  }

  Widget _buildProgresoSemanal() {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_view_week, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Progreso Semanal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(_progresoSemana * 100 * _anim.value).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('${_semana.where((t) => t.completada).length}/${_semana.length}',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _progresoSemana * _anim.value,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 8,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductividad(bool dark, Color textColor, Color subColor, Color bgCard) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('Productividad', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xff6c63ff).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(_estadoProductividad(), style: const TextStyle(color: Color(0xff6c63ff), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorias(bool dark, Color textColor, Color subColor, Color bgCard) {
    final categorias = _categoriasCompletadas;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categorías', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (categorias.isEmpty)
            Text('Aún no hay estadísticas', style: TextStyle(color: subColor, fontSize: 12)),
          if (categorias.isNotEmpty)
            ...categorias.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: TextStyle(color: textColor, fontSize: 12)),
                        Text('${e.value}', style: TextStyle(color: _colorCat(e.key), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: e.value / categorias.values.reduce(math.max).toDouble(),
                      backgroundColor: _colorCat(e.key).withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(_colorCat(e.key)),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildListaTareas(bool dark, Color textColor, Color subColor, Color bgCard) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tareas', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._tareas.map((t) {
            return Dismissible(
              key: Key(t.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              onDismissed: (_) => _deleteTarea(t),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: t.completada
                      ? _colorCat(t.categoria).withOpacity(0.07)
                      : (dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleCompletada(t),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: t.completada ? _colorCat(t.categoria) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: t.completada ? _colorCat(t.categoria) : (dark ? Colors.white30 : Colors.black26),
                            width: 2,
                          ),
                        ),
                        child: t.completada ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.titulo,
                        style: TextStyle(
                          color: t.completada ? subColor : textColor,
                          decoration: t.completada ? TextDecoration.lineThrough : null,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool dark;
  final Color bgCard;

  const _StatCard(this.label, this.value, this.icon, this.color, this.dark, this.bgCard);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgCard.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
