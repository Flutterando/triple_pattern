import 'dart:async';

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

  // group('Either | ', () {
  //   test('Either exec', () async {
  //     final listLoading = <bool>[];
  //     final counter = Counter(listLoading);
  //     await counter.incrementEither();
  //     await counter.incrementEither();
  //     await counter.incrementEither();
  //     expect(counter.state, 3);
  //     expect(listLoading, [true, false, true, false, true, false]);
  //   });

  //   test('Either  exec with switch', () async {
  //     final listLoading = <bool>[];
  //     final counter = Counter(listLoading);
  //     counter.incrementEither();
  //     counter.incrementEither();
  //     counter.incrementEither();
  //     await Future.delayed(Duration(seconds: 5));
  //     expect(counter.state, 1);
  //     expect(listLoading, [true, false]);
  //   });
  // });
}

// ignore: must_be_immutable
class Counter extends TestImplements<Exception, int> {
  Counter(List<bool> list) : super(0, list);

  FutureOr<void> increment() => execute(() {
        return Future.delayed(Duration(seconds: 1)).then((value) {
          return state + 1;
        });
      }, delay: const Duration(milliseconds: 500));

  FutureOr<void> incrementWithError() => execute(() => Future.error('error'));
}

// ignore: must_be_immutable
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
