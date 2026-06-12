import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

// Clase personalizada para almacenar coordenadas de forma segura
class PosicionGeografica {
  final double latitude;
  final double longitude;
  const PosicionGeografica(this.latitude, this.longitude);
}

class MapaServicioScreen extends StatefulWidget {
  final Map<String, dynamic> trabajo;
  const MapaServicioScreen({super.key, required this.trabajo});

  @override
  State<MapaServicioScreen> createState() => _MapaServicioScreenState();
}

class _MapaServicioScreenState extends State<MapaServicioScreen> {
  final MapController _mapController = MapController();
  
  // Coordenadas iniciales por defecto (Centro de Lima)
  PosicionGeografica _posicionActual = const PosicionGeografica(-12.046374, -77.042793);
  bool _cargandoPosicion = true;

  StreamSubscription<Position>? _positionStreamSubscription;
  late PosicionGeografica _coordenadasDestino;
  int pasoServicio = 0; 

  String get botonTexto {
    if (pasoServicio == 0) return 'YA LLEGUÉ A LA UBICACIÓN';
    if (pasoServicio == 1) return 'FINALIZAR TRABAJO COMPLETO';
    return 'REGRESAR A SOLICITUDES';
  }

  Color get botonColor {
    if (pasoServicio == 0) return Colors.blue.shade800;
    if (pasoServicio == 1) return Colors.green.shade700;
    return const Color(0xFFFF6F00);
  }

  @override
  void initState() {
    super.initState();
    
    _coordenadasDestino = PosicionGeografica(
      widget.trabajo['lat'] ?? -12.046374, 
      widget.trabajo['lng'] ?? -77.042793
    );

    _configurarGPSYSeguimiento();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _configurarGPSYSeguimiento() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      if (mounted) setState(() => _cargandoPosicion = false);
      return;
    }

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        if (mounted) setState(() => _cargandoPosicion = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _posicionActual = PosicionGeografica(position.latitude, position.longitude);
          _cargandoPosicion = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargandoPosicion = false);
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10)
    ).listen((Position pos) {
      if (mounted) {
        setState(() {
          _posicionActual = PosicionGeografica(pos.latitude, pos.longitude);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _cargandoPosicion
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    // Inicializamos el mapa en el centro por defecto de la cámara
                    initialZoom: 15.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.jobhub.colaborador',
                    ),
                  ],
                ),

          // BARRA DE INDICACIONES FLOTANTE
          Positioned(
            top: 45, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A), 
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.turn_right, color: Colors.greenAccent, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('En ruta hacia la orden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(widget.trabajo['direccion'] ?? 'Dirección no disponible', style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Text(widget.trabajo['distancia'] ?? '2.3 km', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // HOJA INFERIOR DEL CLIENTE
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 2)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4, 
                    margin: const EdgeInsets.only(bottom: 12), 
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                  Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: Colors.orange.shade100, child: const Icon(Icons.person, color: Color(0xFFFF6F00))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.trabajo['nombre'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Servicio activo de ${widget.trabajo['categoria'] ?? "General"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.black12, child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black87)),
                        onPressed: () => _mostrarChatSimulado(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ganancia estimada:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text(widget.trabajo['precio'] ?? 'S/. 0.00', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: botonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          if (pasoServicio < 2) {
                            pasoServicio++;
                          } else {
                            Navigator.pop(context);
                          }
                        });
                      },
                      child: Text(botonTexto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _mostrarChatSimulado(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 16, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chat con ${widget.trabajo['nombre'] ?? "Cliente"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                child: const Text('Hola, ¿ya vienes en camino?'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                suffixIcon: IconButton(icon: const Icon(Icons.send, color: Color(0xFFFF6F00)), onPressed: () => Navigator.pop(context)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}