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
}

enum TripleEvent { state, loading, error }
