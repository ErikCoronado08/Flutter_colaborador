import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String clienteId;
  final String nombreCliente;

  const ChatScreen({super.key, required this.clienteId, required this.nombreCliente});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerMensajesDelChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _obtenerMensajesDelChat() async {
    // LLAMA A LA API WEB: /api/colaborador/mensajes/{clienteId}
    var msg = await ApiService.obtenerChat(widget.clienteId);
    setState(() {
      _messages = msg;
      _isLoading = false;
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    // Actualizamos la UI inmediatamente para dar sensación de rapidez
    setState(() {
      _messages.add({
        'contenido': text,
        'tipo': 'enviado', // El backend web devuelve "enviado" o "recibido"
        'hora': TimeOfDay.now().format(context),
      });
    });

    // Enviamos a la BD
    bool enviado = await ApiService.enviarMensaje(widget.clienteId, text);
    if (!enviado) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar mensaje')));
      }
      _obtenerMensajesDelChat(); // Recargamos si falla
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initial = widget.nombreCliente.isNotEmpty ? widget.nombreCliente[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleSpacing: 0, 
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE26112).withOpacity(0.1),
              child: Text(initial, style: const TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.nombreCliente, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('En línea', style: TextStyle(color: Colors.green.shade500, fontSize: 12, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
        : Column(
        children: [
          Expanded(
            child: _messages.isEmpty 
              ? const Center(child: Text('Inicia la conversación...', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                // Determinamos si es mío basándonos en la respuesta de Laravel
                final bool mine = message['tipo'] == 'enviado'; 
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: mine ? const Color(0xFFE26112) : Colors.white,
                      border: mine ? null : Border.all(color: Colors.grey.shade200),
                      boxShadow: mine 
                        ? [BoxShadow(color: const Color(0xFFE26112).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
                        : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(mine ? 20 : 4),
                        bottomRight: Radius.circular(mine ? 4 : 20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(message['contenido'] ?? '', style: TextStyle(color: mine ? Colors.white : Colors.black87, fontSize: 15, height: 1.3)),
                        const SizedBox(height: 4),
                        Text(message['hora'] ?? '', style: TextStyle(color: mine ? Colors.white70 : Colors.grey.shade500, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Caja de texto
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, -5))]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      fillColor: const Color(0xFFF1F3F5), 
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFE26112), shape: BoxShape.circle), child: const Icon(Icons.send, color: Colors.white, size: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}