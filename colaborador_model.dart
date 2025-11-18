class Colaborador {
  final String id;
  final String nombre;
  final String descripcion;
  final String logo; // url de imagen o asset
  final String tipo; // veterinaria, patrocinador, etc.
  final String contacto; // email o teléfono
  final List<String> galeria; // imágenes adicionales opcionales
  final String? horario; // opcional, horario específico de este colaborador
  final List<String> diasNoAtiende; // opcional

  Colaborador({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.logo,
    required this.tipo,
    required this.contacto,
    this.galeria = const [],
    this.horario,
    this.diasNoAtiende = const [],
  });

  // Crear desde un Map (por ejemplo, Firestore)
  factory Colaborador.fromMap(Map<String, dynamic> map, String id) {
    return Colaborador(
      id: id,
      nombre: map['nombre'] ?? 'Sin nombre',
      descripcion: map['descripcion'] ?? '',
      logo: map['logo'] ?? '',
      tipo: map['tipo'] ?? '',
      contacto: map['contacto'] ?? '',
      galeria: List<String>.from(map['galeria'] ?? []),
      horario: map['horario'],
      diasNoAtiende: List<String>.from(map['diasNoAtiende'] ?? []),
    );
  }

  // Convertir a Map (por ejemplo, para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'logo': logo,
      'tipo': tipo,
      'contacto': contacto,
      'galeria': galeria,
      'horario': horario,
      'diasNoAtiende': diasNoAtiende,
    };
  }
}
