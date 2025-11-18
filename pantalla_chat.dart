import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../reportes/pantalla_detalle_completo.dart';

class PantallaChat extends StatefulWidget {
  final String chatId;
  final String reporteId;
  final String tipo;
  final String publicadorId;
  final String usuarioId;

  const PantallaChat({
    super.key,
    required this.chatId,
    required this.reporteId,
    required this.tipo,
    required this.publicadorId,
    required this.usuarioId,
  });

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final TextEditingController _mensajeCtrl = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _reporteData;
  Map<String, dynamic>? _usuarioPublicador;
  Map<String, dynamic>? _usuarioActual;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await Future.wait([
      _cargarInfoReporte(),
      _cargarUsuarios(),
    ]);
  }

  Future<void> _cargarInfoReporte() async {
    try {
      final col = widget.tipo == "reporte"
          ? "reportes_mascotas"
          : "avistamientos";

      final doc = await FirebaseFirestore.instance
          .collection(col)
          .doc(widget.reporteId)
          .get();

      if (doc.exists) {
        setState(() {
          _reporteData = doc.data();
        });
      }
    } catch (e) {
      debugPrint("Error cargando reporte: $e");
    }
  }

  Future<void> _cargarUsuarios() async {
    try {
      // Cargar datos del publicador
      final docPublicador = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(widget.publicadorId)
          .get();

      // Cargar datos del usuario actual
      final docActual = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(widget.usuarioId)
          .get();

      setState(() {
        _usuarioPublicador = docPublicador.exists ? docPublicador.data() : null;
        _usuarioActual = docActual.exists ? docActual.data() : null;
        _cargando = false;
      });
    } catch (e) {
      debugPrint("Error cargando usuarios: $e");
      setState(() => _cargando = false);
    }
  }

  ImageProvider? _obtenerAvatar(String usuarioId) {
    final data = usuarioId == widget.publicadorId
        ? _usuarioPublicador
        : _usuarioActual;

    if (data == null) return null;

    final foto = data["fotoPerfil"];
    if (foto != null && foto.isNotEmpty) {
      if (foto.startsWith("assets/")) {
        return AssetImage(foto);
      } else if (foto.startsWith("http")) {
        return NetworkImage(foto);
      }
    }
    return null;
  }

  String _obtenerNombre(String usuarioId) {
    final data = usuarioId == widget.publicadorId
        ? _usuarioPublicador
        : _usuarioActual;

    return data?["nombre"] ?? "Usuario";
  }

  Future<void> _enviarMensaje() async {
    final texto = _mensajeCtrl.text.trim();
    if (texto.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .collection("mensajes")
        .add({
          "emisorId": _auth.currentUser!.uid,
          "texto": texto,
          "fechaEnvio": FieldValue.serverTimestamp(),
          "leido": false,
        });

    _mensajeCtrl.clear();

    // 🔽 Baja automáticamente al último mensaje
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uidActual = _auth.currentUser!.uid;

    final titulo = _cargando
        ? "Cargando..."
        : _reporteData == null
        ? "Chat"
        : widget.tipo == "reporte"
        ? (_reporteData!["nombre"] ?? "Mascota")
        : (_reporteData!["direccion"] ?? "Avistamiento");

    // Avatar del otro usuario en el AppBar
    final otroUsuarioId = uidActual == widget.publicadorId
        ? widget.usuarioId
        : widget.publicadorId;
    final avatarOtroUsuario = _obtenerAvatar(otroUsuarioId);
    final nombreOtroUsuario = _obtenerNombre(otroUsuarioId);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 2,
        titleSpacing: 0,
        title: InkWell(
          onTap: _reporteData == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaDetalleCompleto(
                        data: _reporteData!,
                        tipo: widget.tipo,
                      ),
                    ),
                  );
                },
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: avatarOtroUsuario,
                child: avatarOtroUsuario == null
                    ? const Icon(Icons.person, color: Colors.teal)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreOtroUsuario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.info_outline, color: Colors.white70, size: 22),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 💬 Lista de mensajes
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("chats")
                    .doc(widget.chatId)
                    .collection("mensajes")
                    .orderBy("fechaEnvio", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final mensajes = snapshot.data!.docs;

                  if (mensajes.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aún no hay mensajes 🐾",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: mensajes.length,
                    itemBuilder: (context, i) {
                      final data = mensajes[i].data() as Map<String, dynamic>;
                      final emisorId = data["emisorId"];
                      final esMio = emisorId == uidActual;
                      final avatarEmisor = _obtenerAvatar(emisorId);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: esMio
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Avatar del otro usuario (izquierda)
                            if (!esMio) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.teal.shade50,
                                backgroundImage: avatarEmisor,
                                child: avatarEmisor == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.teal,
                                        size: 18,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],

                            // Burbuja de mensaje
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.65,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: esMio
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF26A69A),
                                            Color(0xFF00796B),
                                          ],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Color(0xFFF5F5F5)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(esMio ? 18 : 4),
                                    bottomRight:
                                        Radius.circular(esMio ? 4 : 18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 3,
                                      offset: const Offset(1, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  data["texto"] ?? "",
                                  style: TextStyle(
                                    color:
                                        esMio ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            // Avatar del usuario actual (derecha)
                            if (esMio) ...[
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.teal.shade50,
                                backgroundImage: avatarEmisor,
                                child: avatarEmisor == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.teal,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // 🧾 Campo de texto + botón enviar (seguro contra notch)
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mensajeCtrl,
                        decoration: InputDecoration(
                          hintText: "Escribe un mensaje...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _enviarMensaje(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _enviarMensaje,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}