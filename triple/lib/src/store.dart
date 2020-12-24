import 'dart:async';

import 'models/triple_model.dart';
import 'package:meta/meta.dart';

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
    _addHistory(_lastTriple);
    triple = triple.copyWith(loading: newloading, event: TripleEvent.loading);
    _lastTriple = triple;
    propagate(triple);
  }

  void setError(Error newError) {
    _addHistory(_lastTriple);
    triple = triple.copyWith(error: newError, event: TripleEvent.error);
    _lastTriple = triple;
    propagate(triple);
  }

  void _addHistory(Triple<State, Error> observableCache) {
    if (_historyIndex == _history.length) {
      _history.add(observableCache);
    } else {
      final newList = _history.take(_historyIndex).toList()
        ..add(observableCache);
      _history.clear();
      _history.addAll(newList);
    }
    if (_history.length > _historyLimit) {
      _history.removeAt(0);
    }
    _historyIndex = _history.length;
  }

  void undo({TripleEvent? when}) {
    if (when != null && _historyIndex > 1) {
      for (var candidate in _history.reversed) {
        if (candidate.event == when) {
          _historyIndex = _history.indexOf(candidate) + 1;
          triple = candidate;
          propagate(triple);
          break;
        }
      }
    } else if (_history.isNotEmpty && when == null) {
      _historyIndex--;
      triple = _history[_historyIndex];
      propagate(triple);
    }
  }

  void redo({TripleEvent? when}) {
    if (when != null) {
      for (var candidate in _history.sublist(_historyIndex - 1)) {
        if (candidate.event == when) {
          _historyIndex = _history.indexOf(candidate) + 1;
          triple = candidate;
          propagate(triple);
          return;
        }
      }
    }

    if (_historyIndex + 1 < _history.length) {
      _historyIndex++;
      triple = _history[_historyIndex];
      propagate(triple);
    } else if (triple != _lastTriple) {
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
