import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../operaciones/conversation_screen.dart';

class MessagesScreen extends StatelessWidget {
  final bool standalone;

  const MessagesScreen({super.key, this.standalone = true});

  @override
  Widget build(BuildContext context) {
    final body = ListView(
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
        
        // Barra de búsqueda moderna
        _buildSearchBar(),
        
        const SizedBox(height: 24),
        
        // Lista de Mensajes (Añadido un parámetro 'unread' para dar realismo)
        _messageTile(context, 'María López', 'ML', '¿Llegarás a tiempo para la instalación?', '10:10 AM', unread: true),
        _messageTile(context, 'Carlos Ruiz', 'CR', 'Confirmé el mantenimiento de la bomba de agua.', '9:42 AM', unread: false),
        _messageTile(context, 'Sofía Hernández', 'SH', 'Necesito una revisión extra en la tubería.', '8:18 AM', unread: false),
        _messageTile(context, 'Eduardo Torres', 'ET', 'Muchas gracias, el servicio quedó excelente.', 'Ayer', unread: false),
      ],
    );

    return standalone
        ? Scaffold(
            backgroundColor: const Color(0xFFF8F9FA), // Fondo claro
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
          hintText: 'Buscar mensajes...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _messageTile(BuildContext context, String name, String initials, String preview, String time, {bool unread = false}) {
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
          // Borde naranja si no está leído, borde gris sutil si ya se leyó
          border: Border.all(color: unread ? const Color(0xFFE26112).withOpacity(0.3) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Avatar con indicador
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
                      child: Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
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
            
            // Textos centrales
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
            
            // Hora y Badge
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
                  const SizedBox(height: 20), // Placeholder para mantener la alineación de las tarjetas
              ],
            ),
          ],
        ),
      ),
    );
  }
}