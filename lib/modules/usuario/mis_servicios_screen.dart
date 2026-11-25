import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import 'service_detail_view.dart';

class MisServiciosScreen extends StatefulWidget {
  const MisServiciosScreen({super.key});

  @override
  State<MisServiciosScreen> createState() => _MisServiciosScreenState();
}

class _MisServiciosScreenState extends State<MisServiciosScreen> {
  List<dynamic> _misServicios = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    setState(() => _isLoading = true);
    final data = await ApiService.obtenerMisServicios();
    if (!mounted) return;
    setState(() {
      _misServicios = data;
      _isLoading = false;
    });
  }

  void _mostrarDialogoAgregar() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    final catalogo = await ApiService.obtenerCatalogoServicios();
    if (!mounted) return;
    Navigator.pop(context);

    if (catalogo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay servicios disponibles en el catálogo.')),
      );
      return;
    }

    String? selectedServicioId = catalogo.first['id'].toString();
    final nombreCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    String tipoTarifa = 'Por hora';
    File? imagenSeleccionada;
    bool guardando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            Future<void> elegirImagen(ImageSource source) async {
              final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
              if (picked != null) {
                setStateModal(() => imagenSeleccionada = File(picked.path));
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Publicar Servicio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 20),

                    // Selector de foto del servicio
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (ctx) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library, color: AppColors.primary),
                                  title: const Text('Elegir de la galería'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    elegirImagen(ImageSource.gallery);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                                  title: const Text('Tomar fotografía'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    elegirImagen(ImageSource.camera);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: imagenSeleccionada != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.file(imagenSeleccionada!, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => setStateModal(() => imagenSeleccionada = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.primary.withOpacity(0.8)),
                                  const SizedBox(height: 8),
                                  const Text('Agregar foto del servicio (opcional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                                  const SizedBox(height: 2),
                                  Text('JPG, PNG o WEBP (máx. 5 MB)', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedServicioId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Categoría Base', border: OutlineInputBorder()),
                      items: catalogo.map<DropdownMenuItem<String>>((s) {
                        return DropdownMenuItem<String>(
                          value: s['id'].toString(),
                          child: Text(
                            s['titulo'] ?? 'Servicio',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setStateModal(() => selectedServicioId = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Título personalizado', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextField(controller: descripcionCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: precioCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio', prefixIcon: Icon(Icons.attach_money), border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: tipoTarifa,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Tarifa', border: OutlineInputBorder()),
                            items: ['Por hora', 'Por servicio', 'Por m2']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setStateModal(() => tipoTarifa = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: guardando
                            ? null
                            : () async {
                                final precioNum = double.tryParse(precioCtrl.text.trim());
                                if (selectedServicioId == null || nombreCtrl.text.trim().isEmpty || precioNum == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todos los campos obligatorios')));
                                  return;
                                }

                                setStateModal(() => guardando = true);

                                final payload = {
                                  'servicio_id': selectedServicioId,
                                  'nombre': nombreCtrl.text.trim(),
                                  'descripcion': descripcionCtrl.text.trim(),
                                  'precioUnidad': precioNum,
                                  'tipoTarifa': tipoTarifa,
                                };

                                bool exito = await ApiService.crearServicio(payload, foto: imagenSeleccionada);
                                if (!mounted) return;

                                Navigator.pop(context);

                                if (exito) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(content: Text('Servicio enviado a revisión'), backgroundColor: Colors.green),
                                  );
                                  await _cargarServicios();
                                } else {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(content: Text('No se pudo guardar el servicio'), backgroundColor: Colors.red),
                                  );
                                }
                              },
                        child: guardando
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('GUARDAR Y PUBLICAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Mis Servicios', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoAgregar,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _misServicios.isEmpty
              ? const Center(child: Text('Aún no tienes servicios publicados.', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _cargarServicios,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _misServicios.length,
                    itemBuilder: (context, index) {
                      final srv = _misServicios[index];
                      final nombre = srv['nombre'] ?? 'Servicio';
                      final categoria = srv['categoria'] ?? 'General';
                      final descripcion = srv['descripcion'] ?? '';
                      final precio = srv['precioUnidad'] ?? '0';
                      final tarifa = srv['tipoTarifa'] ?? '';
                      final estado = srv['estado_publicacion'] ?? 'pendiente';
                      final String? fotoUrl = ApiService.normalizarUrl((srv['foto_url'] ?? srv['foto_path'])?.toString());

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailView(servicio: srv),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (fotoUrl != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.network(
                                    fotoUrl,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                          child: Text(categoria, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                          onPressed: () async {
                                            bool exito = await ApiService.eliminarServicio(srv['id'].toString());
                                            if (exito) _cargarServicios();
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    Text(descripcion, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(height: 1),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '\$$precio MXN / $tarifa',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: estado == 'aprobado' ? Colors.green.shade50 : Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            estado.toUpperCase(),
                                            style: TextStyle(
                                              color: estado == 'aprobado' ? Colors.green.shade700 : Colors.orange.shade800,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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