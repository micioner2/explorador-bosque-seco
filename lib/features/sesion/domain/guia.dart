/// Guía autorizado de una asociación. Al entrar al puesto de control elige
/// su nombre, y las visitas que registra quedan a su nombre.
class Guia {
  Guia({required this.id, required this.asociacionId, required String nombre})
    : nombre = nombre.trim() {
    if (this.nombre.isEmpty) {
      throw ArgumentError.value(nombre, 'nombre', 'No puede estar vacío');
    }
  }

  final String id;
  final String asociacionId;
  final String nombre;

  @override
  bool operator ==(Object other) =>
      other is Guia &&
      other.id == id &&
      other.asociacionId == asociacionId &&
      other.nombre == nombre;

  @override
  int get hashCode => Object.hash(id, asociacionId, nombre);
}
