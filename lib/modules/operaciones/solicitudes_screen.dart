import 'package:flutter/material.dart';
import 'mapa_servicio_screen.dart'; 

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  final double miRating = 4.8;
  final int misResenas = 24;

  DateTime? horaNotificacionEntrante; 

  List<Map<String, dynamic>> solicitudes = [
    {
      'id': 'SRV-2026-001234',
      'nombre': 'María González',
      'tiempo': 'Hace 5 min',
      'categoria': 'Plomería',
      'color': Colors.blue,
      'descripcion': 'Reparación de fuga en tubería de cocina. Urgente.',
      'direccion': 'Calle Reforma 234, Col. Centro',
      'distancia': '2.3 km',
      'estimado': '1-2 horas',
      'precio': '\$450 MXN',
      'detalles_cliente': 'Cliente Premium • 12 servicios solicitados',
    },
    {
      'id': 'SRV-2026-001235',
      'nombre': 'Carlos Ramírez',
      'tiempo': 'Hace 12 min',
      'categoria': 'Jardinería',
      'color': Colors.green,
      'descripcion': 'Mantenimiento de jardín y poda de árboles de más de 3 metros.',
      'direccion': 'Av. Universidad 890, Col. Del Valle',
      'distancia': '4.1 km',
      'estimado': '3-4 horas',
      'precio': '\$800 MXN',
      'detalles_cliente': 'Usuario Verificado • 3 servicios solicitados',
    },
  ];

  void _simularNuevaSolicitud() {
    Map<String, dynamic> servicioEntrante = {
      'id': 'SRV-2026-001299',
      'nombre': 'Alejandro Méndez',
      'tiempo': 'Ahora mismo',
      'categoria': 'Electricidad',
      'color': Colors.amber.shade700,
      'descripcion': 'Cortocircuito en el panel principal. No hay luz.',
      'direccion': 'Av. Benito Juárez #405, Col. Industrial',
      'distancia': '1.5 km',
      'estimado': '45 min',
      'precio': '\$650 MXN',
      'detalles_cliente': 'Solicitud de Emergencia • Alta Prioridad',
    };

    horaNotificacionEntrante = DateTime.now();
    _mostrarNotificacionElegante(context, servicioEntrante);
  }

  void _mostrarNotificacionElegante(BuildContext context, Map<String, dynamic> trabajo) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (BuildContext dialogContext) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 16, right: 16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Icon(Icons.stars, color: Colors.green.shade700, size: 14),
                                const SizedBox(width: 6),
                                Text('Prioridad por Calificación: $miRating ★', style: TextStyle(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(dialogContext),
                            child: const Icon(Icons.close, size: 20, color: Colors.grey),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: trabajo['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                            child: Icon(Icons.flash_on, color: trabajo['color'], size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('¡Solicitud de ${trabajo['categoria']}!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('${trabajo['nombre']} • a ${trabajo['distancia']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                          Text(trabajo['precio'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE26112))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                setState(() {
                                  solicitudes.insert(0, trabajo);
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('IGNORAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE26112),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext); 
                                _procesarAceptacionDirecta(context, trabajo, desdeDetalles: false);
                              },
                              child: const Text('ACEPTAR E IR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _procesarAceptacionDirecta(BuildContext context, Map<String, dynamic> trabajo, {required bool desdeDetalles}) {
    int segundosTranscurridos = 0;
    if (horaNotificacionEntrante != null) {
      segundosTranscurridos = DateTime.now().difference(horaNotificacionEntrante!).inSeconds;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(color: Color(0xFFE26112), strokeWidth: 3),
                ),
                const SizedBox(height: 24),
                const Text('Validando Algoritmo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Verificando disponibilidad en tiempo real...', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (desdeDetalles) Navigator.pop(context); 
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); 

      if (!desdeDetalles && segundosTranscurridos > 5) {
        _mostrarErrorDeAsignacion(context, 'Lo sentimos, este servicio ya fue tomado por otro colaborador con prioridad geográfica activa.');
      } else if (miRating >= 4.5 && misResenas >= 15) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AceptadoScreen(trabajo: trabajo, miRating: miRating),
          ),
        ).then((_) {
          setState(() {
            solicitudes.removeWhere((item) => item['id'] == trabajo['id']);
          });
        });
      } else {
        _mostrarErrorDeAsignacion(context, 'Tu nivel de prioridad actual no fue suficiente para competir por esta orden de emergencia.');
      }
    });
  }

  void _mostrarErrorDeAsignacion(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('No Disponible', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Text(mensaje, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ENTENDIDO', style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('JobHub', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add_outlined, color: Color(0xFFE26112)),
            tooltip: 'Simular Alerta de Trabajo',
            onPressed: _simularNuevaSolicitud,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nuevas Solicitudes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text('Calificación: $miRating ★ (Prioridad Activa)', style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            if (solicitudes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Column(
                    children: [
                      Icon(Icons.business_center_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Buscando oportunidades...', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              
            ...solicitudes.map((trabajo) => _buildSolicitudCard(context, trabajo)),
          ],
        ),
      ),
    );
  }

  Widget _buildSolicitudCard(BuildContext context, Map<String, dynamic> trabajo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: trabajo['color'].withOpacity(0.1), 
                child: Icon(Icons.person, color: trabajo['color'], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trabajo['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(trabajo['tiempo'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: trabajo['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(trabajo['categoria'], style: TextStyle(color: trabajo['color'], fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(trabajo['descripcion'], style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 16),
          
          // Fila de información resumida (Chips)
          Row(
            children: [
              _buildInfoChip(Icons.location_on_outlined, trabajo['distancia']),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.schedule, trabajo['estimado']),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ganancia', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(trabajo['precio'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE26112))),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleTrabajoScreen(
                            trabajo: trabajo,
                            ratingProveedor: miRating,
                            resenasProveedor: misResenas,
                            onAceptar: () {
                              _procesarAceptacionDirecta(context, trabajo, desdeDetalles: true);
                            },
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ver más', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _procesarAceptacionDirecta(context, trabajo, desdeDetalles: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE26112),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Aceptar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ====================================================================
// PANTALLA: DETALLES DEL TRABAJO (Diseño con Botón Fijo Inferior)
// ====================================================================
class DetalleTrabajoScreen extends StatelessWidget {
  final Map<String, dynamic> trabajo;
  final double ratingProveedor;
  final int resenasProveedor;
  final VoidCallback onAceptar;

  const DetalleTrabajoScreen({
    super.key,
    required this.trabajo,
    required this.ratingProveedor,
    required this.resenasProveedor,
    required this.onAceptar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Folio: ${trabajo['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
      ),
      // Uso de un Stack para fijar la botonera en la parte inferior
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 100), // Espacio extra abajo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: trabajo['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(trabajo['categoria'].toUpperCase(), style: TextStyle(color: trabajo['color'], fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 16),
                Text(trabajo['descripcion'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
                const SizedBox(height: 24),
                
                // Panel de Ventaja Competitiva
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.stars, color: Colors.green.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ventaja por tu Reputación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 15)),
                            const SizedBox(height: 6),
                            Text(
                              'Tu excelente puntaje de $ratingProveedor ★ con $resenasProveedor opiniones te da asignación inmediata en este servicio.',
                              style: TextStyle(color: Colors.green.shade800, fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Detalles del servicio
                const Text('Detalles del Servicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                _buildDetailRow(Icons.location_on_outlined, 'Ubicación', trabajo['direccion']),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.schedule, 'Tiempo estimado', trabajo['estimado']),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.route_outlined, 'Distancia', trabajo['distancia']),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.black12),
                ),
                
                // Perfil del Cliente
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: Colors.grey.shade100, child: const Icon(Icons.person, color: Colors.grey)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trabajo['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(trabajo['detalles_cliente'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Botonera Fija Inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ganancia neta', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        Text(trabajo['precio'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE26112))),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE26112),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onAceptar,
                      child: const Text('POSTULARME AHORA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// PANTALLA: ¡CONTRATADO / ASIGNADO!
// ====================================================================
class AceptadoScreen extends StatelessWidget {
  final Map<String, dynamic> trabajo;
  final double miRating;

  const AceptadoScreen({
    super.key,
    required this.trabajo,
    required this.miRating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                  child: Icon(Icons.check, color: Colors.green.shade600, size: 60),
                ),
              ),
              const SizedBox(height: 32),
              const Text('¡TRABAJO ASIGNADO!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Text(
                'Tu alta calificación de $miRating ★ te otorgó prioridad absoluta sobre la orden de ${trabajo['nombre']}.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 40),
              
              // Tarjeta Resumen
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.work_outline, color: trabajo['color'], size: 20),
                            const SizedBox(width: 8),
                            Text(trabajo['categoria'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Text(trabajo['precio'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trabajo['direccion'],
                            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE26112),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapaServicioScreen(trabajo: trabajo),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                  label: const Text('INICIAR RUTA AL EMPLEO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}