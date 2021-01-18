import 'dart:async';

import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:triple/triple.dart';

void main() {
  test('custom middleware', () {
    final counter = Counter([]);
    counter.increment();
    expect(counter.state, 3);
  });
}

class Counter extends TestImplements<Exception, int> {
  Counter(List<bool> list) : super(0, list);

  void increment() => update(1);

  @override
  Triple<Exception, int> middleware(Triple<Exception, int> newTriple) {
    if (newTriple.event == TripleEvent.state) {
      return newTriple.copyWith(state: 3);
    } else {
      return newTriple;
    }
  }
}

abstract class TestImplements<Error extends Object, State extends Object> extends Store<Error, State> {
  final List<bool> list;

  TestImplements(State initialState, this.list) : super(initialState);

  late Triple<Error, State> propagated = triple;

  @override
  Future destroy() async {}

  @override
  void setLoading(bool newloading, {bool force = false}) {
    super.setLoading(newloading);
    list.add(newloading);
  }

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
}

class MyException implements Exception {
  final String message;

  const MyException(this.message);
}
