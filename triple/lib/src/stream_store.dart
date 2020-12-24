import 'dart:async';

import '../triple.dart';
import 'package:meta/meta.dart';

abstract class StreamStore<State extends Object, Error extends Object>
    extends Store<State, Error> {
  final _stateController = StreamController<State>.broadcast(sync: true);
  final _loadingController = StreamController<bool>.broadcast(sync: true);
  final _errorController = StreamController<Error?>.broadcast(sync: true);

  Stream<State> selectState() => _stateController.stream;
  Stream<bool> selectLoading() => _loadingController.stream;
  Stream<Error> selectError() =>
      _errorController.stream.where((event) => event != null).cast<Error>();

  StreamStore(State initialState, {int historyLimit = 256})
      : super(initialState, historyLimit: historyLimit);

  @protected
  @override
  void propagate(Triple<State, Error> _triple) {
    if (_triple.event == TripleEvent.state) {
      _stateController.add(_triple.state);
    } else if (_triple.event == TripleEvent.error) {
      _errorController.add(_triple.error);
    } else if (_triple.event == TripleEvent.loading) {
      _loadingController.add(_triple.loading);
    }
  }

  @override
  Future destroy() async {
    await _stateController.close();
    await _loadingController.close();
    await _errorController.close();
  }

  @override
  Disposer observer({
    void Function()? onState,
    void Function()? onLoading,
    void Function()? onError,
  }) {
    final subs = <StreamSubscription>[];

    if (onState != null) {
      subs.add(selectState().listen((event) {
        onState();
      }));
    }

    if (onLoading != null) {
      subs.add(selectLoading().listen((event) {
        onLoading();
      }));
    }

    if (onError != null) {
      subs.add(selectError().listen((event) {
        onError();
      }));
    }

    return () async {
      for (var sub in subs) {
        await sub.cancel();
      }
    };
  }
}
