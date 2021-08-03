import 'package:flutter/foundation.dart';
import 'package:rx_notifier/rx_notifier.dart';
import 'package:triple/triple.dart';

abstract class NotifierStore<Error extends Object, State extends Object>
    extends Store<Error, State>
    implements
        Selectors<ValueListenable<Error?>, ValueListenable<State>,
            ValueListenable<bool>> {
  late final _selectState = RxNotifier<State>(triple.state);
  late final _selectError = RxNotifier<Error?>(triple.error);
  late final _selectLoading = RxNotifier<bool>(triple.isLoading);

  @override
  ValueListenable<State> get selectState => _selectState;
  @override
  ValueListenable<Error?> get selectError => _selectError;
  @override
  ValueListenable<bool> get selectLoading => _selectLoading;

  @override
  State get state => selectState.value;

  @override
  Error? get error => selectError.value;

  @override
  bool get isLoading => selectLoading.value;

  NotifierStore(State initialState) : super(initialState);

  @override
  void propagate(Triple<Error, State> triple) {
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
  Disposer observer(
      {void Function(State state)? onState,
      void Function(bool loading)? onLoading,
      void Function(Error error)? onError}) {
    final funcState = () => onState?.call(state);
    final funcLoading = () => onLoading?.call(isLoading);
    final funcError = () => error != null ? onError?.call(error!) : null;

    if (onState != null) {
      selectState.addListener(funcState);
    }
    if (onLoading != null) {
      selectLoading.addListener(funcLoading);
    }
    if (onError != null) {
      selectError.addListener(funcError);
    }

    return () async {
      try {
        if (onState != null) {
          selectState.removeListener(funcState);
        }
        if (onLoading != null) {
          selectLoading.removeListener(funcLoading);
        }
        if (onError != null) {
          selectError.removeListener(funcError);
        }
      } catch (ex) {}
    };
  }

  @override
  Future destroy() async {}
}
