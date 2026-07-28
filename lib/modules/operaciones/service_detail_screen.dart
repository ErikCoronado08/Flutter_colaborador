import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import 'mapa_servicio_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> agendaData;

  const ServiceDetailScreen({super.key, required this.agendaData});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  late String _idServicio;

  @override
  void initState() {
    super.initState();
    _idServicio = widget.agendaData['id'].toString();
    _determinarPasoActual();
  }

  void _determinarPasoActual() {
    String estado = (widget.agendaData['estado'] ?? '').toLowerCase();
    
    // Sincronizado exactamente con el ENUM de Laravel
    if (estado == 'programada') _currentStep = 0;
    else if (estado == 'confirmada') _currentStep = 1;
    else if (estado == 'en_proceso') _currentStep = 2;
    else if (estado == 'completada' || estado == 'cancelada') _currentStep = 3;
  }

  Future<void> _avanzarEstadoNormal(String nuevoEstado, int nextStep) async {
    setState(() => _isLoading = true);
    
    // Petición al backend
    bool exito = await ApiService.cambiarEstadoOperativo(_idServicio, nuevoEstado);
    
    setState(() {
      _isLoading = false;
      if (exito) _currentStep = nextStep;
    });

    if (mounted) {
      if (exito) {
        // Si el nuevo estado es 'confirmada', abrimos el mapa
        if (nuevoEstado == 'confirmada') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MapaServicioScreen(trabajo: widget.agendaData)));
        }
      } else {
        // Si el backend rechaza el cambio, mostramos un error para que no sea silencioso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión con el servidor. Intenta de nuevo.'), backgroundColor: Colors.red)
        );
      }
    }
  }

  // PASO FINAL: Subir evidencia y cobrar
  Future<void> _capturarEvidenciaYCobrar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    
    if (photo != null) {
      setState(() => _isLoading = true);
      
      final res = await ApiService.subirEvidencia(_idServicio, File(photo.path));
      
      setState(() {
        _isLoading = false;
        if (res['success']) _currentStep = 3;
      });

      if (mounted) {
        if (res['success']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Trabajo completado y cobrado con éxito!'), backgroundColor: Colors.green));
          Navigator.pop(context); // Regresa a la agenda
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Error al subir la evidencia'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.agendaData['cliente'] ?? 'Cliente';
    final servicio = widget.agendaData['servicio'] ?? 'Servicio';
    final hora = widget.agendaData['hora'] ?? '00:00';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Línea de Tiempo', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: [
                    CircleAvatar(radius: 25, backgroundColor: const Color(0xFFE26112).withOpacity(0.1), child: const Icon(Icons.work, color: Color(0xFFE26112))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cliente, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('$servicio a las $hora', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Stepper(
                  currentStep: _currentStep > 2 ? 2 : _currentStep,
                  controlsBuilder: (context, details) => const SizedBox.shrink(),
                  steps: [
                    Step(
                      title: const Text('Cita Programada', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton.icon(
                          // Envia 'confirmada' en vez de 'en_camino'
                          onPressed: () => _avanzarEstadoNormal('confirmada', 1),
                          icon: const Icon(Icons.directions_car, color: Colors.white, size: 18),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          label: const Text('INICIAR RUTA', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('En Camino al Domicilio', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _avanzarEstadoNormal('en_proceso', 2),
                          icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          label: const Text('LLEGUÉ AL DOMICILIO', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Trabajo en Proceso', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: _capturarEvidenciaYCobrar,
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          label: const Text('TOMAR FOTO Y COBRAR', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}