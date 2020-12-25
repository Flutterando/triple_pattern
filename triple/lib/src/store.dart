import 'dart:async';

import 'models/triple_model.dart';
import 'package:meta/meta.dart';
import 'dart:math' as math;

typedef Disposer = Future<void> Function();

abstract class Store<State extends Object, Error extends Object> {
  late Triple<State, Error> triple;
  late Triple<State, Error> _lastTripleState;
  final _history = <Triple<State, Error>>[];
  int _historyIndex = 0;
  late final int _historyLimit;

  ///Get the [state] value;
  State get state => triple.state;

  ///Get [loading] value;
  bool get loading => triple.loading;

  ///Get [error] value;
  Error? get error => triple.error;

  ///[initialState] Start this store with a value defalt.
  ///
  ///[historyLimit] History's State cache.
  ///This property defines the maximum size of the state value that can be stored. Used when invoking the [undo()] and [rendo()] methods.
  Store(State initialState, {int historyLimit = 256}) {
    assert(historyLimit > 1, 'historySize not can be < 2');
    _historyLimit = historyLimit;
    triple = Triple<State, Error>(state: initialState);
    _lastTripleState = triple;
  }

  ///IMPORTANT!!!
  ///THIS METHOD TO BE VISIBLE FOR OVERRIDING ONLY!!!
  @visibleForOverriding
  void propagate(Triple<State, Error> triple);

  ///Change the State value.
  ///
  ///This also stores the state value to be retrieved using the [undo()] method
  void setState(State newState) {
    final candidate =
        triple.copyWith(state: newState, event: TripleEvent.state);
    if (candidate != triple && candidate.state != triple.state) {
      _addHistory(_lastTripleState);
      triple = candidate;
      _lastTripleState = triple;
      propagate(triple);
    }
  }

  ///Change the loading value.
  void setLoading(bool newloading) {
    final candidate =
        triple.copyWith(loading: newloading, event: TripleEvent.loading);
    if (candidate != triple && candidate.loading != triple.loading) {
      triple = candidate;
      propagate(triple);
    }
  }

  ///Change the error value.
  void setError(Error newError) {
    final candidate =
        triple.copyWith(error: newError, event: TripleEvent.error);
    if (candidate != triple && candidate.error != triple.error) {
      triple = candidate;
      propagate(triple);
    }
  }

  void _addHistory(Triple<State, Error> observableCache) {
    if (_historyIndex == _history.length) {
      _history.add(observableCache);
    } else {
      final newList = _history.take(_historyIndex + 1).toList();
      _history.clear();
      _history.addAll(newList);
    }
    if (_history.length > _historyLimit) {
      _history.removeAt(0);
    }
    _historyIndex = _history.length;
  }

  ///Undo the last state value.
  void undo() {
    if (_history.isNotEmpty && _historyIndex > 0) {
      _historyIndex = _historyIndex > _history.length
          ? math.max(_history.length - 1, 0)
          : _historyIndex - 1;
      triple = _history[_historyIndex];
      propagate(triple);
    }
  }

  ///redo the last state value.
  void redo() {
    if (_historyIndex + 1 < _history.length) {
      _historyIndex++;
      triple = _history[_historyIndex];
      propagate(triple);
    } else if (triple.state != _lastTripleState.state) {
      _historyIndex++;
      triple = _lastTripleState;
      propagate(triple);
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
