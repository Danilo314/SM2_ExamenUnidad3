import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:sos_mascotas/vista/reportes/pantalla_detalle_completo.dart';

class PantallaMisReportes extends StatelessWidget {
  const PantallaMisReportes({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Inicia sesión para ver tus reportes.")),
      );
    }

    final reportesRef = FirebaseFirestore.instance
        .collection("reportes_mascotas")
        .where("usuarioId", isEqualTo: uid)
        .orderBy("fechaRegistro", descending: true);

    final avistamientosRef = FirebaseFirestore.instance
        .collection("avistamientos")
        .where("usuarioId", isEqualTo: uid)
        .orderBy("fechaRegistro", descending: true);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            "Mis Reportes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(icon: Icon(Icons.pets), text: "Reportes"),
              Tab(icon: Icon(Icons.visibility), text: "Avistamientos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ListaReportes(stream: reportesRef.snapshots(), tipo: "reporte"),
            _ListaReportes(
              stream: avistamientosRef.snapshots(),
              tipo: "avistamiento",
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaReportes extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final String tipo;

  const _ListaReportes({required this.stream, required this.tipo});

  // 🧾 Crear PDF con diseño bonito y mapa
  Future<File?> _crearPDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    pw.MemoryImage? foto;
    pw.MemoryImage? mapaImagen;

    // Descargar imagen si existe
    if (data["fotos"] != null && (data["fotos"] as List).isNotEmpty) {
      final url = (data["fotos"] as List)[0];
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          foto = pw.MemoryImage(response.bodyBytes);
        }
      } catch (_) {}
    }

    // 🗺️ Obtener imagen del mapa - MÉTODO SIMPLE Y FUNCIONAL
    final latitud = data["latitud"];
    final longitud = data["longitud"];
    
    if (latitud != null && longitud != null) {
      try {
        // Usando OpenStreetMap Tile Server - SIEMPRE FUNCIONA
        // Calcula los tiles necesarios para el zoom 15
        final zoom = 15;
        final x = ((longitud + 180) / 360 * (1 << zoom)).floor();
        final y = ((1 - log(tan(latitud * pi / 180) + 1 / cos(latitud * pi / 180)) / pi) / 2 * (1 << zoom)).floor();
        
        // Descarga el tile del mapa
        final tileUrl = "https://tile.openstreetmap.org/$zoom/$x/$y.png";
        
        print("🗺️ Descargando mapa desde: $tileUrl");
        
        final mapResponse = await http.get(
          Uri.parse(tileUrl),
          headers: {
            'User-Agent': 'SOS Mascotas App/1.0',
          },
        ).timeout(const Duration(seconds: 15));
        
        if (mapResponse.statusCode == 200 && mapResponse.bodyBytes.isNotEmpty) {
          mapaImagen = pw.MemoryImage(mapResponse.bodyBytes);
          print("✅ Mapa descargado exitosamente");
        } else {
          print("❌ Error al descargar mapa: ${mapResponse.statusCode}");
        }
      } catch (e) {
        print("❌ Error al cargar mapa: $e");
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 🔹 Encabezado bonito
                pw.Container(
                  width: double.infinity,
                  padding:
                      const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.teal,
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(8),
                      topRight: pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text("SOS MASCOTAS",
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text("Ficha de Reporte de Mascota",
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.normal)),
                    ],
                  ),
                ),

                // 🔹 Foto
                if (foto != null)
                  pw.Container(
                    alignment: pw.Alignment.center,
                    margin: const pw.EdgeInsets.all(16),
                    child: pw.ClipRRect(
                      horizontalRadius: 12,
                      verticalRadius: 12,
                      child: pw.Image(foto,
                          width: 300, height: 200, fit: pw.BoxFit.cover),
                    ),
                  ),

