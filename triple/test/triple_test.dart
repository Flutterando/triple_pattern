// ignore_for_file: invalid_use_of_protected_member, cascade_invocations, lines_longer_than_80_chars, avoid_print

import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:triple/triple.dart';

void main() {
  late TestImplements<int> store;

  TripleObserver.addListener(print);

  setUp(() {
    store = TestImplements(0);
  });

  test('check implementation. setState', () {
    store.update(1);
    expect(
      store.propagated.toString(),
      Triple<int>(state: 1).toString(),
    );
  });

  test('check implementation. setLoading', () {
    store.setLoading(true);
    expect(
      store.propagated.toString(),
      Triple<int>(
        state: 0,
        isLoading: true,
        event: TripleEvent.loading,
      ).toString(),
    );
  });

  test('check implementation. setError', () {
    store.setError(const MyException('error'));
    expect(
      store.propagated.toString(),
      Triple<int>(
        state: 0,
        error: const MyException('error'),
        event: TripleEvent.error,
      ).toString(),
    );
  });

  test('check implementation. disctinct setState', () {
    store.setError(const MyException('error'));
    final triple = store.propagated;
    store.update(0);
    expect(store.propagated.hashCode, triple.hashCode);
  });

  test('check implementation. disctinct setState with memento', () {
    store.setError(const MyException('error'));
    store.update(0);
    store.update(1);
    store.update(2);
    store.undo();
    expect(store.state, 1);
    store.redo();
    expect(store.state, 2);
    store.undo();
    expect(store.state, 1);
    store.undo();
    expect(store.state, 0);
    store.redo();
    expect(store.state, 1);

    store.update(2);
    expect(store.state, 2);
    store.update(3);
    expect(store.state, 3);
    store.undo();
    expect(store.state, 2);
    store.redo();
    expect(store.state, 3);
    store.redo();
    expect(store.state, 3);
  });
}

// ignore: must_be_immutable
class TestImplements<State extends Object> extends BaseStore<State> with MementoMixin implements Selectors<Stream, Stream<State>, Stream<bool>> {
  TestImplements(State initialState) : super(initialState);

  late Triple<State> propagated = triple;

  @override
  Future destroy() async {}

  @override
  Disposer observer({
    void Function(State state)? onState,
    void Function(bool loading)? onLoading,
    void Function(Error error)? onError,
  }) {
    return () async {};
  }

  @protected
  @override
  void propagate(Triple<State> triple) {
    super.propagate(triple);
    propagated = triple;
  }

  @override
  Stream<Error> get selectError => throw UnimplementedError();

  @override
  Stream<bool> get selectLoading => throw UnimplementedError();

  @override
  Stream<State> get selectState => throw UnimplementedError();
}

class MyException implements Exception {
  final String message;

  const MyException(this.message);
}
