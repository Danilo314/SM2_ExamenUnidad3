import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../modelo/colaborador_model.dart';

class PantallaDetalleColaborador extends StatelessWidget {
  final Colaborador? colaborador;
  final List<String> beneficios;
  final double valoracion; // 0 a 5
  final List<String> testimonios;
  final String ubicacion; // Dirección o descripción

  const PantallaDetalleColaborador({
    super.key,
    this.colaborador,
    this.beneficios = const [],
    this.valoracion = 5.0,
    this.testimonios = const [],
    this.ubicacion = '',
  });

  // Obtener coordenadas según el colaborador
  LatLng _obtenerUbicacion() {
    if (colaborador?.id == '1') {
      return const LatLng(-18.0065, -70.2444);
    } else {
      return const LatLng(-18.0189, -70.2505);
    }
  }

  // Obtener dirección según el colaborador
  String _obtenerDireccion() {
    if (ubicacion.isNotEmpty) return ubicacion;
    if (colaborador?.id == '1') {
      return 'Av. Bolognesi 456, Centro de Tacna';
    } else {
      return 'Calle San Martín 789, Tacna';
    }
  }

  // Obtener información de contacto según el colaborador
  Map<String, String> _obtenerContactos() {
    final contactos = <String, String>{};
    
    if (colaborador?.id == '1') {
      contactos['email'] = 'veterinaria1@hotmail.com';
      contactos['whatsapp'] = '+51987654321';
      contactos['instagram'] = 'veterinaria_tacna';
      contactos['telefono'] = '+51987654321';
    } else {
      contactos['email'] = 'tienda.mascotas@hotmail.com';
      contactos['whatsapp'] = '+51912345678';
      contactos['instagram'] = 'tienda_mascotas_oficial';
      contactos['telefono'] = '+51912345678';
    }
    
    return contactos;
  }

  // Filtrar beneficios (excluir los específicos)
  List<String> _obtenerBeneficiosFiltrados() {
    return beneficios.where((beneficio) {
      final beneficioLower = beneficio.toLowerCase();
      return !beneficioLower.contains('puntos de fidelidad') &&
             !beneficioLower.contains('acceso a eventos');
    }).toList();
  }

