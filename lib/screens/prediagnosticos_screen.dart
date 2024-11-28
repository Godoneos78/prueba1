import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prediagnostico_detalle_screen.dart'; // Asegúrate de importar la pantalla de detalle

class PrediagnosticosScreen extends StatefulWidget {
  @override
  _PrediagnosticosScreenState createState() => _PrediagnosticosScreenState();
}

class _PrediagnosticosScreenState extends State<PrediagnosticosScreen> {
  List<dynamic> prediagnosticos = [];
  List<dynamic> filteredPrediagnosticos = [];

  @override
  void initState() {
    super.initState();
    fetchPrediagnosticos();
  }

  // Función para obtener la lista de prediagnósticos desde el backend
  Future<void> fetchPrediagnosticos() async {
    final url = Uri.parse('http://10.0.2.2:5000/listar');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          prediagnosticos = json.decode(response.body);
          filteredPrediagnosticos = prediagnosticos; // Al principio, mostrar todos
        });
      } else {
        print("Error en la solicitud: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Función para filtrar los pacientes por nombre
  void filterPrediagnosticos(String query) {
    setState(() {
      filteredPrediagnosticos = prediagnosticos
          .where((prediagnostico) {
            final nombre = prediagnostico['nombre'].toLowerCase();
            return nombre.contains(query.toLowerCase());
          })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Pacientes'),
        actions: [
          // Añadir un campo de búsqueda en la AppBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: PatientSearchDelegate(
                    prediagnosticos: prediagnosticos,
                    onSearch: filterPrediagnosticos,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: filteredPrediagnosticos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredPrediagnosticos.length,
              itemBuilder: (context, index) {
                final prediagnostico = filteredPrediagnosticos[index];

                // Manejo de datos
                final String nombre = prediagnostico['nombre'] ?? 'Sin nombre';
                final int edad = prediagnostico['edad'] ?? 0;
                final String? imagenBase64 = prediagnostico['imagen'];
                final Uint8List? imageBytes = imagenBase64 != null
                    ? base64Decode(imagenBase64)
                    : null;
                final String fecha = prediagnostico['fecha'] ?? 'Fecha no disponible';  // Fecha

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: imageBytes != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(imageBytes),
                          )
                        : CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(nombre),
                    subtitle: Text('Edad: $edad años\nFecha: $fecha'),
                    onTap: () async {
                      // Realiza la solicitud para obtener los detalles del prediagnóstico
                      final detalleUrl = Uri.parse('http://10.0.2.2:5000/detalle/${prediagnostico['id']}');
                      try {
                        final response = await http.get(detalleUrl);
                        if (response.statusCode == 200) {
                          final detalle = json.decode(response.body);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrediagnosticoDetalleScreen(
                                nombre: detalle['nombre'] ?? 'Sin nombre',
                                edad: detalle['edad'] ?? 0,
                                diagnostico: detalle['diagnostico'] ?? 'Diagnóstico no disponible',
                                imagenBase64: detalle['imagen'] ?? '',
                                fecha: fecha,  // Pasa la fecha
                              ),
                            ),
                          );
                        } else {
                          print("Error en la solicitud de detalle: ${response.statusCode}");
                        }
                      } catch (e) {
                        print("Error al obtener el detalle: $e");
                      }
                    },
                  ),
                );
              },
            ),
      // Botón para regresar al inicio
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Regresar a la pantalla inicial
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        child: Icon(Icons.home),
        tooltip: 'Volver al inicio',
      ),
    );
  }
}

// Delegate de búsqueda
class PatientSearchDelegate extends SearchDelegate {
  final List<dynamic> prediagnosticos;
  final Function(String) onSearch;

  PatientSearchDelegate({required this.prediagnosticos, required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);  // Filtrar con una cadena vacía
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredResults = prediagnosticos
        .where((prediagnostico) {
          final nombre = prediagnostico['nombre'].toLowerCase();
          return nombre.contains(query.toLowerCase());
        })
        .toList();

    // Si no hay resultados, mostrar mensaje
    if (filteredResults.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final prediagnostico = filteredResults[index];

        return ListTile(
          title: Text(prediagnostico['nombre']),
          subtitle: Text('Edad: ${prediagnostico['edad']} años'),
          onTap: () {
            // Abre los detalles del prediagnóstico al seleccionar un paciente
            final detalleUrl = Uri.parse('http://10.0.2.2:5000/detalle/${prediagnostico['id']}');
            http.get(detalleUrl).then((response) {
              if (response.statusCode == 200) {
                final detalle = json.decode(response.body);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrediagnosticoDetalleScreen(
                      nombre: detalle['nombre'] ?? 'Sin nombre',
                      edad: detalle['edad'] ?? 0,
                      diagnostico: detalle['diagnostico'] ?? 'Diagnóstico no disponible',
                      imagenBase64: detalle['imagen'] ?? '',
                      fecha: prediagnostico['fecha'] ?? 'Fecha no disponible',  // Fecha
                    ),
                  ),
                );
              } else {
                print("Error en la solicitud de detalle: ${response.statusCode}");
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);  // Usamos los mismos resultados para las sugerencias
  }
}
