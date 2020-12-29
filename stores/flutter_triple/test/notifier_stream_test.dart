import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_triple/flutter_triple.dart';
import 'package:flutter_triple/src/stores/notifier_store.dart';

void main() {
  late Counter counter;

  setUpAll(() {
    counter = Counter();
    counter.observer(
      onState: (state) => print("State ${counter.state}"),
      onLoading: (loading) => print(counter.loading),
    );
  });

  test('increment count', () async {
    await counter.increment();
    print('-------');
    await counter.increment();
    print('-------');
    await Future.delayed(Duration(milliseconds: 1000));
    counter.undo(); // it is state == 2, listener not being notified
    counter.undo(); // true
    await Future.delayed(Duration(milliseconds: 1000));
    // print('-------');
  });
}

class Counter extends NotifierStore<int, Exception> with MementoMixin {
  Counter() : super(0);

  Future<void> increment() async {
    setLoading(true);
    await Future.delayed(Duration(milliseconds: 1000));
    setState(state + 1);
    setLoading(false);
  }
}
