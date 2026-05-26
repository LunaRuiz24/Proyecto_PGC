import 'package:flutter/material.dart';
import 'screens/inicio_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';

void main() {
  UserProvider.instance.loadAllUsers();
  runApp(const MiApp());
}

class MiApp extends StatefulWidget {
  const MiApp({super.key});

  @override
  State<MiApp> createState() => _MiAppState();
}

class _MiAppState extends State<MiApp> {
  @override
  void initState() {
    super.initState();
    ThemeProvider.instance.addListener(() => setState(() {}));
    UserProvider.instance.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amigo en Común',
      themeMode: ThemeProvider.instance.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xff6c63ff),
          secondary: Color(0xffb06aff),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff0d1b2a),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff6c63ff),
          secondary: Color(0xffb06aff),
          surface: Color(0xff1a2535),
        ),
      ),
      home: const InicioScreen(),
    );
  }
}