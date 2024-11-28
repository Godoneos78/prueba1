import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:prueba1/screens/result_screen.dart';

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Uint8List? _imageBytes;
  final picker = ImagePicker();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _edadController = TextEditingController();
  TextEditingController _carnetController = TextEditingController(); // Campo para el carnet

  // Función para seleccionar una imagen
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    } else {
      print("No se seleccionó ninguna imagen");
    }
  }

  // Función para enviar la imagen al backend y recibir el diagnóstico
  Future<void> _sendImage() async {
    if (_imageBytes == null ||
        _nombreController.text.isEmpty ||
        _edadController.text.isEmpty ||
        _carnetController.text.isEmpty) {
      _showDialog('Error', 'Por favor completa todos los campos.');
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5000/prediagnostico'); // URL del backend
    final request = http.MultipartRequest('POST', url)
      ..fields['nombre'] = _nombreController.text
      ..fields['carnet'] = _carnetController.text // Campo del carnet
      ..fields['edad'] = _edadController.text
      ..files.add(http.MultipartFile.fromBytes('imagen', _imageBytes!, filename: 'upload.png'));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        final String diagnostico = decodedData['diagnostico'];
        final String? imagenBase64 = decodedData['imagen'];
        final String fecha = decodedData['fecha']; // Obtener la fecha del backend

        // Navega a ResultScreen pasando el diagnóstico, la imagen, nombre, edad y la fecha
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              nombre: _nombreController.text, // Pasar el nombre ingresado
              edad: _edadController.text,     // Pasar la edad ingresada
              diagnostico: diagnostico,
              imagenBase64: imagenBase64,
              fecha: fecha,                   // Pasar la fecha obtenida del backend
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        // Manejo de error de duplicado de carnet u otro error 400
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);
        final String errorMessage = decodedData['error'] ?? 'Error desconocido.';
        _showDialog('Error', errorMessage);
      } else {
        _showDialog('Error', 'Paciente Registrado, busque en lista de pacientes');
      }
    } catch (e) {
      print("Error: $e");
      _showDialog('Error', 'Ocurrió un error al enviar la solicitud.');
    }
  }

  // Función para mostrar un cuadro de diálogo
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enviar Imagen para Diagnóstico')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _carnetController, // Campo para el carnet
              decoration: InputDecoration(labelText: "Número de Carnet"),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _edadController,
              decoration: InputDecoration(labelText: "Edad"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _imageBytes == null
                ? Text("No se ha seleccionado una imagen")
                : Image.memory(_imageBytes!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Seleccionar Imagen'),
            ),
            ElevatedButton(
              onPressed: _sendImage,
              child: Text('Enviar para Diagnóstico'),
            ),
          ],
        ),
      ),
    );
  }
}
