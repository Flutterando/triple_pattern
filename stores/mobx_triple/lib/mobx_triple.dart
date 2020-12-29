library mobx_triple;

import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart' hide Store;
import 'package:triple/triple.dart';
export 'package:triple/triple.dart';

abstract class MobXStore<State extends Object, Error extends Object>
    extends Store<State, Error>
    implements
        Selectors<Observable<State>, Observable<Error?>, Observable<bool>> {
  @override
  late final selectState = Observable<State>(triple.state);

  @override
  final selectError = Observable<Error?>(null);

  @override
  final selectLoading = Observable<bool>(false);

  @override
  State get state => selectState.value;

  @override
  Error? get error => selectError.value;

  @override
  bool get loading => selectLoading.value;

  late final _propagateAction = Action(() {
    if (triple.event == TripleEvent.state) {
      selectState.value = triple.state;
    } else if (triple.event == TripleEvent.error) {
      selectError.value = triple.error;
    } else if (triple.event == TripleEvent.loading) {
      selectLoading.value = triple.loading;
    }
  });

  MobXStore(State initialState) : super(initialState);

  @protected
  @override
  void propagate(Triple<State, Error> triple) {
    _propagateAction();
  }

  @override
  Disposer observer(
      {void Function(State state)? onState,
      void Function(bool loading)? onLoading,
      void Function(Error error)? onError}) {
    final disposers = <void Function()>[];

    if (onState != null) {
      disposers.add(selectState.observe((_) {
        onState(triple.state);
      }));
    }
    if (onLoading != null) {
      disposers.add(selectLoading.observe((_) {
        onLoading(triple.loading);
      }));
    }
    if (onError != null) {
      disposers.add(selectError.observe((_) {
        onError(triple.error!);
      }));
    }

    return () async {
      for (var disposer in disposers) {
        disposer();
      }
    };
  }

  @override
  Future destroy() async {}
}
