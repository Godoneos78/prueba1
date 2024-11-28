import 'package:flutter/material.dart';
import 'dart:convert';
class PrediagnosticoDetalleScreen extends StatelessWidget {
  final String nombre;
  final int edad;
  final String diagnostico;
  final String? imagenBase64;
  final String fecha;  // Nueva propiedad para la fecha

  PrediagnosticoDetalleScreen({
    required this.nombre,
    required this.edad,
    required this.diagnostico,
    this.imagenBase64,
    required this.fecha,  // Asegúrate de pasar la fecha en el constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Prediagnóstico'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar la imagen si está disponible
            if (imagenBase64 != null)
              Image.memory(
                base64Decode(imagenBase64!),
                fit: BoxFit.cover,
              ),
            SizedBox(height: 20),

            // Mostrar el nombre del paciente
            Text(
              "Nombre: $nombre",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Mostrar la edad del paciente
            Text(
              "Edad: $edad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Mostrar la fecha del prediagnóstico
            Text(
              "Fecha del Prediagnóstico: $fecha",  // Mostrar la fecha
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // Mostrar el título del diagnóstico
            Text(
              "Diagnóstico:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Mostrar el contenido del diagnóstico
            Text(
              diagnostico.isNotEmpty ? diagnostico : "Diagnóstico no disponible",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            
            
          ],
        ),
      ),
    );
  }
}
