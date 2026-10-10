import 'visita.dart';

/// Contrato de acceso a las visitas registradas en el puesto de control.
abstract interface class VisitasRepository {
  List<Visita> visitasDelDia(DateTime dia);
}
