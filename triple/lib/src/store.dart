import 'dart:async';

typedef Disposer = Future<void> Function();

abstract class Store<State extends Object, Error extends Object> {
  late _ObservableCache<State, Error> _observableCache;
  final _history = <_ObservableCache<State, Error>>[];

  State get state => _observableCache.state;
  bool get isLoading => _observableCache.isLoading;
  Error? get error => _observableCache.error;

  final _stateController = StreamController<State>.broadcast(sync: true);
  final _loadingController = StreamController<bool>.broadcast(sync: true);
  final _errorController = StreamController<Error?>.broadcast(sync: true);

  Stream<State> selectState() => _stateController.stream;
  Stream<bool> selectLoading() => _loadingController.stream;
  Stream<Error> selectError() =>
      _errorController.stream.where((event) => event != null).cast<Error>();

  Store(State initialState) {
    _observableCache = _ObservableCache<State, Error>(state: initialState);
    _history.add(_observableCache);
  }

  void setState(State newState) {
    final index = _observableCache.index;
    _observableCache = _observableCache.copyWith(
        state: newState, event: _ObsevableCacheEvent.state, index: index + 1);
    _stateController.add(_observableCache.state);
    _addHistory(index, _observableCache);
  }

  void setLoading(bool newisLoading) {
    final index = _observableCache.index;
    _observableCache = _observableCache.copyWith(
        isLoading: newisLoading,
        event: _ObsevableCacheEvent.loading,
        index: index + 1);
    _loadingController.add(_observableCache.isLoading);
    _addHistory(index, _observableCache);
  }

  void setError(Error newError) {
    final index = _observableCache.index;
    _observableCache = _observableCache.copyWith(
        error: newError, event: _ObsevableCacheEvent.error, index: index + 1);
    _errorController.add(_observableCache.error);
    _addHistory(index, _observableCache);
  }

  void _addHistory(
      int afterIndex, _ObservableCache<State, Error> newObservableCache) {
    final newList = _history.take(afterIndex + 1).toList()
      ..add(newObservableCache);
    _history.clear();
    _history.addAll(newList);
  }

  void undo() {
    if (_history.length > 1) {
      _observableCache = _history[_observableCache.index - 2];
      _propage(_observableCache);
    }
  }

  void redo() {
    final index = _observableCache.index;
    if (index < _history.length) {
      _observableCache = _history[index];
      _propage(_observableCache);
    }
  }

  void _propage(_ObservableCache<State, Error> _observableCache) {
    if (_observableCache.event == _ObsevableCacheEvent.state) {
      _stateController.add(_observableCache.state);
    } else if (_observableCache.event == _ObsevableCacheEvent.error) {
      _errorController.add(_observableCache.error);
    } else if (_observableCache.event == _ObsevableCacheEvent.loading) {
      _loadingController.add(_observableCache.isLoading);
    }
  }

  Future destroy() async {
    await _stateController.close();
    await _loadingController.close();
    await _errorController.close();
  }

  Disposer observer({
    void Function()? onState,
    void Function()? onLoading,
    void Function()? onError,
  }) {
    final subs = <StreamSubscription>[];

    if (onState != null) {
      subs.add(selectState().listen((event) {
        onState();
      }));
    }

    if (onLoading != null) {
      subs.add(selectLoading().listen((event) {
        onLoading();
      }));
    }

    if (onError != null) {
      subs.add(selectError().listen((event) {
        onError();
      }));
    }

    return () async {
      for (var sub in subs) {
        await sub.cancel();
      }
    };
  }
}

class _ObservableCache<State extends Object, Error extends Object> {
  final State state;
  final Error? error;
  final bool isLoading;
  final int index;
  final _ObsevableCacheEvent event;

  const _ObservableCache(
      {required this.state,
      this.error,
      this.isLoading = false,
      this.event = _ObsevableCacheEvent.state,
      this.index = 1});

  _ObservableCache<State, Error> copyWith(
      {State? state,
      Error? error,
      bool? isLoading,
      int? index,
      _ObsevableCacheEvent? event}) {
    return _ObservableCache<State, Error>(
      state: state ?? this.state,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      event: event ?? this.event,
      index: index ?? this.index,
    );
  }
}

enum _ObsevableCacheEvent { state, loading, error }
