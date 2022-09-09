import 'package:test/test.dart';
import 'package:triple/src/store.dart';

import 'triple_test.dart';

void main() {
  setTripleResolver(_getInjection);

  test('Resolver injection', () {
    final store = getTripleResolver<TestImplements>();
    expect(store, isA<TestImplements>());
    expect(store.state, 0);
  });
}

T _getInjection<T extends Object>() {
  return _modularSimulation<T>();
}

final _injection = <Type, dynamic>{TestImplements: TestImplements(0)};
T _modularSimulation<T extends Object>() {
  final bind = _injection[T];
  return bind;
}
