// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'user_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Register controllers
  final _regNameCtrl = TextEditingController();
  final _regCarreraCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regHobbiesCtrl = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureReg = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regCarreraCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regHobbiesCtrl.dispose();
    super.dispose();
  }

  void _switchMode() {
    _animController.reverse().then((_) {
      setState(() {
        _isLogin = !_isLogin;
        _error = null;
      });
      _animController.forward();
    });
  }

  void _handleLogin() {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Por favor completa todos los campos');
      return;
    }
    final user = UserProvider.instance.login(email, pass);
    if (user == null) {
      setState(() => _error = 'Correo o contraseña incorrectos');
      return;
    }
    Navigator.pop(context);
  }

  void _handleRegister() {
    final name = _regNameCtrl.text.trim();
    final carrera = _regCarreraCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final pass = _regPassCtrl.text.trim();
    final hobbies = _regHobbiesCtrl.text.trim();

    if (name.isEmpty || carrera.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Por favor completa los campos requeridos');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Correo electrónico inválido');
      return;
    }
    final ok = UserProvider.instance.register(
      nombre: name, carrera: carrera, email: email, password: pass, hobbies: hobbies,
    );
    if (!ok) {
      setState(() => _error = 'Este correo ya está registrado');
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [const Color(0xff0d1b2a), const Color(0xff1a0533), const Color(0xff0d1b2a)]
                : [const Color(0xffe8f4fd), const Color(0xfff0e6ff), const Color(0xffe8f4fd)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xff1a2535).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.07),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: dark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.12),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(
                          child: Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff6c63ff), Color(0xffff6b6b)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 32),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isLogin ? 'Bienvenido de nuevo' : 'Crear cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : const Color(0xff1a1a2e),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin ? 'Ingresa a tu espacio personal' : 'Únete a Amigo en Común',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 14),
                        ),
                        const SizedBox(height: 28),

                        if (_isLogin) ..._buildLoginFields(dark)
                        else ..._buildRegisterFields(dark),

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                        _buildSubmitButton(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
                              style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: _switchMode,
                              child: Text(
                                _isLogin ? 'Regístrate' : 'Inicia sesión',
                                style: const TextStyle(
                                  color: Color(0xff6c63ff),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoginFields(bool dark) => [
    _buildField(ctrl: _loginEmailCtrl, label: 'Correo electrónico', icon: Icons.email_outlined, dark: dark),
    const SizedBox(height: 14),
    _buildField(
      ctrl: _loginPassCtrl, label: 'Contraseña', icon: Icons.lock_outline, dark: dark,
      obscure: _obscureLogin,
      toggleObscure: () => setState(() => _obscureLogin = !_obscureLogin),
    ),
  ];

  List<Widget> _buildRegisterFields(bool dark) => [
    _buildField(ctrl: _regNameCtrl, label: 'Nombre completo *', icon: Icons.person_outline, dark: dark),
    const SizedBox(height: 14),
    _buildField(ctrl: _regCarreraCtrl, label: 'Carrera *', icon: Icons.school_outlined, dark: dark),
    const SizedBox(height: 14),
    _buildField(ctrl: _regEmailCtrl, label: 'Correo electrónico *', icon: Icons.email_outlined, dark: dark),
    const SizedBox(height: 14),
    _buildField(
      ctrl: _regPassCtrl, label: 'Contraseña *', icon: Icons.lock_outline, dark: dark,
      obscure: _obscureReg,
      toggleObscure: () => setState(() => _obscureReg = !_obscureReg),
    ),
    const SizedBox(height: 14),
    _buildField(ctrl: _regHobbiesCtrl, label: 'Hobbies (opcional)', icon: Icons.favorite_outline, dark: dark),
  ];

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required bool dark,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(color: dark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xff6c63ff), size: 20),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: dark ? Colors.white38 : Colors.black38, size: 18),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: dark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff6c63ff), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLogin ? _handleLogin : _handleRegister,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff6c63ff), Color(0xffb06aff)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: const Color(0xff6c63ff).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: Text(
            _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
