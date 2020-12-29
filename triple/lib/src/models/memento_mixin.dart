import 'package:meta/meta.dart';

import '../store.dart';
import 'triple_model.dart';
import 'dart:math' as math;

mixin MementoMixin<State extends Object, Error extends Object>
    on Store<State, Error> {
  late Triple<State, Error> _lastTripleState = triple;
  final _history = <Triple<State, Error>>[];
  final int _historyLimit = 32;
  int _historyIndex = 0;

  /// Total size of history state caches;
  int get historyLength => _history.length;

  ///Return [true] if you can undo
  bool canUndo() => _history.isNotEmpty && _historyIndex > 0;

  ///Return [true] if you can redo
  bool canRedo() =>
      (_historyIndex + 1) < _history.length ||
      triple.state != _lastTripleState.state;

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

  @mustCallSuper
  @override
  void propagate() {
    if (triple.event == TripleEvent.state) {
      _addHistory(_lastTripleState);
      _lastTripleState = triple;
    }
    _lastTripleState = triple;
  }

  ///Undo the last state value.
  void undo() {
    if (canUndo()) {
      _historyIndex = _historyIndex > _history.length
          ? math.max(_history.length - 1, 0)
          : _historyIndex - 1;
      triple = _history[_historyIndex];
      super.propagate();
    }
  }

  ///redo the last state value.
  void redo() {
    if (_historyIndex + 1 < _history.length) {
      _historyIndex++;
      triple = _history[_historyIndex];
      propagate();
    } else if (triple.state != _lastTripleState.state) {
      _historyIndex++;
      triple = _lastTripleState;
      propagate();
    }
  }
}
