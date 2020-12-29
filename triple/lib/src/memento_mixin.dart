import 'store.dart';
import 'models/triple_model.dart';
import 'dart:math' as math;

mixin MementoMixin<State extends Object, Error extends Object>
    on Store<State, Error> {
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
      triple.state != lastTripleState.state;

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

  @override
  void setState(newState) {
    _addHistory(lastTripleState);
    super.setState(newState);
    lastTripleState = triple;
  }

  ///Undo the last state value.
  void undo() {
    if (canUndo()) {
      _historyIndex = _historyIndex > _history.length
          ? math.max(_history.length - 1, 0)
          : _historyIndex - 1;
      propagate(_history[_historyIndex]);
    }
  }

  ///redo the last state value.
  void redo() {
    if (_historyIndex + 1 < _history.length) {
      _historyIndex++;
      propagate(_history[_historyIndex]);
    } else if (triple.state != lastTripleState.state) {
      _historyIndex++;
      propagate(_history[_historyIndex]);
    }
  }
}
