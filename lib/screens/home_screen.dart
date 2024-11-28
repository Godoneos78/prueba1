import 'package:flutter/material.dart';
import 'image_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido a Clínica Dental'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImageScreen()),
            );
          },
          child: Text('Ir a Captura de Imagen'),
        ),
      ),
    );
  }
}
