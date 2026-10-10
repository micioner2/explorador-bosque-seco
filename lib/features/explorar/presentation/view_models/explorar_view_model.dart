import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/espacio_repository_demo.dart';
import '../../domain/espacio.dart';

/// Estado de la pantalla Explorar: el espacio que el turista descargó.
final explorarViewModelProvider = Provider<Espacio>(
  (ref) => ref.watch(espacioRepositoryProvider).espacioActual(),
);
