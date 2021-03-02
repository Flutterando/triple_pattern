import 'dart:async';

import 'package:async/async.dart';
import 'package:dartz/dartz.dart';

import 'models/triple_model.dart';
import 'package:meta/meta.dart';

typedef Disposer = Future<void> Function();

typedef TripleCallback = void Function(Triple triple);

final _tripleCallbackList = <TripleCallback>{};

void _execTripleObserver(Triple triple) {
  for (var callback in _tripleCallbackList) {
    callback(triple);
  }
}

class TripleObserver {
  static void addListener(TripleCallback callback) {
    _tripleCallbackList.add(callback);
  }

  static void removeListener(TripleCallback callback) {
    _tripleCallbackList.remove(callback);
  }

  TripleObserver._();
}

class _MutableObjects<Error extends Object, State extends Object> {
  late Triple<Error, State> triple;
  late Triple<Error, State> lastState;
  CancelableOperation? completerExecution;
  var lastExecution = DateTime.now();

  _MutableObjects(State state) {
    triple = Triple(state: state);
    lastState = Triple(state: state);
  }
}

@immutable
abstract class Store<Error extends Object, State extends Object> {
  late final _MutableObjects<Error, State> _mutableObjects;

  ///Get the complete triple value;
  Triple<Error, State> get triple => _mutableObjects.triple;

  Triple<Error, State> get lastState => _mutableObjects.lastState;

  ///Get the [state] value;
  State get state => _mutableObjects.triple.state;

  ///Get [loading] value;
  bool get isLoading => _mutableObjects.triple.isLoading;

  ///Get [error] value;
  Error? get error => _mutableObjects.triple.error;

  ///[initialState] Start this store with a value defalt.
  Store(State initialState) : _mutableObjects = _MutableObjects<Error, State>(initialState);

  ///IMPORTANT!!!
  ///THIS METHOD TO BE VISIBLE FOR OVERRIDING ONLY!!!
  @visibleForOverriding
  void propagate(Triple<Error, State> triple) {
    _mutableObjects.triple = triple;
    _execTripleObserver(triple);
  }

  ///Change the State value.
  ///
  ///This also stores the state value to be retrieved using the [undo()] method when using MementoMixin
  void update(State newState, {bool force = false}) {
    var candidate = _mutableObjects.triple.copyWith(state: newState, event: TripleEvent.state);
    candidate = middleware(candidate);
    if (force || (candidate.state != _mutableObjects.triple.state)) {
      _mutableObjects.lastState = candidate.copyWith(isLoading: false);
      _mutableObjects.triple = candidate;
      propagate(_mutableObjects.triple);
    }
  }

  ///Change the loading value.
  void setLoading(bool newloading, {bool force = false}) {
    var candidate = _mutableObjects.triple.copyWith(isLoading: newloading, event: TripleEvent.loading);
    candidate = middleware(candidate);
    if (force || (candidate.isLoading != _mutableObjects.triple.isLoading)) {
      _mutableObjects.triple = candidate;
      propagate(_mutableObjects.triple);
    }
  }

  ///Change the error value.
  void setError(Error newError, {bool force = false}) {
    var candidate = _mutableObjects.triple.copyWith(error: newError, event: TripleEvent.error);
    candidate = middleware(candidate);
    if (force || (candidate.error != _mutableObjects.triple.error)) {
      _mutableObjects.triple = candidate;
      propagate(_mutableObjects.triple);
    }
  }

  ///called when dispacher [update], [setLoading] or [setError]
  ///overriding to change triple before the propagation;
  Triple<Error, State> middleware(Triple<Error, State> newTriple) {
    return newTriple;
  }

  ///Execute a Future.
  ///
  ///This function is a sugar code used to run a Future in a simple way,
  ///executing [setLoading] and adding to [setError] if an error occurs in Future
  Future<void> execute(Future<State> Function() func, {Duration delay = const Duration(milliseconds: 50)}) async {
    final localTime = DateTime.now();
    _mutableObjects.lastExecution = localTime;
    await Future.delayed(delay);
    if (localTime != _mutableObjects.lastExecution) {
      return;
    }

    setLoading(true);

    await _mutableObjects.completerExecution?.cancel();

    _mutableObjects.completerExecution = CancelableOperation.fromFuture(func());

    await _mutableObjects.completerExecution!.then(
      (value) {
        if (value is State) {
          update(value, force: true);
          setLoading(false);
        }
      },
      onError: (error, __) {
        if (error is Error) {
          setError(error, force: true);
          setLoading(false);
        } else {
          throw Exception('is expected a ${Error.toString()} type, and receipt ${error.runtimeType}');
        }
      },
    ).valueOrCancellation();
  }

  ///Execute a Future Either [dartz].
  ///
  ///This function is a sugar code used to run a Future in a simple way,
  ///executing [setLoading] and adding to [setError] if an error occurs in Either
  Future<void> executeEither(Future<Either<Error, State>> Function() func, {Duration delay = const Duration(milliseconds: 50)}) async {
    final localTime = DateTime.now();
    _mutableObjects.lastExecution = localTime;
    await Future.delayed(delay);
    if (localTime != _mutableObjects.lastExecution) {
      return;
    }

    setLoading(true);

    await _mutableObjects.completerExecution?.cancel();

    _mutableObjects.completerExecution = CancelableOperation.fromFuture(func());

    await _mutableObjects.completerExecution!.then(
      (value) {
        if (value is Either<Error, State>) {
          value.fold(setError, update);
          setLoading(false);
        }
      },
    ).valueOrCancellation();
  }

  ///Execute a Stream.
  ///
  ///This function is a sugar code used to run a Stream in a simple way,
  ///executing [setLoading] and adding to [setError] if an error occurs in Stream
  StreamSubscription executeStream(Stream<State> stream) {
    StreamSubscription sub = stream.listen(
      update,
      onError: (error) => setError(error, force: true),
      onDone: () => setLoading(false),
    );
    return sub;
  }

  ///Discard the store
  Future destroy();

  ///Observer the Segmented State.
  ///
  ///EXAMPLE:
  ///```dart
  ///Disposer disposer = counter.observer(
  ///   onState: (state) => print(state),
  ///   onLoading: (loading) => print(loading),
  ///   onError: (error) => print(error),
  ///);
  ///
  ///dispose();
  ///```
  Disposer observer({
    void Function(State state)? onState,
    void Function(bool isLoading)? onLoading,
    void Function(Error error)? onError,
  });
}
