/// Lo que el celular sabe de su conexión y de lo que falta enviar al
/// servidor. Se muestra siempre (regla offline-first): la persona sabe que
/// lo registrado está a salvo aunque no haya señal.
sealed class EstadoSincronizacion {
  const EstadoSincronizacion();

  /// [hayRed] es `null` mientras el celular aún no responde: se asume que
  /// no hay señal, lo más prudente en el bosque.
  factory EstadoSincronizacion.calcular({
    required bool? hayRed,
    required int pendientes,
  }) {
    if (hayRed != true) return SinSenal(pendientes);
    if (pendientes > 0) return ConSenal(pendientes);
    return const TodoSincronizado();
  }
}

/// Sin señal: todo queda guardado en el celular.
final class SinSenal extends EstadoSincronizacion {
  const SinSenal(this.pendientes);

  final int pendientes;
}

/// Hay señal y quedan registros por enviar.
final class ConSenal extends EstadoSincronizacion {
  const ConSenal(this.pendientes);

  final int pendientes;
}

/// Hay señal y no queda nada por enviar.
final class TodoSincronizado extends EstadoSincronizacion {
  const TodoSincronizado();
}
