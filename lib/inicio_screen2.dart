import 'package:flutter/material.dart';
import 'i_seción-registro_screen.dart'; 

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fc),
      appBar: AppBar(
        backgroundColor: const Color(0xff0b2b40),
        title: const Text(
          "UAEC",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Inicio",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Nosotros",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegistroScreen(emailInicial: '',),
                  ),
                );
              },
              child: const Text("Suscríbete"),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xffe2eaf5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Column(
                children: [
                  Text(
                    "FACILITA TU AGENDAMIENTO\nUN AMIGO EN COMÚN",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1c4e6f),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Tu aplicación para organizar y gestionar tu tiempo de forma eficiente",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            // IMAGENES
            SizedBox(
              height: 300,
              child: PageView(
                children: [
                  imagen("assets/images/Calendario1.jpg"),
                  imagen("assets/images/calendario2.jpg"),
                  imagen("assets/images/calendario5.jpg"),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // NOSOTROS
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const Text(
                    "Nuestra misión",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1c4e6f),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "La organización del tiempo es la clave del éxito",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Amigo en común está diseñada para ayudar a las personas a gestionar su tiempo de manera eficiente.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/calendario3.jpg",
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            // CARDS
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                FeatureCard(
                  titulo: "GESTIÓN DE ACTIVIDADES",
                  descripcion: "Permite crear, editar y eliminar eventos.",
                  icono: Icons.calendar_month,
                ),
                FeatureCard(
                  titulo: "ORGANIZACIÓN DEL TIEMPO",
                  descripcion: "Ayuda a planificar actividades diarias.",
                  icono: Icons.access_time,
                ),
                FeatureCard(
                  titulo: "SUGERENCIAS",
                  descripcion: "Sistema de sugerencias inteligentes.",
                  icono: Icons.favorite,
                ),
                FeatureCard(
                  titulo: "CHATBOT",
                  descripcion: "Asistente inteligente integrado.",
                  icono: Icons.smart_toy,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget imagen(String ruta) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          ruta,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, size: 50),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;

  const FeatureCard({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            size: 50,
            color: const Color(0xff1c4e6f),
          ),
          const SizedBox(height: 15),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            descripcion,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}