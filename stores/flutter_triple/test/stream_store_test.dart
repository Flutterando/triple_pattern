import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:triple/triple.dart';

void main() {
  late Counter counter;
  late Disposer disposer;

  setUpAll(() {
    counter = Counter();
    disposer = counter.observer(onState: (state) {
      print(counter.state);
    }, onError: (error) {
      print('Error: ${counter.error}');
    }, onLoading: (loading) {
      print(counter.loading);
    });
  });

  tearDownAll(() async {
    await disposer();
    await counter.destroy();
  });

  test('Counter test', () async {
    expect(counter.selectState, emitsInOrder([1, 2, 3, 2, 1, 2]));
    expect(counter.selectError, emitsInOrder([isA<Exception>()]));
    expect(
        counter.selectLoading,
        emitsInOrder([
          true,
          false,
          true,
          false,
          true,
          false,
          true,
          false,
        ]));
    await counter.increment(); //dispach true, 1 and false
    await Future.delayed(Duration(milliseconds: 300));
    await counter.increment(); //dispach true, 2 and false
    await Future.delayed(Duration(milliseconds: 300));
    await counter.increment(); //dispach true, 3 and false
    await Future.delayed(Duration(milliseconds: 300));
    await counter.increment(); //dispach true, Exception and false
    await Future.delayed(Duration(milliseconds: 300));
    print('---------------');
    await Future.delayed(Duration(milliseconds: 1000));
    counter.undo(); // return to 2
    await Future.delayed(Duration(milliseconds: 300));
    counter.undo(); // return to 1
    await Future.delayed(Duration(milliseconds: 300));

    print('---------------');
    await Future.delayed(Duration(milliseconds: 500));
    counter.redo(); // redo to 2
  });
}

class Counter extends StreamStore<int, Exception> with MementoMixin {
  Counter() : super(0);

  Future<void> increment() async {
    setLoading(true);
    await Future.delayed(Duration(milliseconds: 300));
    if (state != 3) {
      update(state + 1);
    } else {
      setError(Exception('Error'));
    }
    setLoading(false);
  }
}
