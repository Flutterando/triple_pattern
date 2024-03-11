// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:triple/triple.dart';

void main() {
  test('custom middleware', () {
    final counter = Counter(
      const [],
    );
    counter.increment();
    expect(counter.state, 3);
  });
}

// ignore: must_be_immutable
class Counter extends TestImplements<int> {
  Counter(List<bool> list) : super(0, list);

  void increment() => update(1);

  @override
  Triple<int> middleware(Triple<int> newTriple) {
    if (newTriple.event == TripleEvent.state) {
      return newTriple.copyWith(state: 3);
    } else {
      return newTriple;
    }
  }
}

// ignore: must_be_immutable
abstract class TestImplements<State> extends BaseStore<State> {
  final List<bool> list;

  TestImplements(State initialState, this.list) : super(initialState);

  late Triple<State> propagated = triple;

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
  void propagate(Triple<State> triple) {
    super.propagate(triple);
    propagated = triple;
  }
}

class MyException implements Exception {
  final String message;

  const MyException(this.message);
}
