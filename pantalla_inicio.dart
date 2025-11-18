import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vistamodelo/notificacion/notificacion_vm.dart';
import 'package:sos_mascotas/vista/chat/pantalla_chats_activos.dart';
import 'package:sos_mascotas/vistamodelo/colaborador_viewmodel.dart';
import 'package:sos_mascotas/modelo/colaborador_model.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _currentIndex = 0;
  bool _modoOscuro = false;
  final ColaboradorViewModel colaboradorViewModel = ColaboradorViewModel();

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final bool esWeb = kIsWeb && ancho > 900;

    // 👇 Si es Web, mostramos diseño adaptado tipo dashboard
    if (esWeb) {
      return _buildWebLayout(context);
    }

    // 👇 Si no, se mantiene tu diseño móvil original
    return _buildMobileLayout(context);
  }

  // ---------------------- 💻 NUEVO DISEÑO WEB MODERNO ----------------------
  Widget _buildWebLayout(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: Row(
        children: [
          // 🌈 Menú lateral con efecto moderno
          Container(
            width: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _modoOscuro
                    ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
                    : [const Color(0xFF009688), const Color(0xFF00695C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.pets, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        "SOS Mascota",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _menuItem(Icons.home, "Inicio", () {}),
                _menuItem(
                  Icons.add_circle,
                  "Reportar Mascota",
                  () => Navigator.pushNamed(context, "/reportarMascota"),
                ),
                _menuItem(
                  Icons.visibility,
                  "Registrar Avistamiento",
                  () => Navigator.pushNamed(context, "/avistamiento"),
                ),
                _menuItem(
                  Icons.map,
                  "Mapa Interactivo",
                  () => Navigator.pushNamed(context, "/mapa"),
                ),
                _menuItem(Icons.chat, "Chats", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PantallaChatsActivos(),
                    ),
                  );
                }),
                const Spacer(),
                const Divider(color: Colors.white38),
                _menuItem(
                  Icons.person,
                  "Perfil",
                  () => Navigator.pushNamed(context, "/perfil"),
                ),
                _menuItem(
                  Icons.comment,
                  "Comentarios",
                  () => Navigator.pushNamed(context, "/comentarios"),
                ),
                _menuItem(
                  Icons.business,
                  "Colaboradores",
                  () => Navigator.pushNamed(context, "/colaboradores"),
                ),
                _menuItem(Icons.exit_to_app, "Cerrar sesión", () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
                      (_) => false,
                    );
                  }
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 🌤 Contenido principal con encabezado superior
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _modoOscuro
                      ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                      : [const Color(0xFFF5F7FA), const Color(0xFFEFF1F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // 🔹 Encabezado superior con nombre y foto
                  Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("usuarios")
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final data =
                                snapshot.data?.data()
                                    as Map<String, dynamic>? ??
                                {};
                            final nombreCompleto = data["nombre"] ?? "Usuario";
                            
                            // Extraer solo el primer nombre
                            final palabras = nombreCompleto.toString().trim().split(' ');
                            String primerNombre = palabras.isNotEmpty ? palabras[0] : "Usuario";
                            
                            return Text(
                              "¡Hola, ${primerNombre.toUpperCase()}!",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _modoOscuro ? Colors.white : const Color(0xFF333333),
                              ),
                            );
                          },
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.teal.shade100,
                          child: const Icon(Icons.person, color: Colors.teal),
                        ),
                      ],
                    ),
                  ),

                  // 🌟 Contenido principal
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Acciones rápidas",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _modoOscuro ? Colors.white : const Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _modernActionCard(
                                Icons.add_circle,
                                "Reportar Mascota",
                                Colors.purple,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  "/reportarMascota",
                                ),
                              ),
                              _modernActionCard(
                                Icons.visibility,
                                "Registrar Avistamiento",
                                Colors.orange,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  "/avistamiento",
                                ),
                              ),
                              _modernActionCard(
                                Icons.map,
                                "Mapa Interactivo",
                                Colors.teal,
                                onTap: () =>
                                    Navigator.pushNamed(context, "/mapa"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Tarjeta moderna con sombra y efecto hover
  Widget _modernActionCard(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 350,
          height: 120,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- 📱 DISEÑO MÓVIL ----------------------
  Widget _buildMobileLayout(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _modoOscuro ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _modoOscuro ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("usuarios")
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Cargando...");
            }
            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final nombreCompleto = data["nombre"] ?? "Usuario";
            final fotoPerfil = data["fotoPerfil"];
            
            // Extraer solo el primer nombre
            final palabras = nombreCompleto.toString().trim().split(' ');
            String primerNombre = palabras.isNotEmpty ? palabras[0] : "Usuario";
            
            return Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/perfil"),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        (fotoPerfil != null && fotoPerfil.toString().isNotEmpty)
                        ? (fotoPerfil.toString().startsWith("assets/")
                              ? AssetImage(fotoPerfil) as ImageProvider
                              : NetworkImage(fotoPerfil))
                        : null,
                    child: (fotoPerfil == null || fotoPerfil.toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.teal)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¡Hola, $primerNombre!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _modoOscuro ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Ayudemos a encontrar mascotas",
                      style: TextStyle(
                        fontSize: 12,
                        color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          Consumer<NotificacionVM>(
            builder: (context, vm, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.teal),
                    onPressed: () async {
                      Navigator.pushNamed(context, "/notificaciones");
                      await vm.marcarTodasComoLeidas();
                    },
                  ),
                  if (vm.noLeidas > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${vm.noLeidas}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: TextStyle(color: _modoOscuro ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Buscar mascotas perdidas...",
                hintStyle: TextStyle(
                  color: _modoOscuro ? Colors.grey.shade500 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
                ),
                filled: true,
                fillColor: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Acciones Rápidas",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    Icons.add_circle,
                    "Reportar Mascota",
                    Colors.purple,
                    onTap: () =>
                        Navigator.pushNamed(context, "/reportarMascota"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    Icons.visibility,
                    "Registrar Avistamiento",
                    Colors.orange,
                    onTap: () => Navigator.pushNamed(context, "/avistamiento"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    Icons.map,
                    "Mapa Interactivo",
                    Colors.teal,
                    onTap: () => Navigator.pushNamed(context, "/mapa"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Menú Principal",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildMenuItem(
              Icons.pets,
              "Ver Mascotas Reportadas",
              "Explora todos los reportes",
              onTap: () => Navigator.pushNamed(context, "/verReportes"),
            ),
            _buildMenuItem(
              Icons.assignment,
              "Mis Reportes",
              "Gestiona tus publicaciones",
              onTap: () => Navigator.pushNamed(context, "/misReportes"),
            ),
            _buildMenuItem(
              Icons.chat,
              "Chats",
              "Conversaciones activas",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaChatsActivos()),
              ),
            ),
            _buildMenuItem(
              Icons.person,
              "Mi Perfil",
              "Configuración de cuenta",
              onTap: () => Navigator.pushNamed(context, "/perfil"),
            ),
            _buildMenuItem(
              Icons.comment,
              "Comentarios",
              "Lee y comparte experiencias",
              onTap: () => Navigator.pushNamed(context, "/comentarios"),
            ),
            _buildMenuItem(
              Icons.business,
              "Colaboradores",
              "Nuestros aliados y patrocinadores",
              onTap: () => Navigator.pushNamed(context, "/colaboradores"),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Colaborador>>(
              stream: colaboradorViewModel.streamColaboradores(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final colaboradores = snapshot.data!;

                final colaboradoresPreview = colaboradores.take(3).toList();

                return Column(
                  children: colaboradoresPreview.map((col) {
                    return Card(
                      color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: col.logo.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  col.logo,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.business,
                                        size: 50, color: Colors.teal);
                                  },
                                ),
                              )
                            : const Icon(Icons.business,
                                size: 50, color: Colors.teal),
                        title: Text(
                          col.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _modoOscuro ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          col.descripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                        trailing: Chip(
                          label: Text(
                            col.tipo,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.teal.shade100,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, "/colaboradores");
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildMenuItem(
              Icons.exit_to_app,
              "Cerrar Sesión",
              "Salir de tu cuenta actual",
              onTap: () async {
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
                    title: Text(
                      "Cerrar Sesión",
                      style: TextStyle(color: _modoOscuro ? Colors.white : Colors.black),
                    ),
                    content: Text(
                      "¿Deseas cerrar sesión?",
                      style: TextStyle(color: _modoOscuro ? Colors.white70 : Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Cerrar Sesión"),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
                      (_) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: _modoOscuro ? const Color(0xFF1E1E1E) : Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Si toca el icono de tema (índice 1) => alternar modo oscuro
          if (index == 1) {
            setState(() {
              _modoOscuro = !_modoOscuro;
            });
            return;
          }

          // Si toca Mapa (índice 3) => abrir mapa
          if (index == 3) {
            Navigator.pushNamed(context, "/mapa");
            return;
          }

          // Si toca Perfil (índice 4) => abrir perfil
          if (index == 4) {
            Navigator.pushNamed(context, "/perfil");
            return;
          }

          // Para otros índices solo actualizar estado
          setState(() => _currentIndex = index);
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(
                painter: PawPainter(modoOscuro: _modoOscuro),
              ),
            ),
            label: "Tema",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.add), label: "Reportar"),
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Card(
      color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _modoOscuro ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

// 🐾 CUSTOM PAINTER PARA DIBUJAR LA HUELLA DE PERRO
class PawPainter extends CustomPainter {
  final bool modoOscuro;

  PawPainter({required this.modoOscuro});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Dibujar la almohadilla principal (mitad blanca, mitad negra)
    final mainPadPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.7,
        size.width * 0.3,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.3,
        size.width * 0.7,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.9,
      )
      ..close();

    // Mitad izquierda (blanca en modo oscuro, negra en modo claro)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height));
    paint.color = modoOscuro ? Colors.white : Colors.black;
    canvas.drawPath(mainPadPath, paint);
    canvas.restore();

    // Mitad derecha (negra en modo oscuro, blanca en modo claro)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(size.width * 0.5, 0, size.width * 0.5, size.height));
    paint.color = modoOscuro ? Colors.black : Colors.white;
    canvas.drawPath(mainPadPath, paint);
    canvas.restore();

    // Dibujar los 4 deditos superiores
    final toes = [
      Offset(size.width * 0.25, size.height * 0.2), // Dedo izquierdo
      Offset(size.width * 0.4, size.height * 0.1), // Dedo centro-izquierdo
      Offset(size.width * 0.6, size.height * 0.1), // Dedo centro-derecho
      Offset(size.width * 0.75, size.height * 0.2), // Dedo derecho
    ];

    for (var toe in toes) {
      // Determinar color según la posición
      paint.color = toe.dx < size.width * 0.5
          ? (modoOscuro ? Colors.white : Colors.black)
          : (modoOscuro ? Colors.black : Colors.white);
      canvas.drawOval(
        Rect.fromCenter(
          center: toe,
          width: size.width * 0.15,
          height: size.height * 0.12,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PawPainter oldDelegate) => oldDelegate.modoOscuro != modoOscuro;
}