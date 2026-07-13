import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../services/auth_service.dart'; 

class Documents extends StatefulWidget {
  const Documents({super.key});

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();
  bool _estaCargando = false;
  final double _progreso = 0.5;

  File? _ineFile, _compFile, _fotoFile, _antFile;

  @override
  void initState() {
    super.initState();
    // Ya no se consulta estatus al servidor al iniciar para evitar errores de autenticación
  }

  void _guardarArchivo(String key, File file) {
    setState(() {
      if (key == 'ine_subido') _ineFile = file;
      if (key == 'comprobante_subido') _compFile = file;
      if (key == 'foto_subida') _fotoFile = file;
      if (key == 'antecedentes_subido') _antFile = file;
    });
  }

  Future<void> _showUploadOptions(String documentName, String key) async {
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
                _handleCameraUpload(key);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Color(0xFFE26112)),
              title: const Text("Seleccionar PDF o Imagen"),
              onTap: () {
                Navigator.pop(context);
                _handleFilePicker(key);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraUpload(String key) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null && mounted) {
        _guardarArchivo(key, File(photo.path));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto capturada con éxito')));
      }
    }
  }

  Future<void> _handleFilePicker(String key) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png'],
      );
      if (result != null && result.files.single.path != null && mounted) {
        _guardarArchivo(key, File(result.files.single.path!));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo seleccionado con éxito')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al seleccionar el archivo')));
    }
  }

  Future<void> _submitDocuments() async {
    if (_ineFile == null || _compFile == null || _fotoFile == null || _antFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Debes seleccionar todos los archivos")));
      return;
    }

    setState(() => _estaCargando = true);
    
    try {
      print("Subiendo archivos al servidor..."); 
      await _authService.subirDocumentos(
        ine: _ineFile!,
        comprobante: _compFile!,
        fotoPerfil: _fotoFile!,
        antecedentes: _antFile!,
      );

      if (mounted) {
        setState(() => _estaCargando = false);
        print("Envío terminado: Redirigiendo a Login.");
        // Redirección directa e incondicional a la vista de Login
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _estaCargando = false);
        print("Error en el envío, redirigiendo de igual forma: $e");
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Widget documentCard(String title, String statusKey, String subtitle) {
    bool isSelected = (statusKey == 'ine_subido' && _ineFile != null) ||
                      (statusKey == 'comprobante_subido' && _compFile != null) ||
                      (statusKey == 'foto_subida' && _fotoFile != null) ||
                      (statusKey == 'antecedentes_subido' && _antFile != null);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSelected ? Colors.green : const Color(0xFFE8E8E8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(color: isSelected ? Colors.green.shade50 : const Color(0xFFFBECE3), borderRadius: BorderRadius.circular(14)),
            child: Icon(
              isSelected ? Icons.check_circle : Icons.description_outlined, 
              color: isSelected ? Colors.green : const Color(0xFFE26112), 
              size: 28
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(isSelected ? "Archivo cargado localmente" : subtitle, style: TextStyle(color: isSelected ? Colors.green : const Color(0xFF777777), fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showUploadOptions(title, statusKey),
            style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: const Color(0xFFE26112), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(isSelected ? "Cambiar" : "Subir", style: const TextStyle(color: Colors.white)),
          ),
        ],
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
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          children: [
                            const Text("Paso 2 de 2", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            documentCard("Identificación Oficial (INE)", "ine_subido", "PDF o JPG"),
                            documentCard("Comprobante de domicilio", "comprobante_subido", "PDF o JPG"),
                            documentCard("Foto de perfil", "foto_subida", "JPG cuadrado"),
                            documentCard("Antecedentes no penales", "antecedentes_subido", "PDF o JPG"),
                            const SizedBox(height: 25),
                            CustomButton(
                              text: "ENVIAR EXPEDIENTE",
                              onTap: () => _submitDocuments(), 
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