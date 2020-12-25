import 'package:flutter/foundation.dart';
import 'package:triple/triple.dart';
import 'package:functional_listener/functional_listener.dart';

abstract class NotifierStore<State extends Object, Error extends Object>
    extends Store<State, Error> {
  late final _tripleController = ValueNotifier<Triple<State, Error>>(triple);

  late final ValueListenable<State> selectState = _tripleController
      .where((triple) => triple.event == TripleEvent.state)
      .map((triple) => triple.state);

  late final ValueListenable<Error> selectError = _tripleController
      .where((triple) => triple.event == TripleEvent.error)
      .where((triple) => triple.error != null)
      .map((triple) => triple.error!);

  late final ValueListenable<bool> selectLoading = _tripleController
      .where((triple) => triple.event == TripleEvent.loading)
      .map((triple) => triple.loading);

  NotifierStore(State initialState, {int historyLimit = 256})
      : super(initialState, historyLimit: historyLimit);

  @override
  void propagate(Triple<State, Error> triple) {
    _tripleController.value = triple;
  }

  @override
  Disposer observer(
      {void Function()? onState,
      void Function()? onLoading,
      void Function()? onError}) {
    final _sub = _tripleController.listen((triple, handle) {
      if (triple.event == TripleEvent.state) {
        onState?.call();
      } else if (triple.event == TripleEvent.error) {
        onError?.call();
      } else if (triple.event == TripleEvent.loading) {
        onLoading?.call();
      }
    });

    return () async {
      _sub.cancel();
    };
  }

  @override
  Future destroy() async {
    _tripleController.dispose();
  }
}
