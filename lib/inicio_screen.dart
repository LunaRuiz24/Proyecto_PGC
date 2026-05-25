// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'calendario_screen.dart';
import 'recordatorios_screen.dart';
import 'seguimiento_screen.dart';
import 'sugerencias_screen.dart';
import 'perfil_screen.dart';
import 'user_provider.dart';
import 'theme_provider.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    ThemeProvider.instance.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _navigate(String route) {
    final screens = {
      'Calendario Académico': const CalendarioScreen(),
      'Recordatorios': const RecordatoriosScreen(),
      'Sugerencias': const SugerenciasScreen(),
      'Seguimiento': const SeguimientoScreen()
    };
    final screen = screens[route];
    if (screen != null) Navigator.push(context, _fadeRoute(screen));
  }

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    transitionDuration: const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final user = UserProvider.instance.currentUser;
    return Scaffold(
      backgroundColor: dark ? const Color(0xff0d1b2a) : const Color(0xfff8f9fc),
      appBar: _buildAppBar(dark, user),
      body: SingleChildScrollView(child: Column(children: [
        _buildHero(dark), _buildCarousel(), const SizedBox(height: 30),
        _buildAbout(dark), const SizedBox(height: 30),
        _buildCards(dark), const SizedBox(height: 40),
      ])),
    );
  }

  PreferredSizeWidget _buildAppBar(bool dark, dynamic user) => AppBar(
    backgroundColor: const Color(0xff0b2b40),
    elevation: 0,
    title: Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 16),
      ),
      const SizedBox(width: 8),
      const Text('UAEC', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    ]),
    actions: [
      const TextButton(onPressed: null, child: Text('Inicio', style: TextStyle(color: Colors.white70, fontSize: 13))),
      PopupMenuButton<String>(
        onSelected: _navigate,
        color: const Color(0xff1a2535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (_) => [
          _menuItem('Calendario Académico', Icons.calendar_month_rounded),
          _menuItem('Recordatorios', Icons.notifications_rounded),
          _menuItem('Sugerencias', Icons.favorite_rounded),
          _menuItem('Seguimiento', Icons.bar_chart_rounded),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Row(children: [
            Text('Funcionalidades', style: TextStyle(color: Colors.white, fontSize: 13)),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
          ]),
        ),
      ),
      IconButton(
        onPressed: () => ThemeProvider.instance.toggle(),
        icon: Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.white70, size: 20),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: user == null ? _loginBtn() : _profileBtn(user),
      ),
    ],
  );

  PopupMenuItem<String> _menuItem(String label, IconData icon) => PopupMenuItem(
    value: label,
    child: Row(children: [
      Icon(icon, color: const Color(0xff6c63ff), size: 18), const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    ]),
  );

  Widget _loginBtn() => GestureDetector(
    onTap: () async { await Navigator.push(context, _fadeRoute(const AuthScreen())); setState(() {}); },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xffff8c00), Color(0xffff6b00)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10)],
      ),
      child: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    ),
  );

  Widget _profileBtn(dynamic user) => GestureDetector(
    onTap: () async { await Navigator.push(context, _fadeRoute(const PerfilScreen())); setState(() {}); },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xff6c63ff).withOpacity(0.4), blurRadius: 10)],
      ),
      child: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
          child: Center(child: Text(
            user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          )),
        ),
        const SizedBox(width: 6),
        Text('Perfil de ${user.nombre.split(' ').first}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    ),
  );

  Widget _buildHero(bool dark) => Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: dark
            ? [const Color(0xff1a2535), const Color(0xff2d1b69).withOpacity(0.8)]
            : [const Color(0xffe2eaf5), const Color(0xffd5e3ff)],
      ),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
    ),
    child: Column(children: [
      Text('FACILITA TU AGENDAMIENTO\nUN AMIGO EN COMÚN',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold,
              color: dark ? Colors.white : const Color(0xff1c4e6f), height: 1.2)),
      const SizedBox(height: 20),
      Text('Un prototipo para organizar y gestionar tu tiempo de forma eficiente.\nPlanifica y coordina de manera sencilla.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: dark ? Colors.white70 : Colors.black54)),
      const SizedBox(height: 28),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _HeroBtn(label: '📅 Ver Calendario', onTap: () => _navigate('Calendario Académico'), primary: true),
        const SizedBox(width: 12),
        _HeroBtn(label: '💡 Sugerencias', onTap: () => _navigate('Sugerencias'), primary: false),
      ]),
    ]),
  );

  Widget _buildCarousel() => SizedBox(
    height: 320,
    child: Stack(alignment: Alignment.bottomCenter, children: [
      PageView(
        controller: _pageCtrl,
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: const [
          _ImgItem(path: 'images/Calendario1.jpg'),
          _ImgItem(path: 'images/calendario2.jpg'),
          _ImgItem(path: 'images/calendario5.jpg'),
        ],
      ),
      Positioned(bottom: 12, child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == i ? 20 : 8, height: 8,
          decoration: BoxDecoration(
            color: _currentPage == i ? const Color(0xff6c63ff) : Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      )),
    ]),
  );

  Widget _buildAbout(bool dark) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: dark ? const Color(0xff1a2535) : Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(dark ? 0.2 : 0.06), blurRadius: 20)],
    ),
    child: LayoutBuilder(builder: (ctx, c) {
      final wide = c.maxWidth > 600;
      final textCol = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.favorite_rounded, color: Color(0xff6c63ff), size: 22),
          const SizedBox(width: 8),
          Text('Nuestra filosofía', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: dark ? Colors.white : const Color(0xff1c4e6f))),
        ]),
        const SizedBox(height: 8),
        Text('LA ORGANIZACIÓN ES REAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
            color: dark ? Colors.white : const Color(0xff1a1a2e))),
        const SizedBox(height: 12),
        Text('Amigo en Común está diseñada para ayudar a las personas a gestionar su tiempo de manera eficiente. Ofrecemos un calendario inteligente, herramientas de colaboración y seguimiento.',
            style: TextStyle(fontSize: 15, height: 1.6, color: dark ? Colors.white70 : Colors.black87)),
        const SizedBox(height: 16),
        Row(children: const [
          _BadgeChip(icon: Icons.bar_chart_rounded, label: 'Organización'),
          SizedBox(width: 12),
          _BadgeChip(icon: Icons.people_rounded, label: 'Colaboración'),
        ]),
      ]);
      final img = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('images/calendario2.jpg',
            height: 240, width: wide ? 280 : double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 240, color: Colors.grey[800],
                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white38)))),
      );
      return wide
          ? Row(children: [Expanded(child: textCol), const SizedBox(width: 24), img])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [textCol, const SizedBox(height: 20), img]);
    }),
  );

  Widget _buildCards(bool dark) {
    final cards = [
      {'t': 'CALENDARIO ACADÉMICO', 'd': 'Gestiona tus eventos y actividades.', 'i': Icons.calendar_month_rounded, 'r': 'Calendario Académico'},
      {'t': 'RECORDATORIOS', 'd': 'Notificaciones para no olvidar nada.', 'i': Icons.notifications_active_rounded, 'r': 'Recordatorios'},
      {'t': 'SUGERENCIAS', 'd': 'Descubre actividades recomendadas.', 'i': Icons.favorite_rounded, 'r': 'Sugerencias'},
      {'t': 'SEGUIMIENTO', 'd': 'Monitorea tu productividad semanal.', 'i': Icons.bar_chart_rounded, 'r': 'Seguimiento'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(spacing: 20, runSpacing: 20,
        children: cards.map((c) => _FeatureCard(
          titulo: c['t'] as String, descripcion: c['d'] as String,
          icono: c['i'] as IconData, dark: dark, onTap: () => _navigate(c['r'] as String),
        )).toList(),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _HeroBtn extends StatelessWidget {
  final String label; final VoidCallback onTap; final bool primary;
  const _HeroBtn({required this.label, required this.onTap, required this.primary});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: primary ? const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]) : null,
        color: primary ? null : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: primary ? null : Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: primary ? [BoxShadow(color: const Color(0xff6c63ff).withOpacity(0.4), blurRadius: 12)] : null,
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
    ),
  );
}

