// ignore_for_file: lines_longer_than_80_chars

import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:triple/triple.dart';
import 'package:triple_test/src/store_mock.dart';
import 'package:triple_test/src/store_test.dart';
import 'package:triple_test/src/store_when.dart';

class TestImplementsMock extends MockStore<MyException, int>
    implements TestImplements<MyException, int> {}

void main() async {
  TestImplementsMock _mountMock() {
    final mock = TestImplementsMock();
    whenObserve<MyException, int>(
      mock,
      input: mock.testAdd,
      initialState: 0,
      triples: [
        Triple(state: 1),
        Triple(isLoading: true, event: TripleEvent.loading, state: 1),
        Triple(state: 2),
      ],
    );
    return mock;
  }

  storeTest<TestImplementsMock>(
    'Teste triple',
    build: _mountMock,
    act: (store) => store.testAdd(),
    expect: () => [isA<int>(), tripleLoading, 2],
  );

  storeTest<TestImplementsMock>(
    'Teste triple initital 0',
    build: _mountMock,
    expect: () => 0,
    verify: (store) {
      verifyNever(() => store.testAdd()).called(0);
    },
  );

  group('TripleMatcher', () {
    test('State ', () {
      expect(Triple(state: 0), tripleState);
    });
    test('error ', () {
      expect(Triple(state: 0, event: TripleEvent.error), tripleError);
    });
    test('Loading', () {
      expect(Triple(state: 0, event: TripleEvent.loading), tripleLoading);
    });
  });
}

// ignore: must_be_immutable
class TestImplements<Error extends Object, State extends Object> extends Store<Error, State>
    with MementoMixin
    implements Selectors<Stream<Error>, Stream<State>, Stream<bool>> {
  TestImplements(State initialState) : super(initialState);

  late Triple<Error, State> propagated = triple;

  void functionVerify() {}

  void testAdd() {}

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
  void propagate(Triple<Error, State> triple) {
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
