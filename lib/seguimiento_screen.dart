// ignore_for_file: depend_on_referenced_packages, unused_import
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
    'id': id, 'titulo': titulo, 'categoria': categoria,
    'completada': completada, 'fecha': fecha.toIso8601String(), 'prioridad': prioridad,
  };

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
    id: json['id'], titulo: json['titulo'], categoria: json['categoria'],
    completada: json['completada'], fecha: DateTime.parse(json['fecha']), prioridad: json['prioridad'],
  );
}

// ==================== ALMACENAMIENTO ====================
class TareaStore {
  static final instance = TareaStore._();
  TareaStore._();
  
  List<Tarea> _tareas = [];
  List<Tarea> get tareas => _tareas;
  
  get SharedPreferences => null;

  Future<void> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('tareas_$userId');
    _tareas = jsonStr != null ? (json.decode(jsonStr) as List).map((e) => Tarea.fromJson(e)).toList() : [];
  }

  Future<void> save(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tareas_$userId', json.encode(_tareas.map((e) => e.toJson()).toList()));
  }

  Future<void> add(Tarea t, String userId) async { _tareas.add(t); await save(userId); }
  Future<void> update(Tarea t, String userId) async { await save(userId); }
}

// ==================== PANTALLA PRINCIPAL ====================
class SeguimientoScreen extends StatefulWidget {
  final String userId;
  const SeguimientoScreen({super.key, required this.userId});

  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;
  bool _showAdd = false;
  bool _loading = true;
  
