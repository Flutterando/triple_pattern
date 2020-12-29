import 'dart:async';

import 'models/triple_model.dart';
import 'package:meta/meta.dart';

typedef Disposer = Future<void> Function();

abstract class Store<State extends Object, Error extends Object> {
  late Triple<State, Error> triple;

  ///Get the [state] value;
  State get state => triple.state;

  ///Get [loading] value;
  bool get loading => triple.loading;

  ///Get [error] value;
  Error? get error => triple.error;

  ///[initialState] Start this store with a value defalt.
  Store(State initialState) {
    triple = Triple<State, Error>(state: initialState);
  }

  ///IMPORTANT!!!
  ///THIS METHOD TO BE VISIBLE FOR OVERRIDING ONLY!!!
  @visibleForOverriding
  void propagate() {}

  ///Change the State value.
  ///
  ///This also stores the state value to be retrieved using the [undo()] method
  void setState(State newState) {
    final candidate =
        triple.copyWith(state: newState, event: TripleEvent.state);
    if (candidate != triple && candidate.state != triple.state) {
      triple = candidate;
      propagate();
    }
  }

  ///Change the loading value.
  void setLoading(bool newloading) {
    final candidate =
        triple.copyWith(loading: newloading, event: TripleEvent.loading);
    if (candidate != triple && candidate.loading != triple.loading) {
      triple = candidate;
      propagate();
    }
  }

  ///Change the error value.
  void setError(Error newError) {
    final candidate =
        triple.copyWith(error: newError, event: TripleEvent.error);
    if (candidate != triple && candidate.error != triple.error) {
      triple = candidate;
      propagate();
    }
  }

  ///Discard the store
  Future destroy();

  ///Observer the Segmented State.
  ///
  ///EXAMPLE:
  ///```dart
  ///Disposer disposer = counter.observer(
  ///   onState: (state) => print(state),
  ///   onLoading: (loading) => print(loading),
  ///   onError: (error) => print(error),
  ///);
  ///
  ///dispose();
  ///```
  Disposer observer({
    void Function(State state)? onState,
    void Function(bool loading)? onLoading,
    void Function(Error error)? onError,
  });
}
