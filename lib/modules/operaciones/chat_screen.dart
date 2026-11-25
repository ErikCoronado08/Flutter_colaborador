import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = true;

  bool _isUploadingImage = false;
  Timer? _timerChat;

  @override
  void initState() {
    super.initState();
    _obtenerMensajesDelChat();
    _timerChat = Timer.periodic(const Duration(seconds: 3), (_) {
      _obtenerMensajesDelChatSilencioso();
    });
  }

  @override
  void dispose() {
    _timerChat?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _obtenerMensajesDelChat() async {
    var msg = await ApiService.obtenerChat(widget.clienteId);
    if (!mounted) return;
    setState(() {
      _messages = msg;
      _isLoading = false;
    });
    _hacerScrollHaciaAbajo();
  }

  Future<void> _obtenerMensajesDelChatSilencioso() async {
    if (_isUploadingImage) return;

    var msg = await ApiService.obtenerChat(widget.clienteId);
    if (mounted && !_isUploadingImage) {
      for (var newMsg in msg) {
        if (newMsg['tipo_mensaje'] == 'imagen') {
          for (var currentMsg in _messages) {
            if (currentMsg['tipo_mensaje'] == 'imagen' && currentMsg['local_image'] != null) {
              if (currentMsg['id'] == newMsg['id'] || currentMsg['id'] == null) {
                newMsg['local_image'] = currentMsg['local_image'];
                break;
              }
            }
          }
        }
      }

      if (msg.length != _messages.length) {
        setState(() => _messages = msg);
        _hacerScrollHaciaAbajo();
      } else {
        setState(() => _messages = msg);
      }
    }
  }

  void _hacerScrollHaciaAbajo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    setState(() {
      _messages.add({
        'id': null,
        'contenido': text,
        'tipo': 'enviado',
        'tipo_mensaje': 'texto',
        'hora': TimeOfDay.now().format(context),
      });
    });
    _hacerScrollHaciaAbajo();

    bool enviado = await ApiService.enviarMensaje(widget.clienteId, text);
    if (!enviado && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar mensaje', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      _obtenerMensajesDelChat();
    } else {
      // Sincroniza para obtener el ID real de la BD y permitir borrarlo
      _obtenerMensajesDelChatSilencioso();
    }
  }

  void _confirmarEliminarMensaje(dynamic message, int index) {
    final mensajeId = message['id']?.toString();
    if (mensajeId == null || mensajeId.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar mensaje', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('¿Deseas eliminar este mensaje para ambos? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final respaldo = _messages[index];
              setState(() {
                _messages.removeAt(index);
              });

              bool eliminado = await ApiService.eliminarMensaje(mensajeId);
              if (!eliminado && mounted) {
                setState(() {
                  _messages.insert(index, respaldo);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo eliminar el mensaje'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Compartir archivo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFFFF2E3), child: Icon(Icons.camera_alt, color: Color(0xFFE26112))),
                  title: const Text('Tomar foto', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarYEnviarImagen(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFFFF2E3), child: Icon(Icons.photo_library, color: Color(0xFFE26112))),
                  title: const Text('Elegir de la galería', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarYEnviarImagen(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _seleccionarYEnviarImagen(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source, imageQuality: 70);

    if (photo != null) {
      File imageFile = File(photo.path);

      _isUploadingImage = true;

      setState(() {
        _messages.add({
          'id': null,
          'contenido': '',
          'tipo': 'enviado',
          'tipo_mensaje': 'imagen',
          'hora': TimeOfDay.now().format(context),
          'local_image': imageFile,
        });
      });
      _hacerScrollHaciaAbajo();

      bool enviado = await ApiService.enviarImagenChat(widget.clienteId, imageFile);

      _isUploadingImage = false;

      if (!enviado && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir imagen', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
        _obtenerMensajesDelChat();
      } else {
        _obtenerMensajesDelChatSilencioso();
      }
    }
  }

  Widget _construirContenidoMensaje(dynamic message, bool mine) {
    if (message['tipo_mensaje'] == 'imagen') {
      if (message['local_image'] != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(message['local_image'], width: 220, height: 220, fit: BoxFit.cover),
        );
      } else {
        final String? url = ApiService.normalizarUrl(message['contenido']?.toString());

        if (url == null) {
          return SizedBox(
            width: 220,
            height: 220,
            child: Center(child: Icon(Icons.broken_image, color: mine ? Colors.white54 : Colors.grey.shade400, size: 40)),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                width: 220,
                height: 220,
                child: Center(child: CircularProgressIndicator(color: mine ? Colors.white : const Color(0xFFE26112))),
              );
            },
            errorBuilder: (_, __, ___) => SizedBox(
              width: 220,
              height: 220,
              child: Center(child: Icon(Icons.broken_image, color: mine ? Colors.white54 : Colors.grey.shade400, size: 40)),
            ),
          ),
        );
      }
    } else {
      return Text(
        (message['contenido'] ?? '').toString(),
        style: TextStyle(color: mine ? Colors.white : Colors.black87, fontSize: 15, height: 1.3, fontWeight: FontWeight.w500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trimmedName = widget.nombreCliente.trim();
    final String initial = trimmedName.isNotEmpty ? trimmedName[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE26112).withOpacity(0.1),
                  child: Text(initial, style: const TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.green.shade500, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trimmedName.isNotEmpty ? trimmedName : 'Cliente',
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('En línea ahora', style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined, color: Colors.black87, size: 22), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                                ),
                                child: const Icon(Icons.waving_hand_rounded, color: Color(0xFFFFC107), size: 40),
                              ),
                              const SizedBox(height: 16),
                              Text('¡Di Hola!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                              const SizedBox(height: 8),
                              Text('Inicia la conversación para afinar detalles.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 10),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final bool mine = message['tipo'] == 'enviado';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!mine) ...[
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFFE26112).withOpacity(0.1),
                                      child: Text(initial, style: const TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold, fontSize: 10)),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: GestureDetector(
                                      onLongPress: (mine && message['id'] != null)
                                          ? () => _confirmarEliminarMensaje(message, index)
                                          : null,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: message['tipo_mensaje'] == 'imagen' ? 6 : 16,
                                          vertical: message['tipo_mensaje'] == 'imagen' ? 6 : 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: mine
                                              ? const LinearGradient(colors: [Color(0xFFE86E18), Color(0xFFC85F10)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                                              : null,
                                          color: mine ? null : Colors.white,
                                          border: mine ? null : Border.all(color: Colors.grey.shade200),
                                          boxShadow: mine
                                              ? [BoxShadow(color: const Color(0xFFE26112).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(20),
                                            topRight: const Radius.circular(20),
                                            bottomLeft: Radius.circular(mine ? 20 : 0),
                                            bottomRight: Radius.circular(mine ? 0 : 20),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                          children: [
                                            _construirContenidoMensaje(message, mine),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  (message['hora'] ?? '').toString(),
                                                  style: TextStyle(color: mine ? Colors.white70 : Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w600),
                                                ),
                                                if (mine) ...[
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.done_all_rounded, color: Colors.white70, size: 14),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                Container(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF6B6B6B), size: 22),
                          onPressed: _mostrarOpcionesImagen,
                          splashRadius: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _messageController,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            minLines: 1,
                            cursorColor: const Color(0xFFE26112),
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          padding: const EdgeInsets.all(13),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFFE86E18), Color(0xFFB1541A)]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Color(0x4DE26112), blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}