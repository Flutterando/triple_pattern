import 'package:equatable/equatable.dart';
import 'package:flutter_triple/src/stores/notifier_store.dart';

class MockStore extends NotifierStore<String, int> {
  MockStore() : super(0);

  void updateWithValue(int state) => update(state);

  void updateWithError(String error) => setError(error);

  void enableLoading() => setLoading(true);

  void disableLoading() => setLoading(false);
}

class MockDistinctStore extends NotifierStore<String, CountState> {
  MockDistinctStore() : super(Init(0));

  void updateWithIncrement() => update(Increment(state.value + 1));

  void updateWithdecrement() => update(Decrement(state.value - 1));

  void updateError(String error) => setError(error);

  void enableLoading() => setLoading(true);

  void disableLoading() => setLoading(false);
}

abstract class CountState with EquatableMixin {
  final int value;

  CountState(this.value);

  @override
  List<Object?> get props => [value];
}

class Increment extends CountState with EquatableMixin {
  Increment(int value) : super(value);

  @override
  List<Object?> get props => [value];
}

class Decrement extends CountState with EquatableMixin {
  Decrement(int value) : super(value);

  @override
  List<Object?> get props => [value];
}

class Loading extends CountState with EquatableMixin {
  Loading(int value) : super(value);
  @override
  List<Object?> get props => [value];
}

class Init extends CountState with EquatableMixin {
  Init(int value) : super(value);

  @override
  List<Object?> get props => [value];
}
