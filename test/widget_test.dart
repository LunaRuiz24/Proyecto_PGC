import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amigo en Común',
      home: const InicioScreen(), 
    );
  }
}

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('UAEC'), 
      ),
    );
  }
}

void main() {
  testWidgets('Carga la app correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MiApp());
    expect(find.text('UAEC'), findsOneWidget);
  });
}