import 'dart:async';

import 'models/triple_model.dart';

typedef Disposer = Future<void> Function();

abstract class Store<State extends Object, Error extends Object> {
  late Triple<State, Error> _triple;
  late Triple<State, Error> _lastTriple;
  final _history = <Triple<State, Error>>[];
  int _historyIndex = 0;
  late final int _historyLimit;

  State get state => _triple.state;
  bool get loading => _triple.loading;
  Error? get error => _triple.error;

  Store(State initialState, {int historyLimit = 256}) {
    assert(historyLimit > 1, 'historySize not can be < 2');
    _historyLimit = historyLimit;
    _triple = Triple<State, Error>(state: initialState);
    _lastTriple = _triple;
  }

  void setState(State newState) {
    _addHistory(_lastTriple);
    _triple = _triple.copyWith(state: newState, event: TripleEvent.state);
    _lastTriple = _triple;
  }

  void setLoading(bool newloading) {
    _addHistory(_lastTriple);
    _triple = _triple.copyWith(loading: newloading, event: TripleEvent.loading);
    _lastTriple = _triple;
  }

  void setError(Error newError) {
    _addHistory(_lastTriple);
    _triple = _triple.copyWith(error: newError, event: TripleEvent.error);
    _lastTriple = _triple;
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
          _triple = candidate;
          propage(_triple);
          break;
        }
      }
    } else if (_history.isNotEmpty && when == null) {
      _historyIndex--;
      _triple = _history[_historyIndex];
      propage(_triple);
    }
  }

  void redo({TripleEvent? when}) {
    if (when != null) {
      for (var candidate in _history.sublist(_historyIndex - 1)) {
        if (candidate.event == when) {
          _historyIndex = _history.indexOf(candidate) + 1;
          _triple = candidate;
          propage(_triple);
          return;
        }
      }
    }

    if (_historyIndex + 1 < _history.length) {
      _historyIndex++;
      _triple = _history[_historyIndex];
      propage(_triple);
    } else if (_triple != _lastTriple) {
      _historyIndex++;
      _triple = _lastTriple;
      propage(_triple);
    }
  }

  void propage(Triple<State, Error> _triple);

  Future destroy();

  Disposer observer({
    void Function()? onState,
    void Function()? onLoading,
    void Function()? onError,
  });
}
