import '../../features/explorar/domain/espacio.dart';
import '../../features/reportes/domain/reporte_diario.dart';
import '../../features/visitas/domain/visita.dart';
import '../../l10n/app_localizations.dart';

// Texto visible de cada valor del dominio, en el idioma de la app.
//
// El dominio no guarda textos de interfaz: aquí se traduce cada `enum`.
// Al agregar un valor nuevo, el `switch` deja de compilar hasta traducirlo.

extension TextoTipoServicio on TipoServicio {
  String texto(AppLocalizations l10n) => switch (this) {
    TipoServicio.guiado => l10n.tipoGuiado,
    TipoServicio.alimentacion => l10n.tipoAlimentacion,
    TipoServicio.hospedaje => l10n.tipoHospedaje,
    TipoServicio.transporte => l10n.tipoTransporte,
  };
}

extension TextoProcedencia on Procedencia {
  String texto(AppLocalizations l10n) => switch (this) {
    Procedencia.piura => l10n.procedenciaPiura,
    Procedencia.lima => l10n.procedenciaLima,
    Procedencia.otraRegion => l10n.procedenciaOtraRegion,
    Procedencia.extranjero => l10n.procedenciaExtranjero,
  };
}

extension TextoActividad on Actividad {
  String texto(AppLocalizations l10n) => switch (this) {
    Actividad.senderismo => l10n.actividadSenderismo,
    Actividad.aves => l10n.actividadAves,
    Actividad.fotografia => l10n.actividadFotografia,
    Actividad.campamento => l10n.actividadCampamento,
  };
}

extension TextoRangoEdad on RangoEdad {
  String texto(AppLocalizations l10n) => switch (this) {
    RangoEdad.menores => l10n.edadMenores,
    RangoEdad.de18a29 => l10n.edad18a29,
    RangoEdad.de30a44 => l10n.edad30a44,
    RangoEdad.de45a59 => l10n.edad45a59,
    RangoEdad.mayores => l10n.edadMayores,
  };
}
