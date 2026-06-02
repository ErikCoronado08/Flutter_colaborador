import 'package:flutter/material.dart';

class MapaServicioScreen extends StatefulWidget {
  final Map<String, dynamic> trabajo;
  const MapaServicioScreen({super.key, required this.trabajo});

  @override
  State<MapaServicioScreen> createState() => _MapaServicioScreenState();
}

class _MapaServicioScreenState extends State<MapaServicioScreen> {
  // Estados del flujo estilo Uber: 
  // 0 = En camino a la casa | 1 = Llegué/Trabajando | 2 = Terminado
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. SIMULACIÓN DEL MAPA EN VIVO (Fondo estilo GPS)
          Container(
            color: Colors.grey.shade100,
            width: double.infinity,
            height: double.infinity,
            child: GridPaper(
              color: Colors.blue.withOpacity(0.05),
              divisions: 2,
              subdivisions: 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ruta trazada simulada
                  Positioned(
                    top: 220,
                    child: Icon(Icons.navigation, size: 48, color: Colors.blue.shade700),
                  ),
                  Positioned(
                    top: 150, left: 140,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Ruta óptima: 8 min', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  const Positioned(
                    top: 100,
                    child: Icon(Icons.location_on, size: 50, color: Colors.red),
                  )
                ],
              ),
            ),
          ),

          // 2. BARRA DE INDICACIONES FLOTANTE (ESTILO UBER)
          Positioned(
            top: 45, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A), // Corrección del color de fondo oscuro limpia
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
                        const Text('A 400 metros de la orden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(widget.trabajo['direccion'], style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Text(widget.trabajo['distancia'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // 3. HOJA INFERIOR DESLIZABLE CON LOS DATOS DEL CLIENTE Y ACCIONES
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
                  // Indicador de control superior con margen corregido a only(bottom: 12)
                  Container(
                    width: 40, 
                    height: 4, 
                    margin: const EdgeInsets.only(bottom: 12), 
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                  
                  // Información del usuario a atender
                  Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: Colors.orange.shade100, child: const Icon(Icons.person, color: Color(0xFFFF6F00))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.trabajo['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Servicio activo de ${widget.trabajo['categoria']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),
                      ),
                      // Botones rápidos estilo Uber de contacto
                      IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.black12, child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black87)),
                        onPressed: () => _mostrarChatSimulado(context),
                      ),
                      IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.black12, child: Icon(Icons.phone, size: 20, color: Colors.black87)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  // Tarifa transparente fijada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ganancia estimada al finalizar:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text(widget.trabajo['precio'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BOTÓN DE ACCIÓN CENTRALIZADO (MANEJA LAS ETAPAS DEL VIAJE)
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
                            // Si ya terminó el flujo, nos salimos de la navegación y regresamos al pool
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

  // Ventana de Chat Flotante instantánea
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
            Text('Chat con ${widget.trabajo['nombre']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                child: const Text('Hola, ¿ya vienes en camino? El timbre no funciona bien.'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje seguro...',
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