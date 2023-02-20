// ignore_for_file: empty_catches, lines_longer_than_80_chars

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:triple/triple.dart';

class _MutableIsDispose {
  bool value = false;
}

///[StreamStore] it's an abstract class that
///implements Selectors<Stream<Error>, Stream<State>, Stream<bool>>
abstract class StreamStore<Error extends Object, State extends Object>
    extends Store<Error, State>
    implements Selectors<Stream<Error>, Stream<State>, Stream<bool>> {
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(
    sync: true,
  );

  @override
  late final Stream<State> selectState = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.state)
      .map((triple) => triple.state);
  @override
  late final Stream<Error> selectError = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.error)
      .where((triple) => triple.error != null)
      .map((triple) => triple.error!);
  @override
  late final Stream<bool> selectLoading = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.loading)
      .map((triple) => triple.isLoading);

  final _MutableIsDispose _disposeValue = _MutableIsDispose();

  ///[StreamStore] constructor class
  StreamStore(State initialState) : super(initialState);

  @protected
  @override
  void propagate(Triple<Error, State> triple) {
    if (_disposeValue.value) {
      return;
    }
    super.propagate(triple);
    _tripleController.add(triple);
  }

  @override
  Future destroy() async {
    if (_disposeValue.value) {
      return;
    }
    _disposeValue.value = true;
    await _tripleController.close();
  }

  @override
  Disposer observer({
    void Function(State error)? onState,
    void Function(bool isLoading)? onLoading,
    void Function(Error error)? onError,
  }) {
    final _sub = _tripleController.stream.listen(
      (triple) {
        if (triple.event == TripleEvent.state) {
          onState?.call(
            triple.state,
          );
        } else if (triple.event == TripleEvent.error) {
          onError?.call(
            triple.error!,
          );
        } else if (triple.event == TripleEvent.loading) {
          onLoading?.call(
            triple.isLoading,
          );
        }
      },
    );

    return () async {
      try {
        await _sub.cancel();
      } catch (e, s) {
        log('StreamStoreError:', error: e, stackTrace: s);
      }
    };
  }
}
