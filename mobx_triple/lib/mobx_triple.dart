library mobx_triple;

import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart' hide Store;
import 'package:triple/triple.dart';

abstract class MobXStore<State extends Object, Error extends Object>
    extends Store<State, Error> {
  late final _stateObservable = Observable<State>(triple.state);
  final _errorObservable = Observable<Error?>(null);
  final _loadingObservable = Observable<bool>(false);

  @override
  State get state => _stateObservable.value;

  @override
  Error? get error => _errorObservable.value;

  @override
  bool get loading => _loadingObservable.value;

  MobXStore(State initialState, {int historyLimit = 256})
      : super(initialState, historyLimit: historyLimit);

  @protected
  @override
  void propagate(Triple<State, Error> triple) {
    if (triple.event == TripleEvent.state) {
      _stateObservable.value = triple.state;
    } else if (triple.event == TripleEvent.error) {
      _errorObservable.value = triple.error;
    } else if (triple.event == TripleEvent.loading) {
      _loadingObservable.value = triple.loading;
    }
  }

  @override
  Disposer observer(
      {void Function(State state)? onState,
      void Function(bool loading)? onLoading,
      void Function(Error error)? onError}) {
    final disposers = <void Function()>[];

    if (onState != null) {
      disposers.add(_stateObservable.observe((_) {
        onState(triple.state);
      }));
    }
    if (onLoading != null) {
      disposers.add(_loadingObservable.observe((_) {
        onLoading(triple.loading);
      }));
    }
    if (onError != null) {
      disposers.add(_errorObservable.observe((_) {
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
