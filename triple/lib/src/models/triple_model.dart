///[Triple] class
// ignore_for_file: public_member_api_docs

class Triple<Error extends Object, State extends Object> {
  ///The variable [state] it's the type [State]
  final State state;

  ///The variable [error] it's the type [Error]
  final Error? error;

  ///The variable [isLoading] it's the type [bool]
  final bool isLoading;

  ///The variable [event] it's the type [TripleEvent]
  final TripleEvent event;

  ///[Triple] construct class
  Triple({
    required this.state,
    this.error,
    this.isLoading = false,
    this.event = TripleEvent.state,
  });

  Triple<Error, State> copyWith({
    State? state,
    Error? error,
    bool? isLoading,
    int? index,
    TripleEvent? event,
  }) {
    return Triple<Error, State>(
      state: state ?? this.state,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      event: event ?? this.event,
    );
  }

  Triple<Error, State> clearError() {
    return Triple<Error, State>(
      state: state,
      isLoading: isLoading,
      event: event,
    );
  }

  @override
  String toString() {
    return '$event: $state | $error | $isLoading';
  }
}

enum TripleEvent { state, loading, error }
