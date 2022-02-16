import 'dart:async';

import 'package:meta/meta.dart';
import 'package:triple/triple.dart';
import 'package:test/test.dart' as test;

/// Creates a new `store`-specific test case with the given [description].
/// [storeTest] will handle asserting that the `store` emits the [expect]ed
/// states (in order) after [act] is executed.
/// [storeTest] also handles ensuring that no additional states are emitted
/// by closing the `store` stream before evaluating the [expect]ation.
///
/// [build] should be used for all `store` initialization and preparation
/// and must return the `store` under test.
///
/// [act] is an optional callback which will be invoked with the `store` under
/// test and should be used to interact with the `store`.
///
/// [expect] is an optional `Function` that returns a `Matcher` which the `store`
/// under test is expected to emit after [act] is executed.
///
/// [verify] is a callback which is invoked after [expect]
/// and can be used for additional verification/assertions.
/// [verify] is called with the `store` returned by [build].
///
/// ```dart
/// storeTest(
///   'Counterstore emits [1] when update method is called',
///   build: () => CounterStore(),
///   act: (store) => store.update(1),
///   expect: () => [1],
/// );
/// ```
///
/// [storeTest] can also be used to [verify] internal store functionality.
///
/// ```dart
/// storeTest(
///   'Counterstore emits [1] when update method is called',
///   build: () => CounterStore(),
///   act: (store) => store.update(1),
///   expect: () => [1],
///   verify: (_) {
///     verify(() => repository.someMethod(any())).called(1);
///   }
/// );
/// ```
@isTest
FutureOr<void> storeTest<T extends Store>(
  String description, {
  required T Function() build,
  Function(T store)? act,
  required Function() expect,
  Duration? wait,
  Function(T store)? verify,
}) async {
  test.test(description, () async {
    final completer = Completer();
    final store = build();
    int i = 0;
    final _list = expect();
    final actualList = <String>[];
    Disposer disposer;
    final expectList = _list is List ? _list : List.from([_list]);
    bool isFinished = false;
    await runZonedGuarded(() async {
      testTriple(Triple triple, dynamic value) {
        if (isFinished) {
          return;
        }

        actualList.add('${triple.event.toString().replaceFirst('TripleEvent.', '')}($value)');

        if (i >= expectList.length) {
          throw test.TestFailure('''Expected: $expectList
  Actual: $actualList

''');
        }

        final matcher = expectList[i];

        test.expect(matcher is TripleMatcher ? triple : value, matcher);
        i++;
        if (i >= expectList.length && !completer.isCompleted) {
          completer.complete(true);
        }
      }

      // testTriple(store.triple, store.triple.state);

      disposer = store.observer(
        onState: (value) => testTriple(store.triple, value),
        onError: (value) => testTriple(store.triple, value),
        onLoading: (value) => testTriple(store.triple, value),
      );
      act?.call(store);
      await Future.wait([
        completer.future,
        Future.delayed(wait ?? Duration.zero),
      ]);
      isFinished = true;
      disposer.call();
      try {
        verify?.call(store);
      } on test.TestFailure catch (e) {
        throw VerifyError(e.message);
      }
    }, (Object error, _) {
      if (error is test.TestFailure) {
        // ignore: only_throw_errors
        throw test.TestFailure(
          '''Expected: $expectList
  Actual: $actualList

''',
        );
      } else {
        throw error;
      }
    });
  });
}

const tripleState = TripleMatcher(TripleEvent.state);
const tripleError = TripleMatcher(TripleEvent.error);
const tripleLoading = TripleMatcher(TripleEvent.loading);

class TripleMatcher extends test.Matcher {
  final TripleEvent event;
  const TripleMatcher(this.event);

  @override
  test.Description describe(test.Description description) => description.add('Triple State');

  @override
  bool matches(covariant Triple triple, Map matchState) {
    return triple.event == event;
  }

  @override
  String toString() {
    return '${event.toString().replaceFirst('TripleEvent', 'TripleMatcher')}';
  }
}

class VerifyError {
  final String? message;
  VerifyError(this.message);

  @override
  String toString() => message.toString();
}
