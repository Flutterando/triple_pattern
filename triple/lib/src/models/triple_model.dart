class Triple<State extends Object, Error extends Object> {
  final State state;
  final Error? error;
  final bool loading;
  final TripleEvent event;

  Triple({
    required this.state,
    this.error,
    this.loading = false,
    this.event = TripleEvent.state,
  });

  Triple<State, Error> copyWith(
      {State? state,
      Error? error,
      bool? loading,
      int? index,
      TripleEvent? event}) {
    return Triple<State, Error>(
      state: state ?? this.state,
      error: error ?? this.error,
      loading: loading ?? this.loading,
      event: event ?? this.event,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Triple<State, Error> &&
        o.state == state &&
        o.error == error &&
        o.loading == loading &&
        o.event == event;
  }

  @override
  int get hashCode {
    return state.hashCode ^ error.hashCode ^ loading.hashCode ^ event.hashCode;
  }
}

enum TripleEvent { state, loading, error }
