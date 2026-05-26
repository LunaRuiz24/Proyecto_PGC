// ignore_for_file: unused_import
import 'package:flutter/material.dart';

class _Sugerencia {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color color;
  final List<String> tags;

  const _Sugerencia({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.tags,
  });
}

const _allSugerencias = [
  _Sugerencia(titulo: 'Aprender recetas exóticas', descripcion: 'Sorprende con tus habilidades culinarias',
      icono: Icons.restaurant_menu_rounded, color: Color(0xffff6b35), tags: ['cocina', 'gastronomía']),
  _Sugerencia(titulo: 'Visitar librerías', descripcion: 'Encuentra tu próxima lectura favorita',
      icono: Icons.menu_book_rounded, color: Color(0xff5b7fff), tags: ['lectura', 'cultura']),
  _Sugerencia(titulo: 'Meditación guiada', descripcion: 'Comienza tu día con claridad mental',
      icono: Icons.self_improvement_rounded, color: Color(0xffb06aff), tags: ['bienestar', 'salud']),
  _Sugerencia(titulo: 'Clase de fotografía', descripcion: 'Captura momentos únicos con tu cámara',
      icono: Icons.camera_alt_rounded, color: Color(0xff9b59b6), tags: ['fotografía', 'creatividad']),
  _Sugerencia(titulo: 'Paseo en bicicleta', descripcion: 'Recorre nuevos caminos sobre dos ruedas',
      icono: Icons.directions_bike_rounded, color: Color(0xff00b894), tags: ['deporte', 'aire libre']),
  _Sugerencia(titulo: 'Noche de juegos de mesa', descripcion: 'Diversión clásica con amigos y familia',
      icono: Icons.casino_rounded, color: Color(0xffe67e22), tags: ['social', 'entretenimiento']),
  _Sugerencia(titulo: 'Taller de jardinería', descripcion: 'Crea tu propio oasis verde en casa',
      icono: Icons.eco_rounded, color: Color(0xff27ae60), tags: ['naturaleza', 'hogar']),
  _Sugerencia(titulo: 'Sesión de yoga al aire libre', descripcion: 'Conecta cuerpo y mente con la naturaleza',
      icono: Icons.accessibility_new_rounded, color: Color(0xff16a085), tags: ['bienestar', 'deporte']),
  _Sugerencia(titulo: 'Maratón de películas clásicas', descripcion: 'Revive el cine de todas las épocas',
      icono: Icons.movie_rounded, color: Color(0xffe74c3c), tags: ['cine', 'entretenimiento']),
  _Sugerencia(titulo: 'Aprender un idioma nuevo', descripcion: 'Abre puertas con un segundo idioma',
      icono: Icons.translate_rounded, color: Color(0xff2980b9), tags: ['educación', 'cultura']),
  _Sugerencia(titulo: 'Senderismo en la montaña', descripcion: 'Explora rutas naturales cerca de ti',
      icono: Icons.terrain_rounded, color: Color(0xff795548), tags: ['deporte', 'naturaleza']),
  _Sugerencia(titulo: 'Escribir un diario', descripcion: 'Refleja tus pensamientos cada día',
      icono: Icons.edit_note_rounded, color: Color(0xfff39c12), tags: ['bienestar', 'creatividad']),
];

class SugerenciasScreen extends StatefulWidget {
  const SugerenciasScreen({super.key});

  @override
  State<SugerenciasScreen> createState() => _SugerenciasScreenState();
}

class _SugerenciasScreenState extends State<SugerenciasScreen> with TickerProviderStateMixin {
  String _searchQuery = '';
  String? _selectedTag;
  late AnimationController _staggerCtrl;

  final Set<String> _allTags = {};

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    for (final s in _allSugerencias) {
      _allTags.addAll(s.tags);
    }
    _staggerCtrl.forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  List<_Sugerencia> get _filtered {
    return _allSugerencias.where((s) {
      final matchQuery = _searchQuery.isEmpty ||
          s.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.descripcion.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchTag = _selectedTag == null || s.tags.contains(_selectedTag);
      return matchQuery && matchTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? Colors.white : const Color(0xff1a1a2e);
    final subText = dark ? Colors.white54 : Colors.black45;
    final cardBg = dark ? const Color(0xff1a2535) : const Color(0xff1e2740);

    return Scaffold(
      backgroundColor: dark ? const Color(0xff0d1b2a) : const Color(0xff0f1729),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [const Color(0xff0d1b2a), const Color(0xff1a0533), const Color(0xff0d1b2a)]
                : [const Color(0xff0f1729), const Color(0xff1a0f33), const Color(0xff0f1729)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('# Recomendaciones para ti',
                        style: TextStyle(
                            color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Descubre nuevas actividades y pasatiempos',
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 16),
                    // Search
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Buscar sugerencias...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tags filter
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _TagChip(label: 'Todos', selected: _selectedTag == null,
                              onTap: () => setState(() => _selectedTag = null)),
                          ..._allTags.map((t) => _TagChip(
                              label: t,
                              selected: _selectedTag == t,
                              onTap: () => setState(() => _selectedTag = _selectedTag == t ? null : t))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.08)),
              const SizedBox(height: 8),

              // Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final delay = (i * 0.06).clamp(0.0, 0.9);
                    return AnimatedBuilder(
                      animation: _staggerCtrl,
                      builder: (_, child) {
                        final start = delay;
                        final end = (delay + 0.4).clamp(0.0, 1.0);
                        final t = (((_staggerCtrl.value - start) / (end - start)).clamp(0.0, 1.0));
                        return Opacity(
                          opacity: t,
                          child: Transform.translate(offset: Offset(0, 20 * (1 - t)), child: child),
                        );
                      },
                      child: _SugerenciaCard(sugerencia: _filtered[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TagChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff6c63ff) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xff6c63ff) : Colors.white.withOpacity(0.15)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

class _SugerenciaCard extends StatefulWidget {
  final _Sugerencia sugerencia;
  const _SugerenciaCard({required this.sugerencia});

  @override
  State<_SugerenciaCard> createState() => _SugerenciaCardState();
}

class _SugerenciaCardState extends State<_SugerenciaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.sugerencia;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hovered
              ? s.color.withOpacity(0.12)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? s.color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(s.icono, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.titulo,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(s.descripcion,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: s.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: s.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(t, style: TextStyle(color: s.color, fontSize: 9, fontWeight: FontWeight.bold)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
