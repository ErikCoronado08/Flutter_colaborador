import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapaServicioScreen extends StatefulWidget {
  final Map<String, dynamic> trabajo;
  const MapaServicioScreen({super.key, required this.trabajo});

  @override
  State<MapaServicioScreen> createState() => _MapaServicioScreenState();
}

class _MapaServicioScreenState extends State<MapaServicioScreen> {
  final MapController _mapController = MapController();

  LatLng _posicionActual = const LatLng(20.967370, -89.592586);
  late LatLng _coordenadasDestino;

  bool _cargando = true;
  List<LatLng> _puntosRuta = [];
  String _tiempoEstimado = "Calculando...";

  final String _orsApiKey = "5b3ce3597851110001cf6248c8bfa9df9c7c4e51921f64f33da07d08";

  @override
  void initState() {
    super.initState();

    final ubicacion = widget.trabajo['ubicacion'];
    double destLat = 20.967370;
    double destLng = -89.592586;

    if (ubicacion is Map) {
      destLat = double.tryParse((ubicacion['lat'] ?? ubicacion['latitud'] ?? '').toString()) ?? destLat;
      destLng = double.tryParse((ubicacion['lng'] ?? ubicacion['longitud'] ?? '').toString()) ?? destLng;
    } else if (widget.trabajo['latitud'] != null && widget.trabajo['longitud'] != null) {
      destLat = double.tryParse(widget.trabajo['latitud'].toString()) ?? destLat;
      destLng = double.tryParse(widget.trabajo['longitud'].toString()) ?? destLng;
    }

    _coordenadasDestino = LatLng(destLat, destLng);
    _inicializarMapaYGPS();
  }

  Future<void> _inicializarMapaYGPS() async {
    setState(() => _cargando = true);

    try {
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.whileInUse || permiso == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 4),
        );
        _posicionActual = LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint("El GPS tardó o no está disponible, usando ubicación base.");
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
        final double segundos = (data['features'][0]['properties']['summary']['duration'] as num).toDouble();

        setState(() {
          _puntosRuta = coords.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
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
      _tiempoEstimado = "Ruta directa generada";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _posicionActual,
                    initialZoom: 14.0,
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
                  top: 50,
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
                  top: 50,
                  left: MediaQuery.of(context).size.width * 0.25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '🚗 Tiempo estimado: $_tiempoEstimado',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    label: const Text('VOLVER A LÍNEA DE TIEMPO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
    );
  }
}