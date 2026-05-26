import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';

class CalendarioEvent {
  final String id;
  String titulo, hora, duracion, tipo;
  DateTime fecha;
  CalendarioEvent({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.hora,
    required this.duracion,
    required this.tipo
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'fecha': fecha.toIso8601String(),
    'hora': hora,
    'duracion': duracion,
    'tipo': tipo,
  };

  factory CalendarioEvent.fromJson(Map<String, dynamic> json) => CalendarioEvent(
    id: json['id'],
    titulo: json['titulo'],
    fecha: DateTime.parse(json['fecha']),
    hora: json['hora'],
    duracion: json['duracion'],
    tipo: json['tipo'],
  );
}

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});
  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> with TickerProviderStateMixin {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  List<CalendarioEvent> _events = [];
  bool _showForm = false;
  CalendarioEvent? _editingEvent;
  bool _isLoading = true;

  final _tituloCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  String _duracion = '1 hora', _tipo = 'personal';
  DateTime _formDate = DateTime.now();

  late AnimationController _formAnimCtrl;
  late Animation<Offset> _formSlide;
  
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _formAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _formSlide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _formAnimCtrl, curve: Curves.easeOutCubic));
    _loadEvents();
  }

  // ✅ CORREGIDO - Usa load() en lugar de loadData(), sin async/await
  void _loadEvents() {
    setState(() => _isLoading = true);
    
    final userId = UserProvider.instance.currentUser?.id;
    if (userId != null) {
      final eventsData = _storage.load('${userId}_eventos');
      if (eventsData != null && eventsData is List) {
        _events.clear();
        for (var e in eventsData) {
          _events.add(CalendarioEvent.fromJson(e));
        }
      }
    }
    
    setState(() => _isLoading = false);
  }

  // ✅ CORREGIDO - Usa save() en lugar de saveData(), sin async/await
  void _saveEvents() {
    final userId = UserProvider.instance.currentUser?.id;
    if (userId == null) return;
    
    final eventsJson = _events.map((e) => e.toJson()).toList();
    _storage.save('${userId}_eventos', eventsJson);
    print('💾 Eventos guardados: ${_events.length}');
  }

  @override
  void dispose() {
    _formAnimCtrl.dispose();
    _tituloCtrl.dispose();
    _horaCtrl.dispose();
    super.dispose();
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];
    for (int i = 1; i < first.weekday; i++) days.add(DateTime(0));
    for (int d = 1; d <= last.day; d++) days.add(DateTime(month.year, month.month, d));
    return days;
  }

  bool _hasEvent(DateTime d) => _events.any((e) => e.fecha.year == d.year && e.fecha.month == d.month && e.fecha.day == d.day);

  void _openForm({CalendarioEvent? event, DateTime? date}) {
    setState(() {
      _editingEvent = event;
      _formDate = date ?? _selectedDay ?? DateTime.now();
      _tituloCtrl.text = event?.titulo ?? '';
      _horaCtrl.text = event?.hora ?? '';
      _duracion = event?.duracion ?? '1 hora';
      _tipo = event?.tipo ?? 'personal';
      _showForm = true;
    });
    _formAnimCtrl.forward();
  }

  void _closeForm() => _formAnimCtrl.reverse().then((_) => setState(() => _showForm = false));

  void _saveEvent() {
    if (_tituloCtrl.text.isEmpty) return;
    setState(() {
      if (_editingEvent != null) {
        _editingEvent!.titulo = _tituloCtrl.text;
        _editingEvent!.fecha = _formDate;
        _editingEvent!.hora = _horaCtrl.text;
        _editingEvent!.duracion = _duracion;
        _editingEvent!.tipo = _tipo;
      } else {
        _events.add(CalendarioEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titulo: _tituloCtrl.text,
          fecha: _formDate,
          hora: _horaCtrl.text,
          duracion: _duracion,
          tipo: _tipo,
        ));
      }
    });
    _saveEvents();
    _closeForm();
  }

  void _deleteEvent(CalendarioEvent e) {
    setState(() => _events.remove(e));
    _saveEvents();
    _closeForm();
  }

  String _monthName(int m) => ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][m];

  Color _tipoColor(String t) {
    const c = {'académico': Color(0xff6c63ff), 'personal': Color(0xff00d4aa), 'trabajo': Color(0xffff6b6b), 'salud': Color(0xffffb347)};
    return c[t] ?? const Color(0xff6c63ff);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = dark ? const Color(0xff1a2535) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xff1a1a2e);
    final subText = dark ? Colors.white54 : Colors.black45;
    final days = _daysInMonth(_focusedMonth);
    final selectedEvents = _selectedDay == null ? <CalendarioEvent>[]
        : _events.where((e) => e.fecha.year == _selectedDay!.year && e.fecha.month == _selectedDay!.month && e.fecha.day == _selectedDay!.day).toList();

    return Scaffold(
      backgroundColor: dark ? const Color(0xff0d1b2a) : const Color(0xfff0f4ff),
      body: Stack(children: [
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: dark ? [const Color(0xff0d1b2a), const Color(0xff1a0533)] : [const Color(0xffe8f0ff), const Color(0xfff8f0ff)]))),
        SafeArea(child: Row(children: [
          Expanded(child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: Row(children: [
              IconButton(onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: dark ? Colors.white70 : Colors.black54)),
              const Spacer(),
              Text('📅  Mi Calendario', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
              const Spacer(),
              IconButton(onPressed: () => _openForm(), icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              )),
            ])),
            Text('Organiza tus eventos importantes', style: TextStyle(color: subText, fontSize: 13)),
            const SizedBox(height: 16),
            Divider(color: dark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(icon: Icon(Icons.chevron_left, color: textColor),
                  onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1))),
              Text('${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              IconButton(icon: Icon(Icons.chevron_right, color: textColor),
                  onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1))),
            ]),
            const SizedBox(height: 12),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
              decoration: BoxDecoration(color: cardBg.withOpacity(0.7), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: dark ? Colors.white10 : Colors.black.withOpacity(0.06))),
              child: Column(children: [
                const SizedBox(height: 14),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'].map((d) => SizedBox(width: 36,
                    child: Text(d, textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xff6c63ff), fontWeight: FontWeight.bold, fontSize: 12)))).toList(),
                )),
                const SizedBox(height: 8),
                Expanded(child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
                  itemCount: days.length,
                  itemBuilder: (ctx, i) {
                    final d = days[i];
                    if (d.year == 0) return const SizedBox();
                    final isSelected = _selectedDay != null && _selectedDay!.year == d.year && _selectedDay!.month == d.month && _selectedDay!.day == d.day;
                    final isToday = DateTime.now().year == d.year && DateTime.now().month == d.month && DateTime.now().day == d.day;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xff6c63ff) : isToday ? const Color(0xff6c63ff).withOpacity(0.18) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isToday && !isSelected ? Border.all(color: const Color(0xff6c63ff).withOpacity(0.5), width: 1.5) : null,
                        ),
                        child: Stack(alignment: Alignment.center, children: [
                          Text('${d.day}', style: TextStyle(
                            color: isSelected ? Colors.white : dark ? Colors.white70 : Colors.black87,
                            fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13,
                          )),
                          if (_hasEvent(d)) Positioned(bottom: 4, child: Container(width: 5, height: 5,
                              decoration: const BoxDecoration(color: Color(0xffff6b6b), shape: BoxShape.circle))),
                        ]),
                      ),
                    );
                  },
                )),
              ]),
            ))),
            if (_selectedDay != null) ...[
              const SizedBox(height: 12),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
                Text('${_selectedDay!.day} ${_monthName(_selectedDay!.month)}',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                TextButton.icon(onPressed: () => _openForm(date: _selectedDay),
                    icon: const Icon(Icons.add, size: 16), label: const Text('Evento'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xff6c63ff))),
              ])),
              SizedBox(height: 80, child: selectedEvents.isEmpty
                  ? Center(child: Text('Sin eventos', style: TextStyle(color: subText, fontSize: 13)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedEvents.length,
                      itemBuilder: (ctx, i) {
                        final ev = selectedEvents[i];
                        return GestureDetector(onTap: () => _openForm(event: ev), child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: _tipoColor(ev.tipo).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14), border: Border.all(color: _tipoColor(ev.tipo).withOpacity(0.4))),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(ev.titulo, style: TextStyle(color: _tipoColor(ev.tipo), fontWeight: FontWeight.bold, fontSize: 13)),
                            if (ev.hora.isNotEmpty) Text(ev.hora, style: TextStyle(color: subText, fontSize: 11)),
                          ]),
                        ));
                      },
                    )),
            ],
            const SizedBox(height: 16),
          ])),
          if (_showForm) SlideTransition(position: _formSlide, child: _buildFormPanel(dark, textColor, subText, cardBg)),
        ])),
      ]),
    );
  }

  Widget _buildFormPanel(bool dark, Color textColor, Color subText, Color cardBg) {
    return Container(
      width: 340, margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg.withOpacity(0.97), borderRadius: BorderRadius.circular(24),
          border: Border.all(color: dark ? Colors.white10 : Colors.black.withOpacity(0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(-8, 0))]),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: Colors.white, size: 16)),
          const SizedBox(width: 10),
          Text(_editingEvent != null ? 'Editar Evento' : 'Nuevo Evento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const Spacer(),
          IconButton(icon: Icon(Icons.close, color: subText, size: 20), onPressed: _closeForm),
        ]),
        const SizedBox(height: 20),
        _field('Título del evento', _tituloCtrl, dark, textColor),
        const SizedBox(height: 14),
        _datePicker(dark, textColor, subText),
        const SizedBox(height: 14),
        _field('Hora (HH:MM)', _horaCtrl, dark, textColor),
        const SizedBox(height: 14),
        _dropdown('Duración', _duracion, ['30 min', '1 hora', '2 horas', '3 horas', 'Todo el día'],
            (v) => setState(() => _duracion = v!), dark, textColor),
        const SizedBox(height: 14),
        _dropdown('Tipo de evento', _tipo, ['personal', 'académico', 'trabajo', 'salud'],
            (v) => setState(() => _tipo = v!), dark, textColor),
        const Spacer(),
        if (_editingEvent != null) TextButton.icon(
          onPressed: () => _deleteEvent(_editingEvent!),
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          label: const Text('Eliminar evento', style: TextStyle(color: Colors.red, fontSize: 13)),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: _closeForm,
            style: OutlinedButton.styleFrom(side: BorderSide(color: dark ? Colors.white24 : Colors.black26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12)),
            child: Text('Cancelar', style: TextStyle(color: subText)),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _saveEvent,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff6c63ff),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0),
            child: const Text('Guardar Evento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )),
        ]),
      ])),
    );
  }

  Widget _field(String label, TextEditingController ctrl, bool dark, Color textColor) => TextField(
    controller: ctrl, style: TextStyle(color: textColor, fontSize: 14),
    decoration: InputDecoration(
      labelText: label, labelStyle: TextStyle(color: dark ? Colors.white38 : Colors.black38, fontSize: 13),
      filled: true, fillColor: dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff6c63ff), width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );

  Widget _datePicker(bool dark, Color textColor, Color subText) => GestureDetector(
    onTap: () async {
      final p = await showDatePicker(context: context, initialDate: _formDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xff6c63ff))), child: child!));
      if (p != null) setState(() => _formDate = p);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Text('Fecha', style: TextStyle(color: dark ? Colors.white38 : Colors.black38, fontSize: 13)), const Spacer(),
        Text('${_formDate.day.toString().padLeft(2,'0')}/${_formDate.month.toString().padLeft(2,'0')}/${_formDate.year}',
            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xff6c63ff)),
      ]),
    ),
  );

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged, bool dark, Color textColor) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(color: dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: value, isExpanded: true, dropdownColor: dark ? const Color(0xff1e2d40) : Colors.white,
          style: TextStyle(color: textColor, fontSize: 14),
          hint: Text(label, style: TextStyle(color: dark ? Colors.white38 : Colors.black38, fontSize: 13)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        )),
      );
}