import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String servicioId;
  final String nombreCliente;

  const ChatScreen({
    super.key, 
    required this.servicioId, 
    required this.nombreCliente
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _mensajes = [];
  bool _cargando = true;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _obtenerMensajesDelChat();
  }

  Future<void> _obtenerMensajesDelChat() async {
    var msg = await ApiService.obtenerChat(widget.servicioId);
    setState(() {
      _mensajes = msg;
      _cargando = false;
    });
  }

  void _enviarMensaje() async {
    if (_textController.text.trim().isEmpty) return;

    String textoEnviado = _textController.text.trim();
    _textController.clear();

    setState(() {
      _mensajes.add({
        "remitente": "colaborador",
        "contenido": textoEnviado,
        "fecha": DateTime.now().toIso8601String()
      });
    });

    bool enviado = await ApiService.enviarMensaje(widget.servicioId, textoEnviado);
    if (!enviado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar mensaje al servidor')),
      );
      _obtenerMensajesDelChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: ${widget.nombreCliente}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
          : Column(
              children: [
                Expanded(
                  child: _mensajes.isEmpty
                      ? Center(child: Text('Inicia la conversación con ${widget.nombreCliente}', style: const TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _mensajes.length,
                          itemBuilder: (context, index) {
                            final m = _mensajes[index];
                            bool esMio = m['remitente'] == 'colaborador';
                            
                            return Align(
                              alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: esMio ? const Color(0xFFE26112) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12).copyWith(
                                    bottomRight: esMio ? const Radius.circular(0) : const Radius.circular(12),
                                    bottomLeft: esMio ? const Radius.circular(12) : const Radius.circular(0),
                                  ),
                                ),
                                child: Text(
                                  m['contenido'] ?? '',
                                  style: TextStyle(color: esMio ? Colors.white : Colors.black87, fontSize: 14),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFFE26112)),
                          onPressed: _enviarMensaje,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}