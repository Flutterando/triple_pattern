import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:triple/triple.dart';

void main() {
  group('Futures | ', () {
    test('exec', () async {
      final listLoading = <bool>[];
      final counter = Counter(listLoading);
      await counter.increment();
      await counter.increment();
      await counter.increment();
      expect(counter.state, 3);
      expect(listLoading, [true, false, true, false, true, false]);
      await counter.increment();
    });

    test('Switch exec', () async {
      final listLoading = <bool>[];
      final counter = Counter(listLoading);
      counter.increment();
      counter.increment();
      counter.increment();
      await Future.delayed(Duration(seconds: 5));
      expect(counter.state, 1);
      expect(listLoading, [true, false]);
    });
  });

  group('Either | ', () {
    test('exec', () async {
      final listLoading = <bool>[];
      final counter = Counter(listLoading);
      await counter.incrementEither();
      await counter.incrementEither();
      await counter.incrementEither();
      expect(counter.state, 3);
      expect(listLoading, [true, false, true, false, true, false]);
    });

    test('Switch exec', () async {
      final listLoading = <bool>[];
      final counter = Counter(listLoading);
      counter.incrementEither();
      counter.incrementEither();
      counter.incrementEither();
      await Future.delayed(Duration(seconds: 5));
      expect(counter.state, 1);
      expect(listLoading, [true, false]);
    });
  });
}

class Counter extends TestImplements<Exception, int> {
  Counter(List<bool> list) : super(0, list);

  FutureOr<void> increment() => execute(() => Future.delayed(Duration(seconds: 1)).then((value) {
        if (state < 3) {
          return state + 1;
        } else {
          throw 'Error';
        }
      }));
  FutureOr<void> incrementEither() => executeEither(() => Future.delayed(Duration(seconds: 2)).then((value) => Right(state + 1)));
}

abstract class TestImplements<Error extends Object, State extends Object> extends Store<Error, State> {
  final List<bool> list;

  TestImplements(State initialState, this.list) : super(initialState);

  late Triple<Error, State> propagated = triple;

  @override
  Future destroy() async {}

  @override
  void setLoading(bool newloading) {
    super.setLoading(newloading);
    list.add(newloading);
  }

  @override
  void update(State newState) {
    super.update(newState);
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
