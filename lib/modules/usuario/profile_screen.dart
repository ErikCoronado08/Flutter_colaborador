import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool embed;

  const ProfileScreen({super.key, this.embed = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _userData;
  List<dynamic> _documentos = [];
  bool _isLoading = true;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    final dashboardData = await ApiService.obtenerDashboard();

    if (!mounted) return;
    setState(() {
      if (dashboardData != null) {
        _userData = dashboardData['perfil'];
        _documentos = dashboardData['documentos'] ?? [];
      }
      _isLoading = false;
    });
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      final exito = await ApiService.actualizarFotoPerfil(_profileImage!);
      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada correctamente.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
        _fetchUserProfile();
      }
    }
  }

  Future<void> _subirDocumento(String tipo) async {
    File? archivoSeleccionado;

    if (tipo == 'foto') {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        archivoSeleccionado = File(pickedFile.path);
      }
    } else {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        archivoSeleccionado = File(result.files.single.path!);
      }
    }

    if (archivoSeleccionado == null) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var request = http.MultipartRequest('POST', Uri.parse('https://jobhub.utptics.com/api/colaborador/perfil/documentos'));
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['tipo'] = tipo;
    request.files.add(await http.MultipartFile.fromPath('documento', archivoSeleccionado.path));

    var response = await request.send();

    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento subido correctamente.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al procesar el documento.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
      _fetchUserProfile();
    }
  }

  Future<void> _eliminarDocumento(int id) async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.delete(
      Uri.parse('https://jobhub.utptics.com/api/colaborador/perfil/documentos/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento eliminado.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
      _fetchUserProfile();
    }
  }

  void _mostrarModalEditarPerfil() {
    final nombreCtrl = TextEditingController(text: _userData?['nombre_completo'] ?? '');
    final telefonoCtrl = TextEditingController(text: _userData?['telefono'] ?? '');
    final ocupacionCtrl = TextEditingController(text: _userData?['ocupacion'] ?? '');
    final sobreMiCtrl = TextEditingController(text: _userData?['sobre_mi'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
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
                const Text('Editar Información', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: telefonoCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: ocupacionCtrl, decoration: InputDecoration(labelText: 'Ocupación', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: sobreMiCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Sobre mí', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);

                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token') ?? '';

                      final response = await http.post(
                        Uri.parse('https://jobhub.utptics.com/api/colaborador/actualizar-perfil'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                          'Authorization': 'Bearer $token',
                        },
                        body: jsonEncode({
                          'nombres': nombreCtrl.text,
                          'telefono': telefonoCtrl.text,
                          'ocupacion': ocupacionCtrl.text,
                          'sobre_mi': sobreMiCtrl.text,
                        }),
                      );

                      if (response.statusCode == 200 && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado con éxito', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                        _fetchUserProfile();
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar perfil', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                        setState(() => _isLoading = false);
                      }
                    },
                    child: const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchSupport() async {
    final Uri url = Uri(scheme: 'mailto', path: 'soporte@jobhub.com', query: 'subject=Soporte JobHub');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el correo de soporte.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE26112))),
      );
    }

    final content = RefreshIndicator(
      onRefresh: _fetchUserProfile,
      color: const Color(0xFFE26112),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactHeader(),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _mostrarModalEditarPerfil,
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFE26112)),
                label: const Text('Editar información personal', style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFE26112)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('Expediente de Seguridad'),
            const SizedBox(height: 12),
            _buildDocumentosLista(),
            const SizedBox(height: 32),

            _buildSectionTitle('Soporte'),
            _buildSettingsGroup([
              _buildListTile(Icons.support_agent, 'Atención al Cliente', 'Enviar correo a soporte', trailingIcon: Icons.arrow_forward_ios, onTap: _launchSupport),
            ]),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _mostrarConfirmacionCerrarSesion(context),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.redAccent.withOpacity(0.08),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    return widget.embed
        ? content
        : Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Mi Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              centerTitle: true,
            ),
            body: content,
          );
  }

  Widget _buildCompactHeader() {
    final String? avatarUrl = ApiService.normalizarUrl(_userData?['foto_perfil_url']?.toString());
    final String nombreCompleto = _userData?['nombre_completo'] ?? 'Colaborador';
    final String email = _userData?['email'] ?? '';
    final String ocupacion = _userData?['ocupacion'] ?? '';
    final String calificacion = _userData?['calificacion']?.toString() ?? '5.0';

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE26112).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : (avatarUrl != null
                            ? Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 48, color: Color(0xFFE26112)),
                              )
                            : const Icon(Icons.person, size: 48, color: Color(0xFFE26112))),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(nombreCompleto, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (ocupacion.isNotEmpty) ...[
                Text(ocupacion, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFE26112))),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(calificacion, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildDocumentosLista() {
    const tipos = [
      {'tipo': 'foto', 'label': 'Fotografía de Rostro'},
      {'tipo': 'ine', 'label': 'Identificación Oficial (INE)'},
      {'tipo': 'domicilio', 'label': 'Comprobante de Domicilio'},
      {'tipo': 'antecedentes', 'label': 'Antecedentes no Penales'},
    ];

    Future<void> verDocumento(String rawUrl) async {
      final String? urlNormalizada = ApiService.normalizarUrl(rawUrl);
      if (urlNormalizada == null) return;

      final Uri uri = Uri.parse(urlNormalizada);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el documento.'), backgroundColor: Colors.red),
          );
        }
      }
    }

    return Column(
      children: tipos.map((docData) {
        final String tipo = docData['tipo']!;
        final String label = docData['label']!;

        final docExistente = _documentos.firstWhere((d) => d['tipo'] == tipo, orElse: () => null);

        String estadoStr = 'NO SUBIDO';
        Color colorEstado = Colors.grey;
        IconData iconoEstado = Icons.error_outline;

        if (docExistente != null) {
          final rawEstado = (docExistente['estado'] ?? '').toString().toLowerCase();
          if (rawEstado == 'aprobado' || rawEstado == 'aceptado') {
            estadoStr = 'VERIFICADO';
            colorEstado = Colors.green;
            iconoEstado = Icons.check_circle;
          } else if (rawEstado == 'pendiente' || rawEstado == 'revision') {
            estadoStr = 'EN REVISIÓN';
            colorEstado = Colors.amber.shade700;
            iconoEstado = Icons.hourglass_top;
          } else if (rawEstado == 'rechazado') {
            estadoStr = 'RECHAZADO';
            colorEstado = Colors.red;
            iconoEstado = Icons.cancel;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorEstado.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(iconoEstado, color: colorEstado, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(estadoStr, style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ],
                ),
              ),
              if (docExistente != null) ...[
                if (docExistente['url'] != null && docExistente['url'].toString().isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, color: Colors.blueAccent),
                    tooltip: 'Ver documento',
                    onPressed: () => verDocumento(docExistente['url'].toString()),
                  ),
                IconButton(
                  icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFFE26112)),
                  tooltip: 'Reemplazar documento',
                  onPressed: () => _subirDocumento(tipo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Eliminar',
                  onPressed: () => _eliminarDocumento(docExistente['id']),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => _subirDocumento(tipo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE26112),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  child: const Text('Subir', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, {IconData trailingIcon = Icons.arrow_forward_ios, Color? trailingColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE26112).withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: const Color(0xFFE26112))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(trailingIcon, size: 16, color: trailingColor ?? Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _mostrarConfirmacionCerrarSesion(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [Icon(Icons.logout, color: Colors.redAccent), SizedBox(width: 10), Text('Cerrar sesión', style: TextStyle(fontSize: 18))]),
          content: const Text('¿Estás seguro de que deseas salir?', style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              child: const Text('Salir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}