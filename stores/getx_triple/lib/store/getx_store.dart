import 'dart:async';

import 'package:triple/triple.dart';
import 'package:get/get_rx/get_rx.dart';

abstract class GetXStore<Error extends Object, State extends Object> extends Store<Error, State> {
  final _error = Rx<Error>();
  final _state = Rx<State>();
  final _isLoading = Rx<bool>();

  @override
  State get state => _state.value;
  @override
  Error get error => _error.value;
  @override
  bool get isLoading => _isLoading.value;

  GetXStore(State initialState) : super(initialState) {
    _state.value = initialState;
    _isLoading.value = false;
  }

  @override
  void propagate(Triple<Error, State> triple) {
    super.propagate(triple);
    if (triple.event == TripleEvent.state) {
      _state.value = triple.state;
    } else if (triple.event == TripleEvent.error) {
      _error.value = triple.error;
    } else if (triple.event == TripleEvent.loading) {
      _isLoading.value = triple.isLoading;
    }
  }

  @override
  Disposer observer({void Function(State state) onState, void Function(bool isLoading) onLoading, void Function(Error error) onError}) {
    final list = <StreamSubscription>[];
    if (onState != null) {
      list.add(_state.listen((State state) {
        onState(state);
      }));
    }

    if (isLoading != null) {
      list.add(_isLoading.listen((bool isLoading) {
        onLoading(isLoading);
      }));
    }

    if (onError != null) {
      list.add(_error.listen((Error error) {
        onError(error);
      }));
    }

    return () async {
      for (var item in list) {
        await item.cancel();
      }
    };
  }

  @override
  Future destroy() async {
    _state.close();
    _error.close();
    _isLoading.close();
  }
}
