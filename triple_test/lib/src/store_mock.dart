// ignore_for_file: lines_longer_than_80_chars, cascade_invocations

import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triple/triple.dart';

class MockStore<S> extends Mock implements BaseStore<S> {
  final _callList = <InvocationPropagation<S>>[];

  void dispatcherTriple(Triple<S> triple) {
    for (final call in _callList) {
      if (triple.event == TripleEvent.state) {
        call.onState?.call(triple.state);
      } else if (triple.event == TripleEvent.loading) {
        call.onLoading?.call(triple.isLoading);
      } else if (triple.event == TripleEvent.error) {
        if (triple.error != null) {
          call.onError?.call(triple.error);
        }
      }
    }
  }

  @visibleForTesting
  void restartInitialTriple(Triple<S> triple) {
    when(() => state).thenReturn(triple.state);
    when(() => error).thenReturn(triple.error);
    when(() => isLoading).thenReturn(triple.isLoading);
    when(() => this.triple).thenReturn(triple);
  }

  @override
  Disposer observer({
    void Function(S state)? onState,
    void Function(bool isLoading)? onLoading,
    void Function(dynamic error)? onError,
  }) {
    final call = InvocationPropagation<S>();
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

class InvocationPropagation<S> {
  void Function(S state)? onState;
  void Function(bool isLoading)? onLoading;
  void Function(dynamic error)? onError;
}