  // Obtener imágenes de galería según colaborador y beneficios filtrados
  List<Map<String, String>> _obtenerImagenesGaleria() {
    final imagenes = <Map<String, String>>[];
    final beneficiosFiltrados = _obtenerBeneficiosFiltrados();
    
    // Imágenes disponibles en orden para cada colaborador
    final imagenesColaborador1 = [
      'assets/imagen/imagen1.png',
      'assets/imagen/imagen2.jpeg',
      'assets/imagen/imagen3.webp',
      'assets/imagen/imagen4.jpeg',
      'assets/imagen/imagen5.avif',
      'assets/imagen/imagen6.avif',
    ];
    
    final imagenesColaborador2 = [
      'assets/imagen/imagen7.png',
      'assets/imagen/imagen8.webp',
      'assets/imagen/imagen9.jpg',
      'assets/imagen/imagen10.jpg',
      'assets/imagen/imagen11.jpg',
      'assets/imagen/imagen12.avif',
    ];
    
    if (colaborador?.id == '1') {
      // Veterinaria - Asignar imágenes específicas a cada beneficio
      if (beneficiosFiltrados.isNotEmpty) {
        // Buscar el beneficio "Chequeo gratuito" para asignarle las últimas 3 imágenes
        int chequeoIndex = -1;
        for (int i = 0; i < beneficiosFiltrados.length; i++) {
          if (beneficiosFiltrados[i].toLowerCase().contains('chequeo gratuito')) {
            chequeoIndex = i;
            break;
          }
        }
        
        for (int i = 0; i < beneficiosFiltrados.length; i++) {
          if (i == chequeoIndex) {
            // Chequeo gratuito: imágenes 4, 5, 6
            imagenes.addAll([
              {
                'ruta': imagenesColaborador1[3],
                'titulo': 'Chequeo - Imagen 1',
                'beneficio': beneficiosFiltrados[i],
              },
              {
                'ruta': imagenesColaborador1[4],
                'titulo': 'Chequeo - Imagen 2',
                'beneficio': beneficiosFiltrados[i],
              },
              {
                'ruta': imagenesColaborador1[5],
                'titulo': 'Chequeo - Imagen 3',
                'beneficio': beneficiosFiltrados[i],
              },
            ]);
          } else {
            // Otros beneficios: primeras 3 imágenes
            imagenes.addAll([
              {
                'ruta': imagenesColaborador1[0],
                'titulo': 'Promoción ${i + 1} - Imagen 1',
                'beneficio': beneficiosFiltrados[i],
              },
              {
                'ruta': imagenesColaborador1[1],
                'titulo': 'Promoción ${i + 1} - Imagen 2',
                'beneficio': beneficiosFiltrados[i],
              },
              {
                'ruta': imagenesColaborador1[2],
                'titulo': 'Promoción ${i + 1} - Imagen 3',
                'beneficio': beneficiosFiltrados[i],
              },
            ]);
          }
        }
      }
    } else {
      // Tienda de Mascotas - Asignar imágenes específicas a cada beneficio
      if (beneficiosFiltrados.isNotEmpty) {
        // Buscar índices de beneficios específicos
        int productosIndex = -1;
        int descuentosIndex = -1;
        
        for (int i = 0; i < beneficiosFiltrados.length; i++) {
          final beneficioLower = beneficiosFiltrados[i].toLowerCase();
          if (beneficioLower.contains('productos promocionales')) {
            productosIndex = i;
          } else if (beneficioLower.contains('descuentos en consultas')) {
            descuentosIndex = i;
          }
        }
        
        for (int i = 0; i < beneficiosFiltrados.length; i++) {
          if (i == productosIndex) {
            // Productos promocionales gratis: imágenes 7, 8, 9
            imagenes.addAll([
              {
                'ruta': imagenesColaborador2[0],
                'titulo': 'Producto - Imagen 1',
                'beneficio': beneficiosFiltrados[i],
              },
              {
                'ruta': imagenesColaborador2[1],
                'titulo': 'Producto - Imagen 2',
                'beneficio': beneficiosFiltrados[i],
              },
              {
                'ruta': imagenesColaborador2[2],
                'titulo': 'Producto - Imagen 3',
                'beneficio': beneficiosFiltrados[i],
              },
            ]);
          } else if (i == descuentosIndex) {
            // Descuentos en consultas y servicios: imágenes 10, 11, 12
            imagenes.addAll([
              {
                'ruta': imagenesColaborador2[3],
                'titulo': 'Descuento - Imagen 1',
                'beneficio': beneficiosFiltrados[i],
              },
              {
                'ruta': imagenesColaborador2[4],
                'titulo': 'Descuento - Imagen 2',
                'beneficio': beneficiosFiltrados[i],
              },
              {
                'ruta': imagenesColaborador2[5],
                'titulo': 'Descuento - Imagen 3',
                'beneficio': beneficiosFiltrados[i],
              },
            ]);
          } else {
            // Otros beneficios: rotar entre todas las imágenes
            for (int j = 0; j < 3; j++) {
              final imagenIndex = (i * 3 + j) % imagenesColaborador2.length;
              imagenes.add({
                'ruta': imagenesColaborador2[imagenIndex],
                'titulo': 'Oferta ${i + 1} - Imagen ${j + 1}',
                'beneficio': beneficiosFiltrados[i],
              });
            }
          }
        }
      }
    }
    
    return imagenes;
  }

  // Abrir imagen de galería en pantalla completa
  void _abrirImagenGaleria(BuildContext context, Map<String, String> imagen) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          imagen['titulo'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          imagen['beneficio'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Image.asset(
                    imagen['ruta'] ?? '',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar imagen',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Abrir email
  Future<void> _abrirEmail(String correo) async {
    final Uri uri = Uri(scheme: 'mailto', path: correo);
    if (!await launchUrl(uri)) {
      throw 'No se pudo abrir el correo';
    }
  }

  // Abrir WhatsApp
  Future<void> _abrirWhatsApp(String telefono) async {
    final Uri uri = Uri.parse('https://wa.me/$telefono');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir WhatsApp';
    }
  }

  // Abrir Instagram
  Future<void> _abrirInstagram(String usuario) async {
    final Uri uri = Uri.parse('https://instagram.com/$usuario');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir Instagram';
    }
  }

  // Abrir SMS
  Future<void> _abrirMensajes(String telefono) async {
    final Uri uri = Uri(scheme: 'sms', path: telefono);
    if (!await launchUrl(uri)) {
      throw 'No se pudo abrir mensajes';
    }
  }

  // Abrir teléfono
  Future<void> _abrirTelefono(String telefono) async {
    final Uri uri = Uri(scheme: 'tel', path: telefono);
    if (!await launchUrl(uri)) {
      throw 'No se pudo llamar';
    }
  }

  // Mostrar opciones de contacto
  void _mostrarOpcionesContacto(BuildContext context) {
    final contactos = _obtenerContactos();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona cómo contactar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Email
            if (contactos.containsKey('email'))
              _opcionContacto(
                context,
                icon: Icons.email,
                titulo: 'Email',
                subtitulo: contactos['email']!,
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _abrirEmail(contactos['email']!);
                },
              ),
            
            // WhatsApp
            if (contactos.containsKey('whatsapp'))
              _opcionContacto(
                context,
                icon: Icons.chat,
                titulo: 'WhatsApp',
                subtitulo: contactos['whatsapp']!,
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _abrirWhatsApp(contactos['whatsapp']!);
                },
              ),
            
