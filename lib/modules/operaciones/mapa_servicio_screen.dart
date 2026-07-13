import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../services/api_service.dart'; // Ajusta la ruta a tu api_service.dart

class MapaServicioScreen extends StatefulWidget {
  final Map<String, dynamic> trabajo;
  const MapaServicioScreen({super.key, required this.trabajo});

  @override
  State<MapaServicioScreen> createState() => _MapaServicioScreenState();
}

class _MapaServicioScreenState extends State<MapaServicioScreen> {
  final MapController _mapController = MapController();
  
  // Coordenadas predeterminadas (Por si el GPS tarda) basadas en tu Mongo local
  LatLng _posicionActual = LatLng(20.96, -89.61); 
  late LatLng _coordenadasDestino;
  
  bool _cargando = true;
  List<LatLng> _puntosRuta = [];
  String _tiempoEstimado = "Calculando...";

  final String _orsApiKey = "5b3ce3597851110001cf6248c8bfa9df9c7c4e51921f64f33da07d08";

  @override
  void initState() {
    super.initState();
    
    // Extraer coordenadas de destino del JSON de MongoDB
    final ubicacion = widget.trabajo['ubicacion'];
    double destLat = 20.96;
    double destLng = -89.61;

    if (ubicacion != null) {
      destLat = double.tryParse(ubicacion['lat'].toString()) ?? 20.96;
      destLng = double.tryParse(ubicacion['lng'].toString()) ?? -89.61;
    }

    _coordenadasDestino = LatLng(destLat, destLng);
    _inicializarMapaYGPS();
  }

  Future<void> _inicializarMapaYGPS() async {
    setState(() => _cargando = true);
    
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 4)
      );
      _posicionActual = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("El GPS tardó, usando ubicación base predeterminada.");
    }

    await _obtenerRutaDesdeAPI();

    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _obtenerRutaDesdeAPI() async {
    final String url = 
        'https://api.openrouteservice.org/v2/directions/driving-car'
        '?api_key=$_orsApiKey'
        '&start=${_posicionActual.longitude},${_posicionActual.latitude}'
        '&end=${_coordenadasDestino.longitude},${_coordenadasDestino.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        final double segundos = data['features'][0]['properties']['summary']['duration'];

        setState(() {
          _puntosRuta = coords.map((c) => LatLng(c[1], c[0])).toList();
          _tiempoEstimado = "${(segundos / 60).round()} min";
        });
      } else {
        _generarLineaRectaRespaldo();
      }
    } catch (e) {
      _generarLineaRectaRespaldo();
    }
  }

  void _generarLineaRectaRespaldo() {
    setState(() {
      _puntosRuta = [_posicionActual, _coordenadasDestino];
      _tiempoEstimado = "12 min (Simulado)";
    });
  }

  // 🚀 FUNCIÓN ASÍNCRONA PARA FINALIZAR EL TRABAJO
  void _procesarFinalizacionTrabajo() async {
    final String idServicio = (widget.trabajo['_id'] ?? widget.trabajo['id'] ?? '').toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    bool exito = await ApiService.finalizarServicio(idServicio);
    Navigator.pop(context); // Quitar círculo de carga

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Servicio finalizado con éxito en MongoDB!'), backgroundColor: Colors.green),
      );
      // Regresa al menú principal cerrando la vista del mapa
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al comunicar la finalización del servicio'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cargando 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6F00)))
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _posicionActual,
                  zoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.jobhub.colaborador',
                  ),

                  if (_puntosRuta.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _puntosRuta,
                          strokeWidth: 5.5,
                          color: Colors.blue.shade700,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _posicionActual,
                        width: 45,
                        height: 45,
                        child: Icon(Icons.navigation, color: Colors.blue.shade800, size: 35),
                      ),
                      Marker(
                        point: _coordenadasDestino,
                        width: 45,
                        height: 45,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                top: 60,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              Positioned(
                top: 140,
                left: MediaQuery.of(context).size.width * 0.25,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    '🚗 Tiempo estimado: $_tiempoEstimado', // Corregido el nombre de la variable
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // BOTÓN INFERIOR CAMBIADO A ACCIÓN DE FINALIZAR TRABAJO REAL
              Positioned(
                bottom: 20, left: 20, right: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _procesarFinalizacionTrabajo,
                  child: const Text('FINALIZAR TRABAJO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
    );
  }
}