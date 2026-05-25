// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'user_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _editing = false;
  late TextEditingController _nombreCtrl, _carreraCtrl, _hobbiesCtrl;

  @override
  void initState() {
    super.initState();
    final u = UserProvider.instance.currentUser!;
    _nombreCtrl = TextEditingController(text: u.nombre);
    _carreraCtrl = TextEditingController(text: u.carrera);
    _hobbiesCtrl = TextEditingController(text: u.hobbies);
  }

  @override
  void dispose() { _nombreCtrl.dispose(); _carreraCtrl.dispose(); _hobbiesCtrl.dispose(); super.dispose(); }

  void _saveProfile() {
    UserProvider.instance.updateProfile(nombre: _nombreCtrl.text, carrera: _carreraCtrl.text, hobbies: _hobbiesCtrl.text);
    setState(() => _editing = false);
  }

  void _logout() { UserProvider.instance.logout(); Navigator.pop(context); }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final u = UserProvider.instance.currentUser!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: dark ? [const Color(0xff0d1b2a), const Color(0xff1a0533)] : [const Color(0xff2d1b69), const Color(0xff4a0e8f)],
        )),
        child: SafeArea(child: Row(children: [
          // Landscape illustration
          Expanded(flex: 5, child: Stack(children: [
            Container(decoration: const BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xff2d1b69), Color(0xff0d0a1e)]))),
            CustomPaint(painter: _MountainPainter(), child: const SizedBox.expand()),
            Positioned(top: 80, left: 60, child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xffe8c97b).withOpacity(0.9),
                  boxShadow: [BoxShadow(color: const Color(0xffe8c97b).withOpacity(0.4), blurRadius: 40, spreadRadius: 10)]),
            )),
            Positioned(top: 60, right: 40, child: Row(children: [_Bird(), const SizedBox(width: 16), _Bird(), const SizedBox(width: 10), _Bird()])),
          ])),

          // Profile card
          Expanded(flex: 4, child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xff1a2535).withOpacity(0.95), borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30)]),
            child: Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Avatar
              Center(child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffff6b6b)]), shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xff6c63ff).withOpacity(0.4), blurRadius: 20, spreadRadius: 2)]),
                child: Center(child: Text(u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
              )),
              const SizedBox(height: 8),
              Center(child: Text(u.nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              Center(child: Text(u.carrera, style: const TextStyle(color: Colors.white54, fontSize: 12))),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 8),
              const Text('# Tu Perfil', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              _profileField('Nombre', _nombreCtrl),
              const SizedBox(height: 10),
              _profileField('Carrera', _carreraCtrl),
              const SizedBox(height: 10),
              _emailField(u.email),
              const SizedBox(height: 10),
              _profileField('Hobbies', _hobbiesCtrl),
              const Spacer(),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 12),
              if (!_editing)
                GestureDetector(
                  onTap: () => setState(() => _editing = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff6c63ff), Color(0xffb06aff)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: const Color(0xff6c63ff).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('✏️', style: TextStyle(fontSize: 16)), SizedBox(width: 8),
                      Text('Editar Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                )
              else
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => setState(() => _editing = false),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white54)))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff6c63ff), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                ]),
              const SizedBox(height: 10),
              Divider(color: Colors.white.withOpacity(0.1)),
              TextButton.icon(onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: Color(0xffff6b6b), size: 18),
                  label: const Text('Cerrar sesión', style: TextStyle(color: Color(0xffff6b6b), fontSize: 13))),
              const SizedBox(height: 4),
              OutlinedButton.icon(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('← Volver al menú principal', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xff6c63ff),
                      side: const BorderSide(color: Color(0xff6c63ff)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
            ])),
          )),
        ])),
      ),
    );
  }

  Widget _profileField(String label, TextEditingController ctrl) => Container(
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
        border: _editing ? Border.all(color: const Color(0xff6c63ff).withOpacity(0.5)) : null),
    child: _editing
        ? TextField(controller: ctrl, style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)))
        : Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)), const SizedBox(height: 2),
            Text(ctrl.text.isEmpty ? '—' : ctrl.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ])),
  );

  Widget _emailField(String email) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Correo', style: TextStyle(color: Colors.white38, fontSize: 11)), const SizedBox(height: 2),
      Text(email, style: const TextStyle(color: Colors.white60, fontSize: 14)),
    ]),
  );
}

class _Bird extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BirdPainter(), size: const Size(20, 10));
}

class _BirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.7)..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, 0, size.width, size.height * 0.5), paint);
  }
  @override bool shouldRepaint(_) => false;
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void drawMountain(List<Offset> pts, Color color) {
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      final path = Path()..moveTo(0, size.height);
      for (final p in pts) path.lineTo(p.dx * size.width, p.dy * size.height);
      path.lineTo(size.width, size.height); path.close();
      canvas.drawPath(path, paint);
    }
    drawMountain([const Offset(0,.55),const Offset(.15,.4),const Offset(.3,.55),const Offset(.45,.35),const Offset(.6,.5),const Offset(.75,.3),const Offset(.9,.45),const Offset(1,.4)], const Color(0xff3d2a7a));
    drawMountain([const Offset(0,.7),const Offset(.2,.55),const Offset(.35,.65),const Offset(.5,.45),const Offset(.65,.6),const Offset(.8,.5),const Offset(1,.55)], const Color(0xff2d1f5e));
    drawMountain([const Offset(0,.85),const Offset(.25,.7),const Offset(.5,.8),const Offset(.75,.65),const Offset(1,.75)], const Color(0xff1e1342));
    final tp = Paint()..color = const Color(0xff0f0a24)..style = PaintingStyle.fill;
    for (int i = 0; i < 12; i++) {
      final x = (i / 12) * size.width + 20; final h = 40.0 + (i % 3) * 20; final w = 18.0 + (i % 2) * 8;
      canvas.drawPath(Path()..moveTo(x, size.height-h)..lineTo(x-w/2, size.height)..lineTo(x+w/2, size.height)..close(), tp);
    }
    canvas.drawRect(Rect.fromLTWH(0, size.height*.82, size.width, size.height*.18),
        Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [const Color(0xff3d2a7a).withOpacity(0.3), Colors.transparent])
            .createShader(Rect.fromLTWH(0, size.height*.82, size.width, size.height*.18)));
  }
  @override bool shouldRepaint(_) => false;
}