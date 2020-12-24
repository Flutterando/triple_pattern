import 'package:triple/src/models/triple_model.dart';
import 'package:triple/triple.dart';
import 'package:test/test.dart';

void main() {
  late Counter counter;
  late Disposer disposer;

  setUpAll(() {
    counter = Counter();
    disposer = counter.observer(onState: () {
      print(counter.state);
    }, onError: () {
      print('Error: ${counter.error}');
    }, onLoading: () {
      print(counter.loading);
    });
  });

  tearDownAll(() async {
    await disposer();
    await counter.destroy();
  });

  test('Counter test', () async {
    expect(counter.selectState(), emitsInOrder([1, 2, 3, 2, 1, 2]));
    expect(counter.selectError(), emitsInOrder([isA<Exception>()]));
    expect(
        counter.selectLoading(),
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
    await counter.increment(); //dispach true, 2 and false
    await counter.increment(); //dispach true, 3 and false
    await counter.increment(); //dispach true, Exception and false
    print('---------------');
    await Future.delayed(Duration(milliseconds: 1000));
    counter.undo(); // return to 2
    counter.undo(); // return to 1

    print('---------------');
    await Future.delayed(Duration(milliseconds: 500));
    counter.redo(); // redo to 2
  });
}

class Counter extends StreamStore<int, Exception> {
  Counter() : super(0);

  Future<void> increment() async {
    setLoading(true);
    await Future.delayed(Duration(milliseconds: 300));
    if (state != 3) {
      setState(state + 1);
    } else {
      setError(Exception('Error'));
    }
    setLoading(false);
  }
}
