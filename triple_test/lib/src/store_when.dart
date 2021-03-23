import 'package:mocktail/mocktail.dart';
import 'package:triple/triple.dart';
import 'package:triple_test/src/store_mock.dart';

void whenObserve<Error extends Object, State extends Object>(
  MockStore<Error, State> store, {
  required Function() input,
  Duration delay = const Duration(milliseconds: 0),
  List<Triple<Error, State>> triples = const [],
  State? initialState,
}) {
  if (initialState != null) {
    when(() => store.state).thenReturn(initialState);
    when(() => store.error).thenReturn(null);
    when(() => store.isLoading).thenReturn(false);
    when(() => store.triple).thenReturn(Triple<Error, State>(state: initialState));
  }

  when(input).thenAnswer((invocation) async {
    for (var triple in triples) {
      when(() => store.triple).thenReturn(triple);
      if (triple.event == TripleEvent.state) {
        when(() => store.state).thenReturn(triple.state);
      } else if (triple.event == TripleEvent.loading) {
        when(() => store.isLoading).thenReturn(triple.isLoading);
      } else if (triple.event == TripleEvent.error) {
        when(() => store.error).thenReturn(triple.error);
      }
      store.dispatcherTriple(triple);
      await Future.delayed(delay);
    }
  });
}
