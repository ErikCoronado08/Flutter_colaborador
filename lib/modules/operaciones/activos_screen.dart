import 'package:flutter/material.dart';

class ActivosScreen extends StatefulWidget {
  const ActivosScreen({super.key});

  @override
  State<ActivosScreen> createState() => _ActivosScreenState();
}

class _ActivosScreenState extends State<ActivosScreen> {
  // Lista de trabajos activos que mutará cuando el usuario interactúe
  List<Map<String, dynamic>> trabajosActivos = [
    {
      'id': 'ACT-001',
      'nombre_cliente': 'Pedro Sánchez',
      'categoria': 'Plomería',
      'avatar_color': Colors.blue.shade100,
      'avatar_icon': Icons.plumbing,
      'descripcion': 'Instalación de lavabo en baño principal.',
      'direccion': 'Av. Insurgentes 1234, Roma Norte',
      'progreso': 0.60, // 60%
      'precio': '\$450 MXN',
      'telefono': '+52 55 1234 5678'
    },
    {
      'id': 'ACT-002',
      'nombre_cliente': 'Laura Quintanilla',
      'categoria': 'Electricidad',
      'avatar_color': Colors.amber.shade100,
      'avatar_icon': Icons.flash_on,
      'descripcion': 'Cambio de switch principal y balanceo de cargas.',
      'direccion': 'Calle Tulipanes 45, Coyoacán',
      'progreso': 0.25, // 25%
      'precio': '\$650 MXN',
      'telefono': '+52 55 8765 4321'
    }
  ];

  // Simulación de llamada telefónica
  void _simularLlamada(String cliente, String numero) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.white),
            const SizedBox(width: 12),
            Text('Enlazando llamada con $cliente ($numero)...'),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Cuadro de diálogo interactivo para finalizar el servicio y calificar al cliente
  void _mostrarCierreServicio(BuildContext context, Map<String, dynamic> trabajo) {
    double estrellasCliente = 5.0; // Estado inicial de calificación simulada

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( // Nos permite cambiar el estado de las estrellas dentro del popup
          builder: (context, setPopupState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Column(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 48),
                  const SizedBox(height: 12),
                  const Text('¿Finalizar Servicio?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vas a cerrar el trabajo de ${trabajo['nombre_cliente']}. Califica tu experiencia con el cliente:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  
                  // Fila interactiva de Estrellas simuladas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < estrellasCliente ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setPopupState(() {
                            estrellasCliente = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  Text('$estrellasCliente ★', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  
                  // Badge de dinero a cobrar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Monto a cobrar: ${trabajo['precio']}',
                      style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext); // Cierra popup
                    
                    // Removemos el trabajo de la lista activa con una animación nativa de estado
                    setState(() {
                      trabajosActivos.removeWhere((t) => t['id'] == trabajo['id']);
                    });

                    // Notificación de éxito al usuario
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡Servicio con ${trabajo['nombre_cliente']} finalizado y reportado!'),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
                  },
                  child: const Text('CONFIRMAR Y COBRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text('Jobhub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trabajos Activos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(
                trabajosActivos.isEmpty ? 'Sin órdenes pendientes' : '${trabajosActivos.length} trabajos en curso', 
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 20),
              
              // MANEJO DE EMPTY STATE: Si no hay trabajos, muestra un diseño limpio
              Expanded(
                child: trabajosActivos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 72, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              '¡Estás al día!',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No tienes trabajos activos. Ve a la pestaña de solicitudes para aceptar nuevos ingresos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: trabajosActivos.length,
                        itemBuilder: (context, index) {
                          final trabajo = trabajosActivos[index];
                          final int porcentaje = (trabajo['progreso'] * 100).toInt();

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Encabezado de la Tarjeta (Cliente y Categoría)
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: trabajo['avatar_color'], 
                                        child: Icon(trabajo['avatar_icon'], color: Colors.black87, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(trabajo['nombre_cliente'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text(trabajo['categoria'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                                        child: const Text('En Progreso', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  
                                  // Detalles del trabajo
                                  Text(trabajo['descripcion'], style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          trabajo['direccion'], 
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 28),
                                  
                                  // Indicador de Progreso
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Progreso del servicio', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                      Text('$porcentaje%', style: const TextStyle(color: Color(0xFFFF6F00), fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: trabajo['progreso'], 
                                    color: const Color(0xFFFF6F00), 
                                    backgroundColor: Colors.grey.shade200,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 18),
                                  
                                  // Botonera de Acciones Integradas
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _simularLlamada(trabajo['nombre_cliente'], trabajo['telefono']),
                                          icon: const Icon(Icons.phone, size: 18),
                                          label: const Text('LLAMAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.grey.shade300),
                                            foregroundColor: Colors.black87,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _mostrarCierreServicio(context, trabajo),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFF6F00),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text('FINALIZAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}