import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_triple/flutter_triple.dart';
import 'package:flutter_triple/src/stores/notifier_store.dart';

void main() {
  test('increment count', () async {
    final counter = Counter();
    final completer = Completer();
    final list = <dynamic>[0];
    counter.observer(
      onState: (state) {
        list.add(state);
        if (state == 2) {
          completer.complete(true);
        }
      },
      onLoading: (loading) {
        list.add(loading);
      },
    );
    await Future.delayed(Duration(milliseconds: 1000));
    counter.increment();
    await Future.delayed(Duration(milliseconds: 1000));
    counter.increment();
    await completer.future;
    expect(list, [0, true, 1, false, true, 2, false]);
  });

  test('force update', () async {
    final counter = Counter();
    final completer = Completer();
    final list = <dynamic>[];
    counter.observer(
      onState: (state) {
        list.add(state);
        completer.complete(true);
      },
      onLoading: (loading) {
        list.add(loading);
      },
    );
    await Future.delayed(Duration(milliseconds: 1000));
    counter.update(0, force: true);
    await completer.future;
    expect(list, [0]);
  });
}

class Counter extends NotifierStore<Exception, int> with MementoMixin {
  Counter() : super(0);

  Future<void> increment() async {
    setLoading(true);
    await Future.delayed(Duration(milliseconds: 1000));
    update(state + 1);
    setLoading(false);
  }
}
