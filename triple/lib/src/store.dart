import 'dart:async';

import 'models/triple_model.dart';
import 'package:meta/meta.dart';
import 'dart:math' as math;

typedef Disposer = Future<void> Function();

abstract class Store<State extends Object, Error extends Object> {
  late Triple<State, Error> triple;
  late Triple<State, Error> _lastTriple;
  final _history = <Triple<State, Error>>[];
  int _historyIndex = 0;
  late final int _historyLimit;

  State get state => triple.state;
  bool get loading => triple.loading;
  Error? get error => triple.error;

  Store(State initialState, {int historyLimit = 256}) {
    assert(historyLimit > 1, 'historySize not can be < 2');
    _historyLimit = historyLimit;
    triple = Triple<State, Error>(state: initialState);
    _lastTriple = triple;
  }

  @visibleForOverriding
  void propagate(Triple<State, Error> triple);

  void setState(State newState) {
    _addHistory(_lastTriple);
    triple = triple.copyWith(state: newState, event: TripleEvent.state);
    _lastTriple = triple;
    propagate(triple);
  }

  void setLoading(bool newloading) {
    triple = triple.copyWith(loading: newloading, event: TripleEvent.loading);
    propagate(triple);
  }

  void setError(Error newError) {
    triple = triple.copyWith(error: newError, event: TripleEvent.error);
    propagate(triple);
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

  void undo() {
    if (_history.isNotEmpty && _historyIndex > 0) {
      _historyIndex = _historyIndex > _history.length
          ? math.max(_history.length - 1, 0)
          : _historyIndex - 1;
      triple = _history[_historyIndex];
      propagate(triple);
    }
  }

  void redo() {
    if (_historyIndex + 1 < _history.length) {
      _historyIndex++;
      triple = _history[_historyIndex];
      propagate(triple);
    } else if (triple.state != _lastTriple.state) {
      _historyIndex++;
      triple = _lastTriple;
      propagate(triple);
    }
  }

  Future destroy();

  Disposer observer({
    void Function()? onState,
    void Function()? onLoading,
    void Function()? onError,
  });
}