class _ImgItem extends StatelessWidget {
  final String path;
  const _ImgItem({required this.path});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(path, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey[800],
              child: const Center(child: Icon(Icons.image, size: 50, color: Colors.white38)))),
    ),
  );
}

class _BadgeChip extends StatelessWidget {
  final IconData icon; final String label;
  const _BadgeChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xff6c63ff).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      Icon(icon, size: 16, color: const Color(0xff6c63ff)), const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff6c63ff), fontSize: 13)),
    ]),
  );
}

class _FeatureCard extends StatefulWidget {
  final String titulo, descripcion; final IconData icono; final VoidCallback onTap; final bool dark;
  const _FeatureCard({required this.titulo, required this.descripcion, required this.icono, required this.onTap, required this.dark});
  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 260, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.dark
              ? (_hovered ? const Color(0xff6c63ff).withOpacity(0.15) : const Color(0xff1a2535))
              : (_hovered ? const Color(0xff6c63ff).withOpacity(0.06) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _hovered ? const Color(0xff6c63ff).withOpacity(0.5) : Colors.transparent, width: 1.5),
          boxShadow: [BoxShadow(
            color: _hovered ? const Color(0xff6c63ff).withOpacity(0.2) : Colors.black.withOpacity(widget.dark ? 0.2 : 0.06),
            blurRadius: _hovered ? 24 : 12, offset: const Offset(0, 4),
          )],
        ),
        child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: _hovered
                  ? const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)])
                  : LinearGradient(colors: [const Color(0xff6c63ff).withOpacity(0.15), const Color(0xff6c63ff).withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(widget.icono, size: 30, color: _hovered ? Colors.white : const Color(0xff6c63ff)),
          ),
          const SizedBox(height: 16),
          Text(widget.titulo, textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold,
                  color: widget.dark ? Colors.white : const Color(0xff1a1a2e), fontSize: 13)),
          const SizedBox(height: 8),
          Text(widget.descripcion, textAlign: TextAlign.center,
              style: TextStyle(color: widget.dark ? Colors.white54 : Colors.black45, fontSize: 13)),
          const SizedBox(height: 12),
          AnimatedOpacity(
            opacity: _hovered ? 1.0 : 0.0, duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xff6c63ff).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: const Text('Abrir →', style: TextStyle(color: Color(0xff6c63ff), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ]),
      ),
    ),
  );
}