                // 🔹 Info general
                pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _infoFila("Nombre", data["nombre"]),
                      _infoFila("Tipo", data["tipo"]),
                      _infoFila("Raza", data["raza"]),
                      _infoFila("Dirección", data["direccion"]),
                      _infoFila("Fecha pérdida", data["fechaPerdida"]),
                      _infoFila("Hora", data["horaPerdida"]),
                      _infoFila("Estado", data["estado"] ?? "Perdido"),
                      _infoFila("Recompensa", data["recompensa"] ?? "N/A"),
                      _infoFila("Características", data["caracteristicas"]),
                      if (data["telefono"] != null)
                        _infoFila("Teléfono", data["telefono"]),
                      if (data["email"] != null)
                        _infoFila("Email", data["email"]),
                    ],
                  ),
                ),

                // 🗺️ Mapa de ubicación
                if (mapaImagen != null) ...[
                  pw.SizedBox(height: 12),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                    child: pw.Text(
                      "Ubicación donde se perdió:",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 24),
                    child: pw.ClipRRect(
                      horizontalRadius: 8,
                      verticalRadius: 8,
                      child: pw.Image(
                        mapaImagen,
                        width: 450,
                        height: 200,
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  ),
                ] else if (latitud != null && longitud != null) ...[
                  pw.SizedBox(height: 12),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Ubicación donde se perdió:",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Coordenadas: $latitud, $longitud",
                          style: pw.TextStyle(color: PdfColors.grey800, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],

                pw.Spacer(),

                // 🔹 Línea divisora decorativa
                pw.Divider(color: PdfColors.teal, thickness: 1.2),

                // 🔹 Pie de página
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 10),
                    child: pw.Text(
                      "SOS Mascotas - Unidos por los animales perdidos",
                      style: pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 12,
                          fontStyle: pw.FontStyle.italic),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/${data["nombre"] ?? "mascota"}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // 🔸 Helper para formato de datos
  pw.Widget _infoFila(String titulo, dynamic valor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 130,
            child: pw.Text("$titulo:",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
          ),
          pw.Expanded(
            child: pw.Text(
              valor?.toString().isNotEmpty == true ? valor.toString() : "-",
              style: pw.TextStyle(color: PdfColors.grey800),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 Cambiar estado
  Future<void> _cambiarEstado(BuildContext context, String docId, String estadoActual) async {
    final nuevoEstado = (estadoActual == "Perdido") ? "Encontrado" : "Perdido";

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cambiar estado"),
        content: Text("¿Deseas marcar este reporte como '$nuevoEstado'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Confirmar")),
        ],
      ),
    );

    if (confirmar == true) {
      final collection = tipo == "reporte" ? "reportes_mascotas" : "avistamientos";
      await FirebaseFirestore.instance.collection(collection).doc(docId).update({"estado": nuevoEstado});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Estado cambiado a '$nuevoEstado'."),
        backgroundColor: Colors.green,
      ));
    }
  }

  // ✏️ Editar campos
  void _editar(BuildContext context, Map<String, dynamic> data, String docId) {
    final nombreCtrl = TextEditingController(text: data["nombre"] ?? "");
    final tipoCtrl = TextEditingController(text: data["tipo"] ?? "");
    final razaCtrl = TextEditingController(text: data["raza"] ?? "");
    final direccionCtrl = TextEditingController(text: data["direccion"] ?? "");
    final descripcionCtrl = TextEditingController(text: data["caracteristicas"] ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar reporte"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              const SizedBox(height: 10),
              TextField(controller: tipoCtrl, decoration: const InputDecoration(labelText: "Tipo")),
              const SizedBox(height: 10),
              TextField(controller: razaCtrl, decoration: const InputDecoration(labelText: "Raza")),
              const SizedBox(height: 10),
              TextField(controller: direccionCtrl, decoration: const InputDecoration(labelText: "Dirección")),
              const SizedBox(height: 10),
              TextField(controller: descripcionCtrl, decoration: const InputDecoration(labelText: "Características")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final collection = tipo == "reporte" ? "reportes_mascotas" : "avistamientos";
              await FirebaseFirestore.instance.collection(collection).doc(docId).update({
                "nombre": nombreCtrl.text,
                "tipo": tipoCtrl.text,
                "raza": razaCtrl.text,
                "direccion": direccionCtrl.text,
                "caracteristicas": descripcionCtrl.text,
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Cambios guardados correctamente."),
                backgroundColor: Colors.green,
              ));
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
              child: Text(
                  tipo == "reporte" ? "No has registrado reportes" : "No has registrado avistamientos",
                  style: const TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final id = docs[i].id;
            final fotos = (data["fotos"] ?? []) as List;
            final urlFoto = fotos.isNotEmpty ? fotos.first : (data["foto"] ?? "");
            final nombre = data["nombre"] ?? "Mascota sin nombre";
            final raza = data["raza"] ?? "Sin raza";
            final estado = (data["estado"] ?? "Perdido");
            final colorEstado = estado == "Encontrado" ? Colors.green : Colors.red;
            
            // 🆕 Detalles adicionales
            final direccion = data["direccion"] ?? "";
            final fecha = data["fechaPerdida"] ?? "";
            final hora = data["horaPerdida"] ?? "";

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (urlFoto.isNotEmpty)
                      ? Image.network(urlFoto, width: 60, height: 60, fit: BoxFit.cover)
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.teal.shade50,
                          child: const Icon(Icons.pets, color: Colors.teal),
                        ),
                ),
                title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$raza • Estado: $estado",
                      style: TextStyle(color: colorEstado, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    if (direccion.isNotEmpty)
                      Text(
                        "📍 $direccion",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (fecha.isNotEmpty || hora.isNotEmpty)
                      Text(
                        "🕐 $fecha ${hora.isNotEmpty ? '- $hora' : ''}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) async {
                    if (value == "editar") {
                      _editar(context, data, id);
                    } else if (value == "estado") {
                      _cambiarEstado(context, id, estado);
                    } else if (value == "pdf") {
                      // Mostrar loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                      
                      final file = await _crearPDF(data);
                      Navigator.pop(context); // Cerrar loading
                      
                      if (file != null) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("PDF generado ✅"),
                            content: const Text("¿Qué deseas hacer con el PDF?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  OpenFilex.open(file.path);
                                  Navigator.pop(context);
                                },
                                child: const Text("Ver"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Share.shareXFiles([XFile(file.path)], text: "Ficha PDF de mascota");
                                  Navigator.pop(context);
                                },
                                child: const Text("Compartir"),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: "editar",
                      child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("Editar")]),
                    ),
                    PopupMenuItem(
                      value: "estado",
                      child: Row(children: [Icon(Icons.sync, color: Colors.green), SizedBox(width: 8), Text("Cambiar estado")]),
                    ),
                    PopupMenuItem(
                      value: "pdf",
                      child: Row(children: [Icon(Icons.picture_as_pdf, color: Colors.red), SizedBox(width: 8), Text("Exportar PDF")]),
                    ),
                  ],
                ),
                onTap: () {
                  final dataConId = {...data, "id": id};
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaDetalleCompleto(data: dataConId, tipo: tipo),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}