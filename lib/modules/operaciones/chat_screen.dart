import 'package:flutter/material.dart';
import 'conversation_screen.dart';

class ChatScreen extends StatelessWidget {
  final bool standalone;

  const ChatScreen({super.key, this.standalone = true});

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        const Text(
          'Chats Activos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Barra de búsqueda moderna
        _buildSearchBar(),
        
        const SizedBox(height: 24),
        
        // Lista de Chats (manteniendo la información original del archivo)
        _chatTile(context, 'María García', 'MG', 'Gracias por el servicio.', 'Ahora', unread: true),
        _chatTile(context, 'Carlos Ruiz', 'CR', '¿Puedes revisar el presupuesto?', 'Ayer', unread: false),
        _chatTile(context, 'Sofía Hernández', 'SH', 'Perfecto, te espero.', '2 días', unread: false),
      ],
    );

    return standalone
        ? Scaffold(
            backgroundColor: const Color(0xFFF8F9FA), // Fondo unificado
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black87),
              title: const Text(
                'Chat',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            body: body,
          )
        : body;
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar un chat...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _chatTile(BuildContext context, String name, String initials, String lastMessage, String time, {bool unread = false}) {
    return GestureDetector(
      onTap: () {
        // Mantenemos la navegación original hacia ConversationScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(
              contactName: name,
              subtitle: lastMessage,
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
          border: Border.all(color: unread ? const Color(0xFFE26112).withOpacity(0.3) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: unread ? const Color(0xFFE26112).withOpacity(0.1) : Colors.grey.shade100,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: unread ? const Color(0xFFE26112) : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
                        color: Colors.green, // Indicador verde estilo "En línea" o nuevo
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
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
                    lastMessage,
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