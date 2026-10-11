/// Idiomas en los que está traducida la app.
enum Idioma {
  es('es'),
  en('en');

  const Idioma(this.codigo);

  /// Código ISO 639-1. Es el valor que se guarda en el celular.
  final String codigo;

  static Idioma? deCodigo(String? codigo) {
    for (final idioma in values) {
      if (idioma.codigo == codigo) return idioma;
    }
    return null;
  }
}

/// Apariencia de la app.
enum ModoTema {
  /// Sigue el modo claro u oscuro del celular.
  sistema,
  claro,
  oscuro;

  /// Devuelve [sistema] si el [nombre] guardado no se reconoce.
  static ModoTema deNombre(String? nombre) {
    for (final modo in values) {
      if (modo.name == nombre) return modo;
    }
    return ModoTema.sistema;
  }
}

/// Preferencias de quien usa la app. Son inmutables: cada cambio devuelve
/// una copia nueva.
class Preferencias {
  const Preferencias({this.idioma, this.modoTema = ModoTema.sistema});

  /// Idioma elegido. Si es `null` se usa el idioma del celular (y español
  /// cuando el celular está en un idioma sin traducción).
  final Idioma? idioma;

  final ModoTema modoTema;

  Preferencias conIdioma(Idioma idioma) =>
      Preferencias(idioma: idioma, modoTema: modoTema);

  Preferencias conModoTema(ModoTema modoTema) =>
      Preferencias(idioma: idioma, modoTema: modoTema);

  @override
  bool operator ==(Object other) =>
      other is Preferencias &&
      other.idioma == idioma &&
      other.modoTema == modoTema;

  @override
  int get hashCode => Object.hash(idioma, modoTema);
}
