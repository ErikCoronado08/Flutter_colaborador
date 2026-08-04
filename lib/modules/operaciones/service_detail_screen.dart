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

  // Variables para el modal de reporte
  String _tipoReporte = 'incumplimiento_servicio';
  String _prioridadReporte = 'media';
  final TextEditingController _descReporteCtrl = TextEditingController();

  final List<Map<String, String>> _tiposDisputa = [
    {'value': 'conducta', 'label': 'Conducta inapropiada'},
    {'value': 'incumplimiento_servicio', 'label': 'Incumplimiento del servicio'},
    {'value': 'fraude', 'label': 'Posible fraude'},
    {'value': 'acoso', 'label': 'Acoso'},
    {'value': 'pago', 'label': 'Problema con un pago'},
    {'value': 'seguridad', 'label': 'Problema de seguridad'},
    {'value': 'otro', 'label': 'Otro'},
  ];

  final List<Map<String, String>> _prioridades = [
    {'value': 'baja', 'label': 'Prioridad Baja'},
    {'value': 'media', 'label': 'Prioridad Media'},
    {'value': 'alta', 'label': 'Prioridad Alta'},
    {'value': 'urgente', 'label': '¡Urgente!'},
  ];

  @override
  void initState() {
    super.initState();
    _idServicio = widget.agendaData['id'].toString();
    _determinarPasoActual();
  }

  @override
  void dispose() {
    _descReporteCtrl.dispose();
    super.dispose();
  }

  void _determinarPasoActual() {
    String estado = (widget.agendaData['estado'] ?? '').toLowerCase();
    if (estado == 'programada') _currentStep = 0;
    else if (estado == 'confirmada') _currentStep = 1;
    else if (estado == 'en_proceso') _currentStep = 2;
    else if (estado == 'completada' || estado == 'cancelada') _currentStep = 3;
  }

  Future<void> _avanzarEstadoNormal(String nuevoEstado, int nextStep) async {
    setState(() => _isLoading = true);
    
    bool exito = await ApiService.cambiarEstadoOperativo(_idServicio, nuevoEstado);
    
    setState(() {
      _isLoading = false;
      if (exito) _currentStep = nextStep;
    });

    if (mounted) {
      if (exito && nuevoEstado == 'confirmada') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MapaServicioScreen(trabajo: widget.agendaData)));
      } else if (!exito) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión con el servidor. Intenta de nuevo.'), backgroundColor: Colors.red));
      }
    }
  }

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
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Error al subir la evidencia'), backgroundColor: Colors.red));
        }
      }
    }
  }

  // 💡 LÓGICA Y MODAL DE REPORTE/DISPUTA
  void _mostrarModalReporte() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            bool enviando = false;

            Future<void> enviarReporte() async {
              if (_descReporteCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor describe la situación'), backgroundColor: Colors.red));
                return;
              }

              setStateModal(() => enviando = true);

              final payload = {
                'servicio_id': _idServicio,
                'tipo': _tipoReporte,
                'prioridad': _prioridadReporte,
                'descripcion': _descReporteCtrl.text,
              };

              bool exito = await ApiService.enviarReporte(payload);
              
              setStateModal(() => enviando = false);

              if (mounted) {
                Navigator.pop(context);
                if (exito) {
                  _descReporteCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tu reporte ha sido enviado. El SuperAdmin lo revisará pronto.'), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar el reporte. Inténtalo de nuevo.'), backgroundColor: Colors.red));
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24, right: 24, top: 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reportar Problema', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('El equipo de SuperAdmin intervendrá en la disputa.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 20),

                  const Text('Motivo del Reporte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _tipoReporte,
                    decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: _tiposDisputa.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
                    onChanged: (val) => setStateModal(() => _tipoReporte = val!),
                  ),
                  const SizedBox(height: 16),

                  const Text('Nivel de Urgencia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _prioridadReporte,
                    decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: _prioridades.map((p) => DropdownMenuItem(value: p['value'], child: Text(p['label']!))).toList(),
                    onChanged: (val) => setStateModal(() => _prioridadReporte = val!),
                  ),
                  const SizedBox(height: 16),

                  const Text('Descripción detallada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descReporteCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Argumenta lo sucedido. Si tienes evidencias, el admin extraerá las fotos que subiste al finalizar...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: enviando ? null : enviarReporte,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: enviando 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Enviar a SuperAdmin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }
    );
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
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: Color(0xFFE26112)),
                  ),
                  child: Stepper(
                    currentStep: _currentStep > 2 ? 2 : _currentStep,
                    controlsBuilder: (context, details) => const SizedBox.shrink(),
                    steps: [
                      Step(
                        title: const Text('Cita Programada', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton.icon(
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
              ),

              // 💡 ZONA DE CONTROL DE EXCEPCIONES (Botón de Reporte)
              if (_currentStep < 3) 
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _mostrarModalReporte,
                        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                        label: const Text('Reportar / Abrir Disputa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
    );
  }
}