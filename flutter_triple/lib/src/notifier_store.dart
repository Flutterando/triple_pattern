import 'package:flutter/foundation.dart';
import 'package:triple/triple.dart';

abstract class NotifierStore<State extends Object, Error extends Object>
    extends Store<State, Error> {
  late final _stateNotifier = ValueNotifier<State>(state);
  final _errorNotifier = ValueNotifier<Error?>(null);
  final _loadingNotifier = ValueNotifier<bool>(false);

  ValueListenable<State> get selectState => _stateNotifier;
  ValueListenable<Error?> get selectError => _errorNotifier;
  ValueListenable<bool> get selectLoading => _loadingNotifier;

  NotifierStore(State initialState, {int historyLimit = 256})
      : super(initialState, historyLimit: historyLimit);

  @override
  void propagate(Triple<State, Error> triple) {
    if (triple.event == TripleEvent.state) {
      _stateNotifier.value = triple.state;
    } else if (triple.event == TripleEvent.error) {
      _errorNotifier.value = triple.error;
    } else if (triple.event == TripleEvent.loading) {
      _loadingNotifier.value = triple.loading;
    }
  }

  @override
  void setState(State newState) {
    super.setState(newState);
    _stateNotifier.value = newState;
  }

  @override
  void setError(Error newError) {
    super.setError(newError);
    _errorNotifier.value = newError;
  }

  @override
  void setLoading(bool newloading) {
    super.setLoading(newloading);
    _loadingNotifier.value = newloading;
  }

  @override
  Disposer observer(
      {void Function()? onState,
      void Function()? onLoading,
      void Function()? onError}) {
    if (onState != null) {
      selectState.addListener(onState);
    }
    if (onLoading != null) {
      selectLoading.addListener(onLoading);
    }
    if (onError != null) {
      selectError.addListener(onError);
    }

    return () async {
      if (onState != null) {
        selectState.removeListener(onState);
      }
      if (onLoading != null) {
        selectLoading.removeListener(onLoading);
      }
      if (onError != null) {
        selectError.removeListener(onError);
      }
    };
  }

  @override
  Future destroy() async {
    _stateNotifier.dispose();
    _loadingNotifier.dispose();
    _loadingNotifier.dispose();
  }
}
