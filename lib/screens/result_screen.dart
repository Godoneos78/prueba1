import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';

class ResultScreen extends StatelessWidget {
  final String nombre;
  final String edad;
  final String diagnostico;
  final String? imagenBase64;
  final String fecha;

  ResultScreen({
    required this.nombre,
    required this.edad,
    required this.diagnostico,
    this.imagenBase64,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    final Uint8List? imageBytes = imagenBase64 != null ? base64Decode(imagenBase64!) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Prediagnóstico'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBytes != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 10),
            Text(
              "Nombre: $nombre",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "Edad: $edad",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "Fecha: $fecha",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Text(
              "Diagnóstico:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              diagnostico,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 30), // Espaciado antes del botón
            ElevatedButton(
              onPressed: () {
                // Volver al menú principal (pantalla inicial)
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
