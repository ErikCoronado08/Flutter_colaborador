import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 
import '../operaciones/chat_screen.dart'; // <--- Mantenemos tu importación correcta

class MessagesScreen extends StatefulWidget {
  final bool standalone;
  const MessagesScreen({super.key, this.standalone = true});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatsBackend();
  }

  Future<void> _fetchChatsBackend() async {
    setState(() => _isLoading = true);
    final datosChats = await ApiService.obtenerConversaciones(); 
    setState(() {
      _chats = datosChats ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Fondo gris/azulado moderno
      appBar: widget.standalone 
          ? AppBar(
              title: const Text('Mensajes', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)), 
              backgroundColor: Colors.white, 
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.05),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black87),
            ) 
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💡 NUEVO: Título grande si se muestra dentro de la barra de navegación inferior
            if (!widget.standalone)
              const Padding(
                padding: EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 10),
                child: Text(
                  'Tus Chats', 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
                ),
              ),
              
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchChatsBackend,
                color: const Color(0xFFE26112),
                backgroundColor: Colors.white,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
                    : _chats.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _chats.length,
                            itemBuilder: (context, index) {
                              final chat = _chats[index];
                              final name = chat['cliente_nombre'] ?? 'Cliente';
                              final preview = chat['ultimo_mensaje'] ?? '';
                              final time = chat['hora'] ?? '';
                              final initials = chat['avatar_iniciales'] ?? 'C';
                              final clienteId = chat['cliente_id'].toString();
                              
                              // Detectar si el último mensaje fue una foto para pintarlo diferente
                              final isPhoto = preview.contains('📷');

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03), 
                                      blurRadius: 10, 
                                      offset: const Offset(0, 4)
                                    )
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                       Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                                         clienteId: clienteId, 
                                         nombreCliente: name
                                       ))).then((_) => _fetchChatsBackend()); // Recargar al volver
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // 💡 Avatar con indicador en línea
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 26,
                                                backgroundColor: const Color(0xFFE26112).withOpacity(0.1),
                                                child: Text(initials, style: const TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold, fontSize: 18)),
                                              ),
                                              Positioned(
                                                right: 0,
                                                bottom: 2,
                                                child: Container(
                                                  width: 14,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade500,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Colors.white, width: 2.5),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Textos del chat
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name, 
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  preview, 
                                                  maxLines: 1, 
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: isPhoto ? const Color(0xFFE26112) : Colors.grey.shade600, 
                                                    fontSize: 14,
                                                    fontWeight: isPhoto ? FontWeight.w600 : FontWeight.normal
                                                  )
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          
                                          // Hora y flechita
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 8),
                                              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 NUEVO: Estado vacío elegante
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Color(0xFFE26112)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bandeja limpia', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no tienes conversaciones. Cuando un cliente te escriba o inicies un servicio, aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}