import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hora actual inyectable, para poder probar la lógica que depende del
/// tiempo (por ejemplo, la alerta de "sigue dentro").
final relojProvider = Provider<DateTime Function()>((ref) => DateTime.now);
