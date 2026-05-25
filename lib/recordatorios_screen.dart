// ignore_for_file: unused_import
import 'dart:async';
import 'package:flutter/material.dart';

class Recordatorio {
  final String id;
  String titulo;
  String descripcion;
  DateTime fecha;
  String hora;
  bool completado;
  String categoria;

  Recordatorio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    this.completado = false,
    required this.categoria,
  });
}

// Simple in-app notification overlay
class NotifManager {
  static OverlayEntry? _current;

  static void show(BuildContext context, String titulo, String desc) {
    _current?.remove();
    final overlay = Overlay.of(context);
    _current = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: _NotifBanner(titulo: titulo, desc: desc, onDismiss: () => _current?.remove()),
      ),
    );
    overlay.insert(_current!);
    Future.delayed(const Duration(seconds: 4), () => _current?.remove());
  }
}

class _NotifBanner extends StatefulWidget {
  final String titulo;
  final String desc;
  final VoidCallback onDismiss;
  const _NotifBanner({required this.titulo, required this.desc, required this.onDismiss});

  @override
  State<_NotifBanner> createState() => _NotifBannerState();
}

class _NotifBannerState extends State<_NotifBanner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(widget.desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              GestureDetector(onTap: widget.onDismiss, child: const Icon(Icons.close, color: Colors.white70, size: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({super.key});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> with TickerProviderStateMixin {
  final List<Recordatorio> _recordatorios = [];
  bool _showForm = false;
  late AnimationController _formCtrl;
  late Animation<Offset> _formSlide;
  Timer? _checkTimer;

  // Form state
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  DateTime _formDate = DateTime.now();
  String _categoria = 'personal';

  @override
  void initState() {
    super.initState();
    _formCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _formSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));

    // Check reminders every minute
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkNotifications());
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _horaCtrl.dispose();
    _checkTimer?.cancel();
    super.dispose();
  }

  void _checkNotifications() {
    final now = DateTime.now();
    for (final r in _recordatorios) {
      if (r.completado) continue;
      final parts = r.hora.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]) ?? -1;
      final m = int.tryParse(parts[1]) ?? -1;
      final target = DateTime(r.fecha.year, r.fecha.month, r.fecha.day, h, m);
      final diff = target.difference(now).inMinutes;
      if (diff >= 0 && diff <= 1 && mounted) {
        NotifManager.show(context, '⏰ ${r.titulo}', r.descripcion.isNotEmpty ? r.descripcion : 'Tienes un recordatorio ahora');
      }
    }
  }

  void _triggerTestNotif(Recordatorio r) {
    if (mounted) NotifManager.show(context, '🔔 ${r.titulo}', r.descripcion.isNotEmpty ? r.descripcion : 'Recordatorio activado');
  }

  void _openForm() {
    setState(() {
      _tituloCtrl.text = '';
      _descCtrl.text = '';
      _horaCtrl.text = '';
      _formDate = DateTime.now();
      _categoria = 'personal';
      _showForm = true;
    });
    _formCtrl.forward();
  }

  void _closeForm() {
    _formCtrl.reverse().then((_) => setState(() => _showForm = false));
  }

  void _save() {
    if (_tituloCtrl.text.isEmpty) return;
    setState(() {
      _recordatorios.add(Recordatorio(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloCtrl.text,
        descripcion: _descCtrl.text,
        fecha: _formDate,
        hora: _horaCtrl.text,
        categoria: _categoria,
      ));
    });
    _closeForm();
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'académico': return const Color(0xff6c63ff);
      case 'personal': return const Color(0xff00d4aa);
      case 'trabajo': return const Color(0xffff6b6b);
      case 'salud': return const Color(0xffffb347);
      default: return const Color(0xff6c63ff);
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'académico': return Icons.school_rounded;
      case 'personal': return Icons.person_rounded;
      case 'trabajo': return Icons.work_rounded;
      case 'salud': return Icons.favorite_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? Colors.white : const Color(0xff1a1a2e);
    final subText = dark ? Colors.white54 : Colors.black45;
    final cardBg = dark ? const Color(0xff1a2535) : Colors.white;

    final pending = _recordatorios.where((r) => !r.completado).toList();
    final done = _recordatorios.where((r) => r.completado).toList();

    return Scaffold(
      backgroundColor: dark ? const Color(0xff0d1b2a) : const Color(0xfff0f4ff),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? [const Color(0xff0d1b2a), const Color(0xff1a0533)]
                : [const Color(0xffe8f0ff), const Color(0xfff8f0ff)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: dark ? Colors.white70 : Colors.black54),
                        ),
                        const Spacer(),
                        Text('# Tus Recordatorios',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Divider(color: dark ? Colors.white12 : Colors.black12),
                  const SizedBox(height: 12),

                  // Add button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _openForm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: const Color(0xff6c63ff).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_alarm_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('+ Agregar Nuevo Recordatorio',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: dark ? Colors.white12 : Colors.black12),

                  // Content
                  Expanded(
                    child: _recordatorios.isEmpty
                        ? _buildEmptyState(dark)
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              if (pending.isNotEmpty) ...[
                                Text('Pendientes (${pending.length})',
                                    style: TextStyle(color: subText, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                ...pending.map((r) => _buildCard(r, dark, textColor, subText, cardBg)),
                                const SizedBox(height: 20),
                              ],
                              if (done.isNotEmpty) ...[
                                Text('Completados (${done.length})',
                                    style: TextStyle(color: subText, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                ...done.map((r) => _buildCard(r, dark, textColor, subText, cardBg)),
                              ],
                            ],
                          ),
                  ),

                  // Back button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('← Volver al menú principal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff6c63ff),
                        side: const BorderSide(color: Color(0xff6c63ff)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              // Form overlay
              if (_showForm)
                GestureDetector(
                  onTap: _closeForm,
                  child: Container(color: Colors.black54),
                ),
              if (_showForm)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: _formSlide,
                    child: _buildFormSheet(dark, textColor, subText, cardBg),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('images/Calendario1.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded, color: Colors.white54, size: 48),
          SizedBox(height: 12),
          Text('No tienes recordatorios aún',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text('Agrega tu primer recordatorio',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCard(Recordatorio r, bool dark, Color textColor, Color subText, Color cardBg) {
    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => setState(() => _recordatorios.remove(r)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: r.completado ? Colors.transparent : _catColor(r.categoria).withOpacity(0.3),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: ListTile(
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _catColor(r.categoria).withOpacity(r.completado ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_catIcon(r.categoria),
                color: r.completado ? Colors.grey : _catColor(r.categoria), size: 22),
          ),
          title: Text(
            r.titulo,
            style: TextStyle(
              color: r.completado ? Colors.grey : textColor,
              fontWeight: FontWeight.bold,
              decoration: r.completado ? TextDecoration.lineThrough : null,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (r.descripcion.isNotEmpty)
                Text(r.descripcion, style: TextStyle(color: subText, fontSize: 12)),
              Text(
                '${r.fecha.day}/${r.fecha.month}/${r.fecha.year}${r.hora.isNotEmpty ? ' • ${r.hora}' : ''}',
                style: TextStyle(color: _catColor(r.categoria).withOpacity(0.8), fontSize: 11),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Test notification button
              if (!r.completado)
                IconButton(
                  icon: const Icon(Icons.notifications_active_outlined, size: 20),
                  color: const Color(0xff6c63ff),
                  tooltip: 'Probar notificación',
                  onPressed: () => _triggerTestNotif(r),
                ),
              Checkbox(
                value: r.completado,
                activeColor: const Color(0xff6c63ff),
                onChanged: (v) => setState(() => r.completado = v ?? false),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSheet(bool dark, Color textColor, Color subText, Color cardBg) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30)],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text('Nuevo Recordatorio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          _sheetField('Título *', _tituloCtrl, dark, textColor),
          const SizedBox(height: 10),
          _sheetField('Descripción', _descCtrl, dark, textColor),
          const SizedBox(height: 10),
          _sheetField('Hora (HH:MM)', _horaCtrl, dark, textColor),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final p = await showDatePicker(
                context: context,
                initialDate: _formDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (p != null) setState(() => _formDate = p);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: dark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: const Color(0xff6c63ff)),
                  const SizedBox(width: 10),
                  Text(
                    '${_formDate.day}/${_formDate.month}/${_formDate.year}',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: dark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _categoria,
                isExpanded: true,
                dropdownColor: dark ? const Color(0xff1e2d40) : Colors.white,
                style: TextStyle(color: textColor, fontSize: 14),
                items: ['personal', 'académico', 'trabajo', 'salud']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6c63ff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: const Text('Guardar Recordatorio',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl, bool dark, Color textColor) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: dark ? Colors.white38 : Colors.black38, fontSize: 13),
        filled: true,
        fillColor: dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff6c63ff), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
