import '../../mapa/domain/coordenada.dart';

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

/// Ruta que muestra la app: la del bosque o una corta alrededor de la sede
/// de la presentación, para que el jurado vea el GPS sobre la ruta.
enum RutaDemo {
  angolo,
  sede;

  /// Devuelve [angolo] si el [nombre] guardado no se reconoce.
  static RutaDemo deNombre(String? nombre) {
    for (final ruta in values) {
      if (ruta.name == nombre) return ruta;
    }
    return RutaDemo.angolo;
  }
}

/// Preferencias de quien usa la app. Son inmutables: cada cambio devuelve
/// una copia nueva.
class Preferencias {
  const Preferencias({
    this.idioma,
    this.modoTema = ModoTema.sistema,
    this.rutaDemo = RutaDemo.angolo,
    this.centroSede,
  });

  /// Idioma elegido. Si es `null` se usa el idioma del celular (y español
  /// cuando el celular está en un idioma sin traducción).
  final Idioma? idioma;

  final ModoTema modoTema;
  final RutaDemo rutaDemo;

  /// Centro de la ruta de la sede tomado con el GPS en el lugar de la demo.
  /// `null` = el centro que trae la app.
  final Coordenada? centroSede;

  Preferencias _con({
    Idioma? idioma,
    ModoTema? modoTema,
    RutaDemo? rutaDemo,
    Coordenada? centroSede,
  }) => Preferencias(
    idioma: idioma ?? this.idioma,
    modoTema: modoTema ?? this.modoTema,
    rutaDemo: rutaDemo ?? this.rutaDemo,
    centroSede: centroSede ?? this.centroSede,
  );

  Preferencias conIdioma(Idioma idioma) => _con(idioma: idioma);

  Preferencias conModoTema(ModoTema modoTema) => _con(modoTema: modoTema);

  Preferencias conRutaDemo(RutaDemo rutaDemo) => _con(rutaDemo: rutaDemo);

  /// La ruta de la sede se arma alrededor de [centro] y pasa a mostrarse.
  Preferencias conCentroSede(Coordenada centro) =>
      _con(rutaDemo: RutaDemo.sede, centroSede: centro);

  @override
  bool operator ==(Object other) =>
      other is Preferencias &&
      other.idioma == idioma &&
      other.modoTema == modoTema &&
      other.rutaDemo == rutaDemo &&
      other.centroSede == centroSede;

  @override
  int get hashCode => Object.hash(idioma, modoTema, rutaDemo, centroSede);
}
