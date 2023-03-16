///[Triple] class
// ignore_for_file: public_member_api_docs

class Triple<State> {
  ///The variable [state] it's the type [State]
  final State state;

  ///The variable [error] it's the type [Error]
  final dynamic error;

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

  Triple<State> copyWith({
    State? state,
    dynamic error,
    bool? isLoading,
    int? index,
    TripleEvent? event,
  }) {
    return Triple<State>(
      state: state ?? this.state,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      event: event ?? this.event,
    );
  }

  Triple<State> clearError() {
    return Triple<State>(
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