            // Instagram
            if (contactos.containsKey('instagram'))
              _opcionContacto(
                context,
                icon: Icons.camera_alt,
                titulo: 'Instagram',
                subtitulo: '@${contactos['instagram']!}',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  _abrirInstagram(contactos['instagram']!);
                },
              ),
            
            // Mensajes SMS
            if (contactos.containsKey('telefono'))
              _opcionContacto(
                context,
                icon: Icons.message,
                titulo: 'Mensaje SMS',
                subtitulo: contactos['telefono']!,
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _abrirMensajes(contactos['telefono']!);
                },
              ),
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Widget para cada opción de contacto
  Widget _opcionContacto(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 25,
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  // Abrir imagen principal con efecto Hero
  void _abrirImagen(BuildContext context, String? rutaImagen) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black54,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Hero(
            tag: rutaImagen ?? 'no-imagen',
            child: rutaImagen != null && rutaImagen.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(rutaImagen, fit: BoxFit.contain),
                  )
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.business, size: 80, color: Colors.teal),
                  ),
          ),
        ),
      ),
    );
  }

  // Abrir mapa en pantalla completa
  void _abrirMapaCompleto(BuildContext context, LatLng ubicacion, String nombre, String direccion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: Text(nombre),
            actions: [
              IconButton(
                icon: const Icon(Icons.directions),
                tooltip: 'Abrir en Google Maps',
                onPressed: () async {
                  final url = 'https://www.google.com/maps/search/?api=1&query=${ubicacion.latitude},${ubicacion.longitude}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: ubicacion,
                  initialZoom: 16.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.sos_mascotas',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: ubicacion,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.place, color: Colors.deepOrange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                direccion,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para mostrar estrellas de valoración
  Widget _buildValoracion(double valor) {
    int completos = valor.floor();
    bool mitad = (valor - completos) >= 0.5;
    return Row(
      children: List.generate(5, (index) {
        if (index < completos) return const Icon(Icons.star, color: Colors.amber, size: 22);
        if (index == completos && mitad) return const Icon(Icons.star_half, color: Colors.amber, size: 22);
        return const Icon(Icons.star_border, color: Colors.amber, size: 22);
      }),
    );
  }

  // Tarjeta estilizada con gradiente y sombra
  Widget _tarjeta(String texto, IconData icon,
      {Color start = Colors.teal, Color end = Colors.tealAccent}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start.withOpacity(0.4), end.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: start.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: start, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir la galería de imágenes
  Widget _buildGaleria(BuildContext context) {
    final imagenes = _obtenerImagenesGaleria();
    final beneficiosFiltrados = _obtenerBeneficiosFiltrados();
    
    if (imagenes.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text("No hay imágenes aún", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: [
        // Grid de imágenes con agrupación por beneficio
        for (int i = 0; i < beneficiosFiltrados.length; i++) ...[
          // Título del beneficio
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.withOpacity(0.3), Colors.purpleAccent.withOpacity(0.1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    beneficiosFiltrados[i],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 3 imágenes por beneficio
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              final imagenIndex = i * 3 + index;
              if (imagenIndex >= imagenes.length) return const SizedBox();
              
              final imagen = imagenes[imagenIndex];
              return GestureDetector(
                onTap: () => _abrirImagenGaleria(context, imagen),
                child: Hero(
                  tag: 'galeria_${imagen['ruta']}_$imagenIndex',
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Imagen real
                          Image.asset(
                            imagen['ruta'] ?? '',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Indicador de zoom
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (i < beneficiosFiltrados.length - 1) const SizedBox(height: 20),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colab = colaborador;
    if (colab == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Colaborador"), backgroundColor: Colors.deepPurple),
        body: const Center(child: Text("No se encontró información del colaborador")),
      );
    }

    // Horarios distintos según colaborador
    final horarioTexto = colab.id == '1'
        ? "08:00 a.m. - 20:00 p.m. = No atienden domingos y feriados"
        : "09:00 a.m. - 21:00 p.m. = No atienden sábados y domingos";

    // Posición del colaborador según su ID
    final ubicacionMapa = _obtenerUbicacion();
    final direccionCompleta = _obtenerDireccion();
    final contactos = _obtenerContactos();
    final beneficiosFiltrados = _obtenerBeneficiosFiltrados();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          colab.nombre,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _abrirTelefono(contactos['telefono'] ?? ''),
        icon: const Icon(Icons.phone),
        label: const Text("Llamar"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            GestureDetector(
              onTap: () => _abrirImagen(context, colab.logo),
              child: Hero(
                tag: colab.logo.isNotEmpty ? colab.logo : 'no-imagen',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: colab.logo.isNotEmpty
                      ? Image.asset(
                          colab.logo,
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 240,
                          color: Colors.teal.shade100,
                          child: const Center(
                            child: Icon(Icons.business, size: 100, color: Colors.teal),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre, tipo y valoración
            Row(
              children: [
                Expanded(
                  child: Text(
                    colab.nombre,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(colab.tipo),
                  backgroundColor: Colors.orange.shade200,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildValoracion(valoracion),
            const SizedBox(height: 16),

            // Descripción
            Text(
              colab.descripcion,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),

            // Beneficios filtrados
            if (beneficiosFiltrados.isNotEmpty) ...[
              const Text("Beneficios / Recompensas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              ...beneficiosFiltrados.map(
                (b) => _tarjeta(b, Icons.card_giftcard,
                    start: Colors.purple, end: Colors.purpleAccent),
              ),
              const SizedBox(height: 24),
            ],

            // Horario dinámico
            const Text("Horario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text(horarioTexto),
            const SizedBox(height: 24),

            // Ubicación
            const Text("Ubicación", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _tarjeta(direccionCompleta, Icons.place, start: Colors.deepOrange, end: Colors.orangeAccent),
            const SizedBox(height: 24),

            // Galería con imágenes por beneficio (solo los filtrados)
            if (beneficiosFiltrados.isNotEmpty) ...[
              const Text("Galería", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 6),
              const Text(
                "Estamos promocionando estos productos y puedes ganarte cupones dependiendo de las promociones o recompensas disponibles.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              _buildGaleria(context),
              const SizedBox(height: 24),
            ],

            // Mapa con FlutterMap
            const Text("Mapa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            const Text(
              "Nos puedes encontrar en este punto / sitio.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: ubicacionMapa,
                        initialZoom: 15.0,
                        minZoom: 5.0,
                        maxZoom: 18.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.sos_mascotas',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: ubicacionMapa,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton.small(
                    heroTag: 'expandir_mapa',
                    backgroundColor: Colors.white,
                    elevation: 4,
                    onPressed: () => _abrirMapaCompleto(context, ubicacionMapa, colab.nombre, direccionCompleta),
                    child: const Icon(Icons.fullscreen, color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Testimonios
            if (testimonios.isNotEmpty) ...[
              const Text("Testimonios",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              ...testimonios.map((t) => _tarjeta(t, Icons.person,
                  start: Colors.teal, end: Colors.tealAccent)),
            ],

            // Contacto con opciones múltiples
            const SizedBox(height: 24),
            const Text("Contacto",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Card(
              elevation: 5,
              shadowColor: Colors.deepPurple.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.2),
                  child: const Icon(Icons.contacts, color: Colors.deepPurple),
                ),
                title: const Text('Contactar'),
                subtitle: const Text('Elige tu método de contacto preferido'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _mostrarOpcionesContacto(context),
                  child: const Text(
                    "Contactar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text("Horario de llamadas / conversación",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              colab.id == '1'
                  ? "12:00 a.m. - 14:00 p.m. "
                  : "13:00 a.m. - 15:00 p.m. ",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}