import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../operaciones/conversation_screen.dart';
import '../../services/api_service.dart'; // Asegúrate de ajustar la ruta de tu ApiService

class MessagesScreen extends StatefulWidget {
  final bool standalone;

  const MessagesScreen({super.key, this.standalone = true});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> _allChats = [];        // Conversaciones completas del servidor
  List<dynamic> _filteredChats = [];   // Conversaciones filtradas por la barra de búsqueda
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChatsBackend();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Método para obtener los chats desde MongoDB
  Future<void> _fetchChatsBackend() async {
    setState(() => _isLoading = true);
    final datosChats = await ApiService.obtenerChats(); // Asegúrate de tener este método en tu ApiService
    setState(() {
      if (datosChats != null) {
        _allChats = datosChats;
        _filteredChats = datosChats;
      }
      _isLoading = false;
    });
  }

  // Filtrado local en base al input del usuario
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChats = _allChats;
      } else {
        _filteredChats = _allChats.where((chat) {
          final nombre = (chat['name'] ?? chat['contacto'] ?? '').toString().toLowerCase();
          final ultimoMensaje = (chat['preview'] ?? chat['ultimoMensaje'] ?? '').toString().toLowerCase();
          return nombre.contains(query) || ultimoMensaje.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _fetchChatsBackend, // Pull to refresh
      color: const Color(0xFFE26112),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                const Text(
                  'Bandeja de entrada',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Barra de búsqueda moderna conectada al filtro
                _buildSearchBar(),
                
                const SizedBox(height: 24),
                
                // Lista de Mensajes Dinámica
                if (_filteredChats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No tienes mensajes aún'
                            : 'No se encontraron chats',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ..._filteredChats.map((chat) => _buildMessageTile(context, chat as Map<String, dynamic>)).toList(),
              ],
            ),
    );

    return widget.standalone
        ? Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black87),
              title: const Text(
                'Mensajes',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            body: body,
          )
        : Scaffold(backgroundColor: const Color(0xFFF8F9FA), body: body);
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar mensajes...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMessageTile(BuildContext context, Map<String, dynamic> chat) {
    // Mapeo flexible para soportar nombres de llaves de tu backend (Ej: MongoDB)
    final String name = chat['name'] ?? chat['contacto'] ?? 'Usuario';
    final String preview = chat['preview'] ?? chat['ultimoMensaje'] ?? '';
    final String time = chat['time'] ?? chat['hora'] ?? '';
    final bool unread = chat['unread'] ?? chat['noLeido'] ?? false;
    
    // Obtener iniciales automáticamente del nombre recibido
    final String initials = name.isNotEmpty 
        ? name.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : 'U';

    final Color statusBorderColor = unread ? const Color(0xFFE26112).withValues(alpha: 0.3) : Colors.grey.shade200;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(
              contactName: name,
              subtitle: preview,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusBorderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Avatar con indicador en red o Shimmer loader
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: 'https://picsum.photos/seed/${initials.toLowerCase()}/100',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(width: 48, height: 48, color: Colors.grey.shade300),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 24,
                      backgroundColor: unread ? const Color(0xFFE26112).withValues(alpha: 0.1) : Colors.grey.shade100,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: unread ? const Color(0xFFE26112) : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                if (unread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Textos centrales (Nombre y último mensaje)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread ? Colors.black87 : Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Hora y número de mensajes pendientes
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: unread ? const Color(0xFFE26112) : Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                if (unread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE26112),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}