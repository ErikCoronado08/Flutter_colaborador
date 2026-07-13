import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart'; // Asegúrate de ajustar la ruta de tu ApiService

class ProfileScreen extends StatefulWidget {
  final bool embed;

  const ProfileScreen({super.key, this.embed = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // Variables de Estado Dinámicas desde MongoDB
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  List<String> _specialties = [];
  File? _profileImage;
  final TextEditingController _specialtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _specialtyController.dispose();
    super.dispose();
  }

  // Carga inicial del perfil del usuario
  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    final perfil = await ApiService.obtenerPerfilUsuario(); // Llama a tu método en ApiService
    
    setState(() {
      if (perfil != null) {
        _userData = perfil;
        // Mapea especialidades asegurando compatibilidad de tipos
        _specialties = List<String>.from(perfil['specialties'] ?? perfil['especialidades'] ?? []);
      }
      _isLoading = false;
    });
  }

  // Selección y subida de imagen de perfil al servidor
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Enviamos el archivo al backend mediante el ApiService
      final exito = await ApiService.actualizarFotoPerfil(_profileImage!);
      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada correctamente.'), backgroundColor: AppColors.success)
        );
        _fetchUserProfile(); // Refrescamos datos
      }
    }
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
            
            // 1. Estadísticas Rápidas
            _buildQuickStats(),
            const SizedBox(height: 32),
            
            // 2. Especialidades y Configuración de Servicio
            _buildSectionTitle('Configuración de Servicio'),
            _buildServiceTags(),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildListTile(Icons.schedule, 'Horarios de trabajo', _userData?['horario'] ?? 'Lun - Sáb', onTap: () => _showDetailModal(context, 'Horarios', _userData?['horario'] ?? 'Lun - Sáb')),
              _buildDivider(),
              _buildListTile(Icons.place, 'Cobertura', '${_userData?['cobertura'] ?? '15'} km', onTap: () => _showDetailModal(context, 'Cobertura', '${_userData?['cobertura'] ?? '15'} km')),
              _buildDivider(),
              _buildListTile(Icons.attach_money, 'Tarifas personalizadas', 'Desde \$${_userData?['tarifaBase'] ?? '250'} MXN/hora', onTap: () => _showDetailModal(context, 'Tarifas', 'Desde \$${_userData?['tarifaBase'] ?? '250'} MXN/hora')),
            ]),
            const SizedBox(height: 24),

            // 3. Resumen Financiero (Balance y Retiro)
            _buildSectionTitle('Billetera y Finanzas'),
            _buildFinancialSummary(),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildListTile(Icons.account_balance, 'Cuenta CLABE', _userData?['clabe'] ?? '**** **** **** 7823', onTap: () => _showDetailModal(context, 'Cuenta CLABE', _userData?['clabe'] ?? '**** **** **** 7823')),
              _buildDivider(),
              _buildListTile(Icons.payments_outlined, 'Solicitar retiro', 'Disponible: \$${_userData?['balance'] ?? '8,450.00'} MXN', trailingIcon: Icons.arrow_forward_ios, onTap: () => _showWithdrawalConfirmation(context)),
            ]),
            const SizedBox(height: 24),

            // 4. Documentación y Seguridad
            _buildSectionTitle('Cuenta y Seguridad'),
            _buildSettingsGroup([
              _buildListTile(Icons.article_outlined, 'Documentos de identidad', _userData?['verificado'] == true ? 'Verificado' : 'Pendiente', trailingColor: _userData?['verificado'] == true ? AppColors.success : Colors.amber, trailingIcon: _userData?['verificado'] == true ? Icons.check_circle : Icons.warning, onTap: () => _showDetailModal(context, 'Identidad', _userData?['verificado'] == true ? 'Verificado' : 'En proceso de revisión')),
              _buildDivider(),
              _buildListTile(Icons.receipt_long, 'Información fiscal', 'RFC: ${_userData?['rfc'] ?? 'No registrado'}', onTap: () => _showDetailModal(context, 'Fiscal', 'RFC: ${_userData?['rfc'] ?? 'No registrado'}')),
              _buildDivider(),
              _buildListTile(Icons.support_agent, 'Soporte', 'Enviar correo', trailingIcon: Icons.arrow_forward_ios, onTap: _launchSupport),
            ]),
            const SizedBox(height: 24),

            // 5. Estadísticas Detalladas de Reseñas
            _buildSectionTitle('Métricas de Calidad'),
            _buildDetailedStatistics(),
            const SizedBox(height: 24),

            // 6. Reseñas Recientes
            _buildSectionTitle('Reseñas Recientes (${_userData?['totalResenas'] ?? '127'})'),
            _buildReviewsSection(),
            const SizedBox(height: 32),

            // Botón de Cerrar Sesión Minimalista
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _mostrarConfirmacionCerrarSesion(context),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Cerrar sesión', 
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
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
    final String? avatarUrl = _userData?['avatarUrl'] ?? _userData?['fotoUrl'];
    final String nombreCompleto = _userData?['name'] ?? _userData?['nombre'] ?? 'Usuario JobHub';

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
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: _profileImage != null 
                      ? FileImage(_profileImage!) 
                      : (avatarUrl != null ? NetworkImage(avatarUrl) as ImageProvider : null),
                  child: (_profileImage == null && avatarUrl == null)
                      ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                      : null,
                ),
              ),
              if (_userData?['verificado'] == true)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            nombreCompleto,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_userData?['verificado'] == true) _buildBadge('Verificado', AppColors.success.withValues(alpha: 0.14), AppColors.success),
              if (_userData?['topRated'] == true) ...[
                const SizedBox(width: 8),
                _buildBadge('Top Rated', Colors.orange.withValues(alpha: 0.14), Colors.orange),
              ],
              const SizedBox(width: 8),
              _buildBadge('Asegurado', Colors.blue.withValues(alpha: 0.14), Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color background, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildQuickStats() {
    final rating = (_userData?['rating'] ?? 4.9).toString();
    final servicios = (_userData?['serviciosCompletados'] ?? 256).toString();
    final tasaMetrica = (_userData?['tasaExito'] ?? '98%').toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(rating, 'Calificación', Icons.star, Colors.amber),
        Container(width: 1, height: 40, color: Colors.grey.shade300),
        _buildStatItem(servicios, 'Servicios', Icons.task_alt, AppColors.success),
        Container(width: 1, height: 40, color: Colors.grey.shade300),
        _buildStatItem(tasaMetrica, 'Completados', Icons.trending_up, Colors.blue),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: iconColor),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final balanceText = '\$${_userData?['balance'] ?? '8,450.00'} MXN';
    final tarjetaOculta = _userData?['tarjetaTerminacion'] ?? '**** **** **** 4582';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brown,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.brown.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance disponible', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(balanceText, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tarjetaOculta, style: const TextStyle(color: Colors.white70, letterSpacing: 1.5)),
              const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTags() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: [
          ..._specialties.map((specialty) => _buildTag(specialty)).toList(),
          _buildAddTag(),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _eliminarEspecialidadBackend(text),
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          )
        ],
      ),
    );
  }

  Widget _buildAddTag() {
    return GestureDetector(
      onTap: () => _showAddSpecialtyDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: AppColors.primary),
            SizedBox(width: 4),
            Text('Agregar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // Métodos de sincronización con API para especialidades
  Future<void> _agregarEspecialidadBackend(String nuevaEsp) async {
    final listadoActualizado = List<String>.from(_specialties)..add(nuevaEsp);
    final exito = await ApiService.actualizarEspecialidades(listadoActualizado);
    if (exito) {
      setState(() => _specialties.add(nuevaEsp));
    }
  }

  Future<void> _eliminarEspecialidadBackend(String remEsp) async {
    final listadoActualizado = List<String>.from(_specialties)..remove(remEsp);
    final exito = await ApiService.actualizarEspecialidades(listadoActualizado);
    if (exito) {
      setState(() => _specialties.remove(remEsp));
    }
  }

  Widget _buildDetailedStatistics() {
    final metrics = _userData?['metricasEstrellas'] ?? {'5': 0.85, '4': 0.10, '3': 0.03, '2': 0.01, '1': 0.01};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildRatingBar('5', (metrics['5'] ?? 0.0).toDouble()),
          const SizedBox(height: 8),
          _buildRatingBar('4', (metrics['4'] ?? 0.0).toDouble()),
          const SizedBox(height: 8),
          _buildRatingBar('3', (metrics['3'] ?? 0.0).toDouble()),
          const SizedBox(height: 8),
          _buildRatingBar('2', (metrics['2'] ?? 0.0).toDouble()),
          const SizedBox(height: 8),
          _buildRatingBar('1', (metrics['1'] ?? 0.0).toDouble()),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String stars, double fraction) {
    return Row(
      children: [
        Text(stars, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(width: 6),
        const Icon(Icons.star, color: Colors.amber, size: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8))),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(height: 8, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text('${(fraction * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final List<dynamic> reviews = _userData?['resenasRecientes'] ?? [
      {'iniciales': 'MG', 'nombre': 'María García', 'comentario': 'Excelente trabajo, muy profesional y puntual.', 'tiempo': 'Hace 2 días'},
      {'iniciales': 'CL', 'nombre': 'Carlos López', 'comentario': 'Buen servicio, resolvió el problema rápidamente.', 'tiempo': 'Hace 5 días'},
    ];

    return Column(
      children: reviews.map((rev) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildReviewCard(rev['iniciales'] ?? 'U', rev['nombre'] ?? 'Anonimo', rev['comentario'] ?? '', rev['tiempo'] ?? ''),
      )).toList(),
    );
  }

  Widget _buildReviewCard(String initials, String name, String message, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        Icon(Icons.star_half, color: Colors.amber, size: 12),
                      ],
                    ),
                  ],
                ),
              ),
              Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  void _showAddSpecialtyDialog(BuildContext context) {
    _specialtyController.clear();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Agregar especialidad'),
          content: TextField(
            controller: _specialtyController,
            decoration: const InputDecoration(hintText: 'Ej. Herrería', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final newSpecialty = _specialtyController.text.trim();
                if (newSpecialty.isNotEmpty) _agregarEspecialidadBackend(newSpecialty);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Agregar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDetailModal(BuildContext context, String title, String subtitle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Entendido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWithdrawalConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Solicitar retiro', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('¿Deseas solicitar un retiro de tu saldo disponible a tu cuenta guardada?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final exito = await ApiService.solicitarRetiro();
                if (exito && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud de retiro procesada.'), backgroundColor: AppColors.success));
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
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Cerrar sesión', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text('¿Estás seguro de que deseas salir de tu cuenta?', style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                await ApiService.logout();
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