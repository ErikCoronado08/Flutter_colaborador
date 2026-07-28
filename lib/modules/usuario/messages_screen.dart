import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 
import '../operaciones/chat_screen.dart'; // <--- CAMBIO IMPORTANTE

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: widget.standalone ? AppBar(title: const Text('Mensajes', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0) : null,
      body: RefreshIndicator(
        onRefresh: _fetchChatsBackend,
        color: const Color(0xFFE26112),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
            : _chats.isEmpty
                ? const Center(child: Text('Bandeja vacía. Aún no tienes chats.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      final name = chat['cliente_nombre'] ?? 'Cliente';
                      final preview = chat['ultimo_mensaje'] ?? '';
                      final time = chat['hora'] ?? '';
                      final initials = chat['avatar_iniciales'] ?? 'C';
                      final clienteId = chat['cliente_id'].toString();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE26112).withOpacity(0.1),
                            child: Text(initials, style: const TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          onTap: () {
                             // NAVEGAMOS AL CHAT REAL
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                               clienteId: clienteId, 
                               nombreCliente: name
                             )));
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}