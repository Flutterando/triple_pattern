// ignore_for_file: empty_catches, prefer_function_declarations_over_variables, lines_longer_than_80_chars

import 'dart:developer';

import 'package:rx_notifier/rx_notifier.dart';
import 'package:triple/triple.dart';

class _MutableIsDispose {
  bool value = false;
}

///[Store] it's an abstract class that
///implements Selectors<ValueListenable<Error?>, ValueListenable<State>, ValueListenable<bool>>
abstract class Store<State> extends BaseStore<State> implements Selectors<RxValueListenable<dynamic>, RxValueListenable<State>, RxValueListenable<bool>> {
  late final _selectState = RxNotifier<State>(triple.state);
  late final _selectError = RxNotifier<dynamic>(triple.error);
  late final _selectLoading = RxNotifier<bool>(triple.isLoading);

  @override
  RxValueListenable<State> get selectState => _selectState;
  @override
  RxValueListenable<dynamic> get selectError => _selectError;
  @override
  RxValueListenable<bool> get selectLoading => _selectLoading;

  @override
  State get state => selectState.value;

  @override
  dynamic get error => selectError.value;

  @override
  bool get isLoading => selectLoading.value;

  final _MutableIsDispose _disposeValue = _MutableIsDispose();

  ///[Store] constructor class
  Store(State initialState) : super(initialState);

  @override
  void propagate(Triple<State> triple) {
    super.propagate(triple);
    if (triple.event == TripleEvent.state) {
      _selectState.value = triple.state;
    } else if (triple.event == TripleEvent.error) {
      _selectError.value = triple.error;
    } else if (triple.event == TripleEvent.loading) {
      _selectLoading.value = triple.isLoading;
    }
  }

  @override
  Disposer observer({
    void Function(State state)? onState,
    void Function(bool loading)? onLoading,
    void Function(dynamic error)? onError,
  }) {
    final funcState = () => onState?.call(state);
    final funcLoading = () => onLoading?.call(isLoading);
    final funcError = () => error != null ? onError?.call(error) : null;

    if (onState != null) {
      selectState.addListener(
        funcState,
      );
    }
    if (onLoading != null) {
      selectLoading.addListener(
        funcLoading,
      );
    }
    if (onError != null) {
      selectError.addListener(
        funcError,
      );
    }

    return () async {
      try {
        if (onState != null) {
          selectState.removeListener(
            funcState,
          );
        }
        if (onLoading != null) {
          selectLoading.removeListener(
            funcLoading,
          );
        }
        if (onError != null) {
          selectError.removeListener(
            funcError,
          );
        }
      } catch (e, s) {
        log('NotifierStore:', error: e, stackTrace: s);
      }
    };
  }

  @override
  Future destroy() async {
    if (_disposeValue.value) {
      return;
    }
    _disposeValue.value = true;
    _selectState.dispose();
    _selectError.dispose();
    _selectLoading.dispose();
  }
}
