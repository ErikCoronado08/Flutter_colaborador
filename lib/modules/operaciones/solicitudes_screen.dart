import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'mapa_servicio_screen.dart'; 

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  final double miRating = 5.0; 
  final int misResenas = 100;

  DateTime? horaNotificacionEntrante; 
  late IO.Socket socket;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Lista de solicitudes oficiales
  List<Map<String, dynamic>> solicitudes = [
    {
      'id': 'SRV-2026-001234',
      'nombre': 'María González',
      'tiempo': 'Hace 5 min',
      'categoria': 'Plomería',
      'color': Colors.blue,
      'descripcion': 'Reparación de fuga en tubería de cocina. Acceso Directo.',
      'direccion': 'Calle Reforma 234, Col. Centro',
      'distancia': '2.3 km',
      'estimado': '1-2 horas',
      'precio': '\$450 MXN',
      'detalles_cliente': 'Cliente Premium • Orden Verificada',
    },
    {
      'id': 'SRV-2026-001235',
      'nombre': 'Carlos Ramírez',
      'tiempo': 'Hace 12 min',
      'categoria': 'Jardinería',
      'color': Colors.green,
      'descripcion': 'Mantenimiento de jardín y poda de árboles. Acceso Directo.',
      'direccion': 'Av. Universidad 890, Col. Del Valle',
      'distancia': '4.1 km',
      'estimado': '3-4 horas',
      'precio': '\$800 MXN',
      'detalles_cliente': 'Usuario Verificado • Orden Verificada',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  @override
  void dispose() {
    socket.disconnect(); 
    socket.dispose();
    _audioPlayer.dispose(); 
    super.dispose();
  }

  // CONEXIÓN CON SOCKET.IO
  void _initSocket() {
    socket = IO.io('http://tu-servidor-backend.com', IO.OptionBuilder()
      .setTransports(['websocket']) 
      .enableAutoConnect()
      .build());

    socket.onConnect((_) {
      debugPrint('Conectado al servidor JobHub');
    });

    socket.on('nueva_solicitud', (data) {
      if (!mounted) return;
      
      Map<String, dynamic> nuevaOrden = Map<String, dynamic>.from(data);
      nuevaOrden['color'] = _obtenerColorCategoria(nuevaOrden['categoria']);

      _reproducirSonidoAlerta();

      horaNotificacionEntrante = DateTime.now();
      _mostrarNotificacionElegante(context, nuevaOrden);
    });
  }

  Color _obtenerColorCategoria(String? categoria) {
    switch (categoria?.toLowerCase()) {
      case 'plomería': return Colors.blue;
      case 'jardinería': return Colors.green;
      case 'electricidad': return Colors.amber.shade700;
      default: return Colors.purple;
    }
  }

  // REPRODUCCIÓN DE AUDIO
  Future<void> _reproducirSonidoAlerta() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/ping.mp3'));
    } catch (e) {
      debugPrint('Error audio: $e');
    }
  }

  // SIMULADOR LOCAL 
  void _simularNuevaSolicitud() {
    Map<String, dynamic> servicioEntrante = {
      'id': 'SRV-2026-001299',
      'nombre': 'Alejandro Méndez',
      'tiempo': 'Ahora mismo',
      'categoria': 'Electricidad',
      'color': Colors.amber.shade700,
      'descripcion': 'Cortocircuito en el panel principal. Orden Inmediata.',
      'direccion': 'Av. Benito Juárez #405, Col. Industrial',
      'distancia': '1.5 km',
      'estimado': '45 min',
      'precio': '\$650 MXN',
      'detalles_cliente': 'Solicitud Asignada • Alta Prioridad',
    };

    _reproducirSonidoAlerta();
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
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 14),
                                SizedBox(width: 6),
                                Text('Orden Disponible para Ti', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
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
                            child: Icon(Icons.bolt, color: trabajo['color'], size: 24),
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
                              child: const Text('ACEPTAR AHORA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(color: Color(0xFFE26112), strokeWidth: 3),
                ),
                SizedBox(height: 24),
                Text('Asignando Orden', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text('Conectando de forma inmediata...', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (!mounted) return;
      if (desdeDetalles) Navigator.pop(context); 
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pop(context); 

      socket.emit('aceptar_servicio', {'id': trabajo['id']});

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AceptadoScreen(trabajo: trabajo, miRating: miRating),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            solicitudes.removeWhere((item) => item['id'] == trabajo['id']);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('JobHub', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)), // Quitada la palabra Free
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_outlined, color: Color(0xFFE26112)),
            tooltip: 'Simular Orden',
            onPressed: _simularNuevaSolicitud,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              if (solicitudes.isEmpty) {
                solicitudes = [
                  {
                    'id': 'SRV-2026-001234',
                    'nombre': 'María González',
                    'tiempo': 'Hace 5 min',
                    'categoria': 'Plomería',
                    'color': Colors.blue,
                    'descripcion': 'Reparación de fuga en tubería de cocina. Acceso Directo.',
                    'direccion': 'Calle Reforma 234, Col. Centro',
                    'distancia': '2.3 km',
                    'estimado': '1-2 horas',
                    'precio': '\$450 MXN',
                    'detalles_cliente': 'Cliente Premium',
                  }
                ];
              }
            });
          },
          child: solicitudes.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Esperando nuevas solicitudes...', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Usa el botón de arriba ↗ para simular una', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  itemCount: solicitudes.length + 1, 
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Solicitudes de Trabajo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFFE26112)),
                                SizedBox(width: 8),
                                Text('Panel de Control Conectado', style: TextStyle(fontSize: 12, color: Color(0xFFE26112), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                    
                    final trabajo = solicitudes[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildSlidableCard(context, trabajo),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildSlidableCard(BuildContext context, Map<String, dynamic> trabajo) {
    return Slidable(
      key: ValueKey(trabajo['id']),
      
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) => _procesarAceptacionDirecta(context, trabajo, desdeDetalles: false),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white, 
            icon: Icons.check,
            label: 'Aceptar', // Retornado a tu original
          ),
        ],
      ),
      
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) {
              setState(() {
                solicitudes.removeWhere((item) => item['id'] == trabajo['id']);
              });
            },
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white, 
            icon: Icons.delete_outline,
            label: 'Ignorar', // Retornado a tu original
          ),
        ],
      ),
      
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    const Text('Ganancia Directa', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      child: const Text('Detalles', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
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
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
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

// PANTALLA DETALLES
class DetalleTrabajoScreen extends StatelessWidget {
  final Map<String, dynamic> trabajo;
  final VoidCallback onAceptar;

  const DetalleTrabajoScreen({
    super.key,
    required this.trabajo,
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
        title: Text('Orden: ${trabajo['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 100), 
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
                
                const Text('Detalles Generales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                _buildDetailRow(Icons.location_on_outlined, 'Ubicación', trabajo['direccion']),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.schedule, 'Tiempo estimado', trabajo['estimado']),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.route_outlined, 'Distancia', trabajo['distancia']),
                
                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12)),
                
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
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pago Estimado', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        Text(trabajo['precio'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE26112))),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE26112),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onAceptar,
                      child: const Text('ACEPTAR ORDEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

// PANTALLA ASIGNADO
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
                child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 80),
              ),
              const SizedBox(height: 32),
              const Text('¡SOLICITUD ADQUIRIDA!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Has tomado esta orden exitosamente. Ya puedes dirigirte al destino asignado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(trabajo['categoria'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(trabajo['precio'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(trabajo['direccion'], style: const TextStyle(fontSize: 14))),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MapaServicioScreen(trabajo: trabajo)),
                    );
                  },
                  icon: const Icon(Icons.directions_car, color: Colors.white),
                  label: const Text('VER RUTA EN MAPA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}