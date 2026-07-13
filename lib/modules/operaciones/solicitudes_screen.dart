import 'package:flutter/material.dart';
import '../../../services/api_service.dart'; // Ajusta esta ruta según la estructura de tus carpetas
import 'aceptado_screen.dart'; // Ajusta la ruta a tu pantalla verde

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  List<dynamic> _solicitudes = [];
  bool _cargando = true;

  @override
  void initState() { //  Corregido: Sin caracteres extraños
    super.initState();
    _cargarSolicitudesDesdeAPI();
  }

  // ================================================
  // 📥 LLAMADA A LA API DE LARAVEL PARA REFRESCAR DATOS
  // ================================================
  Future<void> _cargarSolicitudesDesdeAPI() async {
    setState(() => _cargando = true);
    
    // Consume tu: Route::get('/operaciones/solicitudes')
    final datos = await ApiService.obtenerSolicitudes();
    
    setState(() {
      _solicitudes = datos;
      _cargando = false;
    });
  }

  // ================================================
  // 🚀 ACCIÓN REAL AL PRESIONAR EL BOTÓN "ACEPTAR"
  // ================================================
  void _procesarAceptacionDirecta(BuildContext context, Map<String, dynamic> trabajo) async {
    final String idMongo = (trabajo['_id'] ?? trabajo['id'] ?? '').toString();

    if (idMongo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: El documento no tiene un ID válido de MongoDB')),
      );
      return;
    }

    // 1. Mostrar círculo de carga (Loading)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Consumir la API de Laravel (ejecuta el $servicio->save() en Mongo)
    bool guardadoExitoso = await ApiService.aceptarServicio(idMongo);

    // Ocultar círculo de carga
    Navigator.pop(context);

    if (guardadoExitoso) {
      // 3. Avanzar a la pantalla verde de éxito si Laravel guardó en MongoDB
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AceptadoScreen(trabajo: trabajo, miRating: 5.0),
        ),
      ).then((_) {
        // Al regresar de la pantalla del chat, vuelve a consultar la API 
        // para quitar de la lista el servicio que ya aceptaste
        _cargarSolicitudesDesdeAPI();
      });
    } else {
      // Alerta visual si hubo fallas de comunicación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar el estado en MongoDB local'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Disponibles'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarSolicitudesDesdeAPI,
          )
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _solicitudes.isEmpty
              ? const Center(child: Text('No hay servicios disponibles por el momento'))
              : RefreshIndicator(
                  onRefresh: _cargarSolicitudesDesdeAPI,
                  child: ListView.builder(
                    itemCount: _solicitudes.length,
                    itemBuilder: (context, index) {
                      final trabajo = _solicitudes[index] as Map<String, dynamic>;
                      
                      // Extraer campos dinámicos de MongoDB
                      final cliente = trabajo['cliente'] ?? 'Cliente Desconocido';
                      final categoria = trabajo['categoria'] ?? 'Servicio General';
                      final descripcion = trabajo['descripcion'] ?? 'Sin descripción disponible';
                      final precio = trabajo['precio'] ?? '0.00';

                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cliente,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Categoría: $categoria',
                                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(descripcion),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$$precio MXN',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => _procesarAceptacionDirecta(context, trabajo),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}