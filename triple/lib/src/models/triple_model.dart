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

  Triple<Error, State> copyWith({State? state, Error? error, bool? isLoading, int? index, TripleEvent? event}) {
    return Triple<Error, State>(
      state: state ?? this.state,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      event: event ?? this.event,
    );
  }

  @override
  String toString() {
    return '$event: $state | $error | $isLoading';
  }
}

enum TripleEvent { state, loading, error }
