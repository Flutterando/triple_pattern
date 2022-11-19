library mobx_triple;

import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart' hide Store;
import 'package:triple/triple.dart';
export 'package:triple/triple.dart';

abstract class MobXStore<Error extends Object, State extends Object>
    extends Store<Error, State>
    implements
        Selectors<Observable<Error?>, Observable<State>, Observable<bool>> {
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
  bool get isLoading => selectLoading.value;

  late final _propagateAction = Action(() {
    if (triple.event == TripleEvent.state) {
      selectState.value = triple.state;
    } else if (triple.event == TripleEvent.error) {
      selectError.value = triple.error;
    } else if (triple.event == TripleEvent.loading) {
      selectLoading.value = triple.isLoading;
    }
  });

  MobXStore(State initialState) : super(initialState);

  @protected
  @override
  void propagate(Triple<Error, State> triple) {
    super.propagate(triple);
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
        onLoading(triple.isLoading);
      }));
    }
    if (onError != null) {
      disposers.add(selectError.observe((_) {
        onError(triple.error!);
      }));
    }

    return () async {
      try {
        for (var disposer in disposers) {
          disposer();
        }
      } catch (e) {}
    };
  }

  @override
  Future destroy() async {}
}
