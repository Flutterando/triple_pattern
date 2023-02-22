import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

class CounterStreamStore extends StreamStore<String, int> {
  CounterStreamStore() : super(0);

  void increment() {
    update(state + 1);
  }

  void decrement() {
    update(state - 1);
  }

  void updateState(int value) {
    update(value);
  }

  void addError(String error) {
    setError(error);
  }

  void loading() {
    setLoading(!isLoading);
  }
}

void main() {
  group('StreamStore listen', () {
    late CounterStreamStore store;
    late int state;
    late String error;
    late bool isLoading;

    setUp(() {
      store = CounterStreamStore();
      state = -1;
      error = 'test exception';
      isLoading = false;

      store.selectState.listen((s) => state = s);
      store.selectError.listen((e) => error = e);
      store.selectLoading.listen((l) => isLoading = l);
    });

    test('initial state should be 0', () {
      expect(store.state, 0);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('increment should increase the state by 1', () {
      store.increment();
      expect(store.state, 1);
      expect(state, 1);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('decrement should decrease the state by 1', () {
      store.decrement();
      expect(store.state, -1);
      expect(state, -1);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('update should update the state', () {
      store.updateState(10);
      expect(store.state, 10);
      expect(state, 10);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('setError should set the error', () {
      store.addError('test exception');
      expect(store.state, 0);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('loading should emit true and false', () {
      store.loading();
      expect(isLoading, true);
      store.loading();
      expect(isLoading, false);
    });
  });
  group('StreamStore observer', () {
    late CounterStreamStore store;
    late int state;
    late String error;
    late bool isLoading;

    setUp(() {
      store = CounterStreamStore();
      state = -1;
      error = 'test exception';
      isLoading = false;

      store.observer(
        onState: (_state) {
          state = _state;
        },
        onError: (_error) {
          error = _error;
        },
        onLoading: (_loading) {
          isLoading = _loading;
        },
      );
    });

    test('initial state should be 0', () {
      expect(store.state, 0);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('increment should increase the state by 1', () {
      store.increment();
      expect(store.state, 1);
      expect(state, 1);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('decrement should decrease the state by 1', () {
      store.decrement();
      expect(store.state, -1);
      expect(state, -1);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('update should update the state', () {
      store.updateState(10);
      expect(store.state, 10);
      expect(state, 10);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('setError should set the error', () {
      store.addError('test exception');
      expect(store.state, 0);
      expect(error, isA<String>());
      expect(isLoading, false);
    });

    test('loading should emit true and false', () {
      store.loading();
      expect(isLoading, true);
      store.loading();
      expect(isLoading, false);
    });
  });
}
