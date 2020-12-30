class Triple<Error extends Object, State extends Object> {
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

  Triple<Error, State> copyWith(
      {State? state,
      Error? error,
      bool? isLoading,
      int? index,
      TripleEvent? event}) {
    return Triple<Error, State>(
      state: state ?? this.state,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      event: event ?? this.event,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Triple<Error, State> &&
        o.state == state &&
        o.error == error &&
        o.isLoading == isLoading &&
        o.event == event;
  }

  @override
  int get hashCode {
    return state.hashCode ^
        error.hashCode ^
        isLoading.hashCode ^
        event.hashCode;
  }
}

enum TripleEvent { state, loading, error }
