import 'package:flutter/material.dart';
import '../../modelo/colaborador_model.dart';
import '../../vistamodelo/colaborador_viewmodel.dart';
import 'pantalla_detalle_colaborador.dart';

class PantallaColaboradores extends StatelessWidget {
  final ColaboradorViewModel viewModel = ColaboradorViewModel();

  PantallaColaboradores({super.key});

  final List<Colaborador> colaboradoresEjemplo = [
    Colaborador(
      id: '1',
      nombre: 'Veterinaria AnimalCare',
      descripcion: 'Atendemos a tus mascotas con el mejor cuidado veterinario.',
      logo: 'assets/imagen/ANIMALCARE.jpeg',
      tipo: 'Veterinaria',
      contacto: 'veterinaria@animalcare.com',
    ),
    Colaborador(
      id: '2',
      nombre: 'Hospital PetsLife',
      descripcion: 'Empresa líder en productos para mascotas y bienestar animal.',
      logo: 'assets/imagen/HOSPITAL.jpeg',
      tipo: 'Patrocinador',
      contacto: 'info@petslife.com',
    ),
  ];

  final Map<String, List<String>> recompensas = {
    '1': [
      '10% de descuento en productos veterinarios',
      'Chequeo gratuito de tu mascota',
      'Puntos de fidelidad por reportes realizados',
    ],
    '2': [
      'Productos promocionales gratis',
      'Acceso a eventos especiales',
      'Descuentos en consultas y servicios',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Colaboradores"),
        backgroundColor: Colors.deepPurple.shade600,
        elevation: 0,
      ),
      body: StreamBuilder<List<Colaborador>>(
        stream: viewModel.streamColaboradores(),
        builder: (context, snapshot) {
          List<Colaborador> colaboradores = snapshot.hasData && snapshot.data!.isNotEmpty
              ? snapshot.data!
              : colaboradoresEjemplo;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: colaboradores.length,
            itemBuilder: (context, index) {
              final col = colaboradores[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaDetalleColaborador(
                        colaborador: col,
                        beneficios: recompensas[col.id] ?? [],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade300, Colors.purple.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Imagen más pequeña
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: col.logo.isNotEmpty
                            ? Image.asset(
                                col.logo,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 100,
                                color: Colors.purple.shade300,
                                child: const Icon(Icons.business, size: 40, color: Colors.white),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              col.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade400,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                col.tipo,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              col.descripcion,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.contact_mail, size: 14),
                              label: const Text(
                                "Contactar",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}