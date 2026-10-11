import 'package:explorador_bosque_seco/core/id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('genera un UUID versión 4', () {
    expect(
      nuevoId(),
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test('no repite ids', () {
    final ids = {for (var i = 0; i < 1000; i++) nuevoId()};

    expect(ids, hasLength(1000));
  });
}
