import 'dart:convert'; // <--- FALTABA ESTE
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http; // <--- FALTABA ESTE
import 'package:shared_preferences/shared_preferences.dart'; // <--- FALTABA ESTE
import '../../theme/app_colors.dart';
import '../../services/api_service.dart'; 
import '../../services/finanzas_service.dart'; 
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
  bool _isLoading = true;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    final perfil = await ApiService.obtenerPerfilUsuario(); 
    
    setState(() {
      if (perfil != null) {
        _userData = perfil;
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
          const SnackBar(content: Text('Foto de perfil actualizada correctamente.'), backgroundColor: AppColors.success)
        );
        _fetchUserProfile(); 
      }
    }
  }

  // Diálogo para editar la información del perfil
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
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Editar Información', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: telefonoCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: ocupacionCtrl, decoration: const InputDecoration(labelText: 'Ocupación', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: sobreMiCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Sobre mí', border: OutlineInputBorder())),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () async {
                      Navigator.pop(context);
                      
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado con éxito'), backgroundColor: Colors.green));
                        _fetchUserProfile();
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar perfil'), backgroundColor: Colors.red));
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
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final content = RefreshIndicator(
      onRefresh: _fetchUserProfile,
      color: AppColors.primary,
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
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                label: const Text('Editar información personal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Billetera y Finanzas'),
            _buildFinancialSummary(),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildListTile(Icons.payments_outlined, 'Solicitar retiro', 'Disponible: \$${_userData?['saldo_disponible'] ?? '0.00'} MXN', trailingIcon: Icons.arrow_forward_ios, onTap: () => _showWithdrawalConfirmation(context)),
            ]),
            const SizedBox(height: 24),

            _buildSectionTitle('Cuenta y Seguridad'),
            _buildSettingsGroup([
              _buildListTile(Icons.article_outlined, 'Documentos de identidad', _userData?['estado'] == 'aprobado' ? 'Verificado' : 'Pendiente', trailingColor: _userData?['estado'] == 'aprobado' ? AppColors.success : Colors.amber, trailingIcon: _userData?['estado'] == 'aprobado' ? Icons.check_circle : Icons.warning, onTap: () {}),
              _buildDivider(),
              _buildListTile(Icons.support_agent, 'Soporte Técnico', 'Enviar correo', trailingIcon: Icons.arrow_forward_ios, onTap: _launchSupport),
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
    final String? avatarUrl = _userData?['foto_perfil_url'];
    final String nombreCompleto = _userData?['nombre_completo'] ?? 'Colaborador';
    final String email = _userData?['email'] ?? '';
    final String ocupacion = _userData?['ocupacion'] ?? '';

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: _profileImage != null 
                      ? FileImage(_profileImage!) 
                      : (avatarUrl != null ? NetworkImage(avatarUrl) as ImageProvider : null),
                  child: (_profileImage == null && avatarUrl == null)
                      ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                      : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(nombreCompleto, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          if (ocupacion.isNotEmpty) ...[
            Text(ocupacion, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
            const SizedBox(height: 2),
          ],
          Text(email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  Widget _buildFinancialSummary() {
    final balanceText = '\$${_userData?['saldo_disponible'] ?? '0.00'} MXN';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brown,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.brown.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance disponible', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(balanceText, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)), child: Column(children: children));
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, {IconData trailingIcon = Icons.arrow_forward_ios, Color? trailingColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: AppColors.primary)),
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

  Widget _buildDivider() {
    return Padding(padding: const EdgeInsets.only(left: 56, right: 16), child: Divider(height: 1, color: Colors.grey.shade100));
  }

  void _showWithdrawalConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Solicitar retiro', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('¿Deseas solicitar un retiro de tu saldo disponible?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                double saldo = double.tryParse(_userData?['saldo_disponible']?.toString() ?? '0') ?? 0.0;
                final exito = await FinanzasService().solicitarRetiro(saldo);
                
                if (exito && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retiro procesado con éxito.'), backgroundColor: AppColors.success));
                  _fetchUserProfile();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Confirmar Retiro', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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