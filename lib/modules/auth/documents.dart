import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart'; // Importación necesaria
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class Documents extends StatefulWidget {
  const Documents({super.key});

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  final ImagePicker _picker = ImagePicker();
  bool _estaCargando = false;
  double _progreso = 0.5; // Comienza al 50%

  Future<void> _showUploadOptions(String documentName) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFE26112)),
              title: const Text("Tomar foto"),
              onTap: () {
                Navigator.pop(context);
                _handleCameraUpload(documentName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Color(0xFFE26112)),
              title: const Text("Seleccionar PDF o Imagen"),
              onTap: () {
                Navigator.pop(context);
                _handleFilePicker(documentName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraUpload(String docName) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$docName capturado correctamente')));
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _handleFilePicker(String docName) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png'],
      );
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$docName seleccionado: ${result.files.single.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al seleccionar el archivo')));
      }
    }
  }

  // Tarjeta de documento con DropTarget integrado
  Widget documentCard(String title, String subtitle) {
    return DropTarget(
      onDragDone: (details) async {
        for (var file in details.files) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title cargado: ${file.name}')));
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 55, height: 55,
              decoration: BoxDecoration(color: const Color(0xFFFBECE3), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.description_outlined, color: Color(0xFFE26112), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF777777), fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showUploadOptions(title),
              style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: const Color(0xFFE26112), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Subir", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _estaCargando,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _progreso,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE26112)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFFE26112)),
                          label: const Text("Volver", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            Image.asset('assets/images/logo.png', width: 90),
                            const SizedBox(height: 15),
                            const Text("CONECTANDO OPORTUNIDADES", style: TextStyle(color: Color(0xFFE26112), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          children: [
                            const Text("Paso 2 de 2", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text("Expediente de Seguridad", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF111111), fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            documentCard("Identificación Oficial (INE)", "PDF o JPG"),
                            documentCard("Comprobante de domicilio", "PDF o JPG"),
                            documentCard("Foto de perfil", "JPG cuadrado"),
                            documentCard("Antecedentes no penales", "PDF o JPG"),
                            const SizedBox(height: 25),
                            CustomButton(
                              text: "ENVIAR EXPEDIENTE",
                              onTap: () async {
                                setState(() {
                                  _estaCargando = true;
                                  _progreso = 0.75;
                                });
                                await Future.delayed(const Duration(seconds: 2));
                                setState(() => _progreso = 1.0);
                                await Future.delayed(const Duration(milliseconds: 500));
                                
                                if (mounted) {
                                  setState(() => _estaCargando = false);
                                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}