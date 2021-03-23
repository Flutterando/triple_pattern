import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triple/triple.dart';

class MockStore<E extends Object, S extends Object> extends Mock implements Store<E, S> {
  final _callList = <InvocationPropagation<E, S>>[];

  void dispatcherTriple(Triple<E, S> triple) {
    for (var call in _callList) {
      if (triple.event == TripleEvent.state) {
        call.onState?.call(triple.state);
      } else if (triple.event == TripleEvent.loading) {
        call.onLoading?.call(triple.isLoading);
      } else if (triple.event == TripleEvent.error) {
        if (triple.error != null) {
          call.onError?.call(triple.error!);
        }
      }
    }
  }

  @visibleForTesting
  void restartInitialTriple(Triple<E, S> triple) {
    when(() => this.state).thenReturn(triple.state);
    when(() => this.error).thenReturn(triple.error);
    when(() => this.isLoading).thenReturn(triple.isLoading);
    when(() => this.triple).thenReturn(triple);
  }

  @override
  Disposer observer({
    void Function(S state)? onState,
    void Function(bool isLoading)? onLoading,
    void Function(E error)? onError,
  }) {
    final call = InvocationPropagation<E, S>();
    call.onState = onState;
    call.onLoading = onLoading;
    call.onError = onError;
    _callList.add(call);
    return () async {
      call.onState = null;
      call.onLoading = null;
      call.onError = null;
      _callList.remove(call);
    };
  }
}

class InvocationPropagation<E extends Object?, S extends Object> {
  void Function(S state)? onState;
  void Function(bool isLoading)? onLoading;
  void Function(E error)? onError;
}
