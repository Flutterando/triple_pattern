import 'package:meta/meta.dart';

import 'store.dart';
import 'models/triple_model.dart';
import 'dart:math' as math;

class _MutableIndex {
  int value = 0;
}

@immutable
mixin MementoMixin<State extends Object, Error extends Object> on Store<Error, State> {
  final _history = <Triple<Error, State>>[];
  final int _historyLimit = 64;
  final _MutableIndex _mutableIndex = _MutableIndex();
  int get _historyIndex => _mutableIndex.value;
  set _historyIndex(int value) => _mutableIndex.value = value;

  /// Total size of history state caches
  int get historyLength => _history.length;

  /// Return [true] if you can undo
  bool canUndo() => _history.isNotEmpty && _historyIndex > 0;

  /// Return [true] if you can redo
  bool canRedo() => (_historyIndex + 1) < _history.length || triple.state != lastState.state;

  void _addHistory(Triple<Error, State> observableCache) {
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

  @protected
  @override
  void update(newState, {bool force = false}) {
    final _last = lastState;
    super.update(newState, force: force);
    if (_last.state != triple.state) {
      _addHistory(_last.copyWith(isLoading: false));
    } else if (_historyIndex + 1 == _history.length) {
      _historyIndex++;
    }
  }

  ///Undo the last state value.
  void undo() {
    if (canUndo()) {
      _historyIndex = _historyIndex > _history.length ? math.max(_history.length - 1, 0) : _historyIndex - 1;
      // ignore: invalid_use_of_visible_for_overriding_member
      propagate(_history[_historyIndex]);
    }
  }

  ///redo the last state value.
  void redo() {
    if (_historyIndex + 1 < _history.length) {
      _historyIndex++;
      // ignore: invalid_use_of_visible_for_overriding_member
      propagate(_history[_historyIndex]);
    } else if (triple.state != lastState.state) {
      _historyIndex++;
      // ignore: invalid_use_of_visible_for_overriding_member
      propagate(lastState);
    }
  }

  void clearHistory(int position) {
    _history.clear();
    _historyIndex = 0;
  }
}
