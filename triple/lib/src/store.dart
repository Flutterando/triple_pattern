import 'dart:async';

typedef Disposer = Future<void> Function();

abstract class Store<State extends Object, Error extends Object> {
  late Triple<State, Error> _triple;
  late Triple<State, Error> _lastTriple;
  final _history = <Triple<State, Error>>[];
  int _historyIndex = 0;

  State get state => _triple.state;
  bool get isLoading => _triple.isLoading;
  Error? get error => _triple.error;

  final _stateController = StreamController<State>.broadcast(sync: true);
  final _loadingController = StreamController<bool>.broadcast(sync: true);
  final _errorController = StreamController<Error?>.broadcast(sync: true);

  Stream<State> selectState() => _stateController.stream;
  Stream<bool> selectLoading() => _loadingController.stream;
  Stream<Error> selectError() =>
      _errorController.stream.where((event) => event != null).cast<Error>();

  Store(State initialState) {
    _triple = Triple<State, Error>(state: initialState);
    _lastTriple = _triple;
  }

  void setState(State newState) {
    _addHistory(_lastTriple);
    _triple = _triple.copyWith(state: newState, event: TripleEvent.state);
    _lastTriple = _triple;
    _stateController.add(_triple.state);
  }

  void setLoading(bool newisLoading) {
    _addHistory(_lastTriple);
    _triple =
        _triple.copyWith(isLoading: newisLoading, event: TripleEvent.loading);
    _lastTriple = _triple;
    _loadingController.add(_triple.isLoading);
  }

  void setError(Error newError) {
    _addHistory(_lastTriple);
    _triple = _triple.copyWith(error: newError, event: TripleEvent.error);
    _lastTriple = _triple;
    _errorController.add(_triple.error);
  }

  void _addHistory(Triple<State, Error> observableCache) {
    if (_historyIndex == _history.length) {
      _history.add(observableCache);
      _historyIndex = _history.length;
    } else {
      final newList = _history.take(_historyIndex).toList()
        ..add(observableCache);
      _history.clear();
      _history.addAll(newList);
    }
  }

  void undo({TripleEvent? when}) {
    if (when != null && _historyIndex > 1) {
      for (var candidate in _history.reversed) {
        if (candidate.event == when) {
          _historyIndex = _history.indexOf(candidate) + 1;
          _triple = candidate;
          _propage(_triple);
          break;
        }
      }
    } else if (_history.isNotEmpty && when == null) {
      _historyIndex--;
      _triple = _history[_historyIndex];
      _propage(_triple);
    }
  }

  void redo({TripleEvent? when}) {
    if (when != null) {
      for (var candidate in _history.sublist(_historyIndex - 1)) {
        if (candidate.event == when) {
          _historyIndex = _history.indexOf(candidate) + 1;
          _triple = candidate;
          _propage(_triple);
          return;
        }
      }
    }

    if (_historyIndex + 1 < _history.length) {
      _historyIndex++;
      _triple = _history[_historyIndex];
      _propage(_triple);
    } else if (_triple != _lastTriple) {
      _historyIndex++;
      _triple = _lastTriple;
      _propage(_triple);
    }
  }

  void _propage(Triple<State, Error> _triple) {
    if (_triple.event == TripleEvent.state) {
      _stateController.add(_triple.state);
    } else if (_triple.event == TripleEvent.error) {
      _errorController.add(_triple.error);
    } else if (_triple.event == TripleEvent.loading) {
      _loadingController.add(_triple.isLoading);
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

class Triple<State extends Object, Error extends Object> {
  final State state;
  final Error? error;
  final bool isLoading;
  final TripleEvent event;

  Triple({
    required this.state,
    this.error,
    this.isLoading = false,
    this.event = TripleEvent.state,
  });

  Triple<State, Error> copyWith(
      {State? state,
      Error? error,
      bool? isLoading,
      int? index,
      TripleEvent? event}) {
    return Triple<State, Error>(
      state: state ?? this.state,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      event: event ?? this.event,
    );
  }
}

enum TripleEvent { state, loading, error }