  final _tituloCtrl = TextEditingController();
  String _newCat = 'académico';
  int _newPri = 2;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _cargarDatos();
  }

  @override
  void dispose() { _animCtrl.dispose(); _tituloCtrl.dispose(); super.dispose(); }

  Future<void> _cargarDatos() async {
    await TareaStore.instance.load(widget.userId);
    setState(() => _loading = false);
    _animCtrl.forward();
  }

  List<Tarea> get _tareas => TareaStore.instance.tareas;
  
  List<Tarea> get _semana {
    final start = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    return _tareas.where((t) => t.fecha.isAfter(start.subtract(const Duration(days: 1))) && 
                                t.fecha.isBefore(start.add(const Duration(days: 7)))).toList();
  }

  double get _progresoSemana => _semana.isEmpty ? 0 : _semana.where((t) => t.completada).length / _semana.length;
  double get _progresoTotal => _tareas.isEmpty ? 0 : _tareas.where((t) => t.completada).length / _tareas.length;
  
  Map<String, int> get _categoriasCompletadas => {
    for (final t in _tareas.where((t) => t.completada)) t.categoria: (_tareas.where((t) => t.completada && t.categoria == t.categoria).length)
  }..removeWhere((k, v) => v == 0);

  Color _colorCat(String cat) => {
    'académico': const Color(0xff6c63ff), 'personal': const Color(0xff00d4aa),
    'trabajo': const Color(0xffff6b6b), 'salud': const Color(0xffffb347),
  }[cat] ?? const Color(0xff6c63ff);

  Future<void> _agregarTarea() async {
    if (_tituloCtrl.text.isEmpty) return;
    final tarea = Tarea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloCtrl.text, categoria: _newCat, prioridad: _newPri, fecha: DateTime.now(),
    );
    setState(() { _tareas.add(tarea); _showAdd = false; _tituloCtrl.text = ''; });
    await TareaStore.instance.add(tarea, widget.userId);
    _animCtrl.reset(); _animCtrl.forward();
  }

  void _toggleCompletada(Tarea t) async {
    setState(() => t.completada = !t.completada);
    await TareaStore.instance.update(t, widget.userId);
    _animCtrl.reset(); _animCtrl.forward();
  }

  String _estadoProductividad() {
    final pct = _progresoSemana;
    if (_tareas.isEmpty) return '📝 Sin tareas';
    if (pct >= 0.8) return '🔥 Excelente';
    if (pct >= 0.6) return '⚡ Buena';
    if (pct >= 0.4) return '📈 Regular';
    return '💡 En progreso';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
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
            _buildHeader(dark, completadas, total),
            if (_showAdd) _buildAddForm(dark, bgCard),
            if (_tareas.isEmpty) _buildEmptyState(dark, bgCard, textColor, subColor),
            if (_tareas.isNotEmpty) ...[
              _buildStatsRow(completadas, total, dark, bgCard),
              const SizedBox(height: 16),
              _buildProgresoSemanal(dark),
              const SizedBox(height: 16),
              _buildProductividad(dark, textColor, subColor, bgCard),
              if (_categoriasCompletadas.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCategorias(dark, textColor, subColor, bgCard),
              ],
              const SizedBox(height: 16),
              _buildListaTareas(dark, textColor, subColor, bgCard),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== COMPONENTES ====================
  Widget _buildHeader(bool dark, int completadas, int total) => Row(
    children: [
      IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, color: dark ? Colors.white70 : Colors.black54)),
      const Spacer(),
      Text('📊 Seguimiento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: dark ? Colors.white : const Color(0xff1a1a2e))),
      const Spacer(),
      IconButton(onPressed: () => setState(() => _showAdd = !_showAdd), icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]), borderRadius: BorderRadius.circular(10)),
        child: Icon(_showAdd ? Icons.close : Icons.add, color: Colors.white, size: 20),
      )),
    ],
  );

  Widget _buildEmptyState(bool dark, Color bgCard, Color textColor, Color subColor) => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(color: bgCard.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      Icon(Icons.task_alt, size: 60, color: const Color(0xff6c63ff).withOpacity(0.5)),
      const SizedBox(height: 16),
      Text('No tienes tareas', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Presiona + para crear tu primera tarea', style: TextStyle(color: subColor, fontSize: 13)),
    ]),
  );

  Widget _buildAddForm(bool dark, Color bgCard) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: bgCard.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      TextField(
        controller: _tituloCtrl,
        style: TextStyle(color: dark ? Colors.white : Colors.black),
        decoration: InputDecoration(hintText: 'Título', filled: true, fillColor: dark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.04),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _buildDropdown('categoría', ['académico', 'personal', 'trabajo', 'salud'], _newCat, (v) => _newCat = v!, dark)),
        const SizedBox(width: 10),
        Expanded(child: _buildDropdown('prioridad', ['Baja', 'Media', 'Alta'], _newPri == 1 ? 'Baja' : _newPri == 2 ? 'Media' : 'Alta', 
          (v) => _newPri = v == 'Baja' ? 1 : v == 'Media' ? 2 : 3, dark)),
      ]),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _agregarTarea, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff6c63ff), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Agregar', style: TextStyle(color: Colors.white))),
    ]),
  );

  Widget _buildDropdown(String hint, List<String> items, String value, Function(String) onChanged, bool dark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: dark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value, isExpanded: true, dropdownColor: dark ? const Color(0xff1e2d40) : Colors.white,
      style: TextStyle(color: dark ? Colors.white : Colors.black, fontSize: 13),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => onChanged(v!),
    )),
  );

  Widget _buildStatsRow(int completadas, int total, bool dark, Color bgCard) => Row(children: [
    _StatCard('Completadas', '$completadas', Icons.check_circle, const Color(0xff00d4aa), dark, bgCard),
    const SizedBox(width: 12),
    _StatCard('Pendientes', '${total - completadas}', Icons.pending, const Color(0xffff6b6b), dark, bgCard),
    const SizedBox(width: 12),
    _StatCard('Total', '$total', Icons.list_alt, const Color(0xff6c63ff), dark, bgCard),
  ]);

  Widget _buildProgresoSemanal(bool dark) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.calendar_view_week, color: Colors.white, size: 20), SizedBox(width: 8), Text('Progreso Semanal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(_progresoSemana * 100 * _anim.value).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text('${_semana.where((t) => t.completada).length}/${_semana.length}', style: const TextStyle(color: Colors.white70)),
        ]),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: _progresoSemana * _anim.value, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 8),
      ]),
    ),
  );

  Widget _buildProductividad(bool dark, Color textColor, Color subColor, Color bgCard) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(dark, bgCard),
    child: Column(children: [
      Row(children: [
        const Text('⚡', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text('Productividad', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xff6c63ff).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(_estadoProductividad(), style: const TextStyle(color: Color(0xff6c63ff), fontSize: 12))),
      ]),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(7, (i) {
        final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
        final isToday = DateTime.now().weekday - 1 == i;
        return Column(children: [
          Container(width: 28, height: 60 * _progresoSemana * _anim.value, decoration: BoxDecoration(
            gradient: LinearGradient(colors: isToday ? [const Color(0xff6c63ff), const Color(0xffb06aff)] : [const Color(0xff6c63ff).withOpacity(0.3), const Color(0xff6c63ff).withOpacity(0.5)]),
            borderRadius: BorderRadius.circular(8),
          )),
          const SizedBox(height: 6),
          Text(days[i], style: TextStyle(color: isToday ? const Color(0xff6c63ff) : subColor, fontSize: 11, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
        ]);
      })),
    ]),
  );

  Widget _buildCategorias(bool dark, Color textColor, Color subColor, Color bgCard) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(dark, bgCard),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Categorías', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ..._categoriasCompletadas.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(e.key, style: TextStyle(color: textColor, fontSize: 12)),
            Text('${e.value}', style: TextStyle(color: _colorCat(e.key), fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: e.value / _categoriasCompletadas.values.reduce(math.max).toDouble(), backgroundColor: _colorCat(e.key).withOpacity(0.1), valueColor: AlwaysStoppedAnimation(_colorCat(e.key)), minHeight: 6),
        ]),
      )),
    ]),
  );

  Widget _buildListaTareas(bool dark, Color textColor, Color subColor, Color bgCard) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(dark, bgCard),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tareas', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ..._tareas.map((t) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: t.completada ? _colorCat(t.categoria).withOpacity(0.07) : (dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          GestureDetector(onTap: () => _toggleCompletada(t), child: Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: t.completada ? _colorCat(t.categoria) : Colors.transparent, borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.completada ? _colorCat(t.categoria) : (dark ? Colors.white30 : Colors.black26), width: 2)),
            child: t.completada ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          )),
          const SizedBox(width: 12),
          Expanded(child: Text(t.titulo, style: TextStyle(color: t.completada ? subColor : textColor, decoration: t.completada ? TextDecoration.lineThrough : null, fontSize: 13))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _colorCat(t.categoria).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(t.categoria, style: TextStyle(color: _colorCat(t.categoria), fontSize: 10))),
          const SizedBox(width: 6),
          Icon(t.prioridad == 3 ? Icons.arrow_upward : t.prioridad == 2 ? Icons.remove : Icons.arrow_downward, size: 14, 
            color: t.prioridad == 3 ? const Color(0xffff6b6b) : t.prioridad == 2 ? const Color(0xffffb347) : const Color(0xff00d4aa)),
        ]),
      )),
    ]),
  );

  BoxDecoration _cardDecoration(bool dark, Color bgCard) => BoxDecoration(
    color: bgCard.withOpacity(0.85), borderRadius: BorderRadius.circular(16),
    border: Border.all(color: dark ? Colors.white10 : Colors.black.withOpacity(0.05)),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool dark;
  final Color bgCard;
  
  const _StatCard(this.label, this.value, this.icon, this.color, this.dark, this.bgCard);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: bgCard.withOpacity(0.85), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 10)),
      ]),
    ),
  );
}