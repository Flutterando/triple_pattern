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
      print(counter.isLoading);
    });
  });

  tearDownAll(() async {
    await disposer();
    await counter.destroy();
  });

  test('Counter test', () async {
    expect(counter.selectState(), emitsInOrder([1, 2, 3, 3]));
    expect(counter.selectError(),
        emitsInOrder([isA<Exception>(), isA<Exception>(), isA<Exception>()]));
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
          true,
          false,
          true,
        ]));
    await counter.increment(); //dispach true, 1 and false
    await counter.increment(); //dispach true, 2 and false
    await counter.increment(); //dispach true, 3 and false
    await counter.increment(); //dispach true, Exception and false
    print('---------------');
    await Future.delayed(Duration(milliseconds: 1000));
    counter.undo(); // return to loading true
    counter.undo(); // return to Exception
    counter.undo(); // return to loading false
    print('---------------');
    await Future.delayed(Duration(milliseconds: 500));
    counter.redo(); // redo to true
    counter.redo(); // redo to Exception
    counter.redo(); // redo to false
    print('---------------');
    await Future.delayed(Duration(milliseconds: 500));
    counter.undo(); // return to Exception
    counter.undo(when: TripleEvent.state); // return to 3
    await Future.delayed(Duration(milliseconds: 500));
    counter.redo(); // redo to true
    counter.redo(when: TripleEvent.loading); // redo to false
  });
}

class Counter extends Store<int, Exception> {
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
