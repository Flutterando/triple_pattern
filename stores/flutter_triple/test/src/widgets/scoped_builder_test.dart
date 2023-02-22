import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';
import '../mocks/mocks.dart';

void main() {
  group('ScopedBuilder', () {
    late MockStore store;

    setUp(() {
      store = MockStore();
    });

    testWidgets(
        '''throws AssertionError if either onState, onError, or onLoading is not provided''',
        (tester) async {
      expect(() => ScopedBuilder(store: store), throwsAssertionError);
    });

    testWidgets('calls onState when state changes', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('state 1'), findsOneWidget);
    });

    testWidgets('calls onState when states changes', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('state 1'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();

      expect(find.text('state 2'), findsOneWidget);

      store.updateWithValue(3);
      await tester.pump();

      expect(find.text('state 3'), findsOneWidget);
    });

    testWidgets('calls onState when states changes with distincted',
        (tester) async {
      var rebuildCount = 0;
      final _store = MockDistinctStore();

      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockDistinctStore, String, CountState>(
            store: _store,
            onState: (context, state) {
              rebuildCount++;
              return Text('$rebuildCount');
            },
          ),
        ),
      );
      expect(rebuildCount, equals(1));
      expect(find.text('1'), findsOneWidget);

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      expect(rebuildCount, equals(7));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('should trigger onState when states changes with distincted',
        (tester) async {
      var rebuildCount = 0;
      final _store = MockDistinctStore();

      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockDistinctStore, String, CountState>(
            store: _store,
            distinct: (state) => state.id,
            onState: (context, state) {
              rebuildCount++;
              return Text('$rebuildCount');
            },
          ),
        ),
      );
      expect(rebuildCount, equals(1));
      expect(find.text('1'), findsOneWidget);

      _store
        ..updateWithValue(1)
        ..updateWithValue(1)
        ..updateWithValue(1)
        ..updateWithValue(1)
        ..updateWithValue(1)
        ..updateWithValue(1);
      await tester.pump();

      expect(rebuildCount, equals(2));
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('calls onState and onLoading when state changes',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 1'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 2'), findsOneWidget);
    });

    testWidgets('calls onState, onLoading and onError when state changes',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 1'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 2'), findsOneWidget);

      store.updateWithError('error');
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('calls onState when filter is true and an state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            filter: (state) => true,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
    });

    testWidgets('calls onState when filter is false and an state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            filter: (state) => false,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsNothing);
    });

    testWidgets('calls onState when filter is true and an state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
            filter: (state) => true,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
    });

    testWidgets(
        '''onStateBuilder not called when state is emitted and Notfilter is applied''',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
            filter: (state) => false,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsNothing);
    });

    testWidgets('calls onError when an error is emitted', (tester) async {
      store.updateWithError('error');
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onError: (context, error) {
              if (error != null) {
                return Text(error);
              } else {
                return const Text('no error');
              }
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('calls onError and onState when an error and state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onError: (context, error) => Text('$error'),
            onState: (context, state) => const Text('state'),
          ),
        ),
      );

      store.updateWithError('error');
      await tester.pump();
      expect(find.text('state'), findsNothing);
      expect(find.text('error'), findsOneWidget);

      store.updateWithValue(1);
      await tester.pump();
      expect(find.text('state'), findsOneWidget);
      expect(find.text('error'), findsNothing);
    });

    testWidgets('calls onLoading when loading is emitted', (tester) async {
      store.enableLoading();
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('loading'), findsOneWidget);
    });

    testWidgets('calls onLoading and onState when an load and state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
            onState: (context, state) => const Text('state'),
          ),
        ),
      );

      store.enableLoading();
      await tester.pump();
      expect(find.text('loading'), findsOneWidget);

      store.updateWithValue(1);
      await tester.pump();
      expect(find.text('state'), findsOneWidget);
    });

    testWidgets('calls onLoading and onError when an load and error is emitted',
        (tester) async {
      store.enableLoading();

      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('loading'), findsOneWidget);

      store.updateWithError('error');
      await tester.pump();
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets(
        'not calls onLoading and onState when an load and state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
            onState: (context, state) => const Text('state'),
          ),
        ),
      );

      store.disableLoading();
      await tester.pump();
      expect(find.text('loading'), findsNothing);

      store.updateWithValue(1);
      await tester.pump();
      expect(find.text('state'), findsOneWidget);
    });

    testWidgets(
        '''calls onState when value is emitted and calls onLoading when loading is emitted''',
        (tester) async {
      store.updateWithValue(1);

      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
            onState: (context, state) => Text('state $state'),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);

      store.enableLoading();
      await tester.pump();
      expect(find.text('loading'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();
      expect(find.text('loading'), findsNothing);
      expect(find.text('state 2'), findsOneWidget);
    });
  });
  group('ScopedBuilder.transition', () {
    late MockStore store;

    setUp(() {
      store = MockStore();
    });

    testWidgets(
        '''throws AssertionError if either onState, onError, or onLoading is not provided''',
        (tester) async {
      expect(
        () => ScopedBuilder.transition(store: store),
        throwsAssertionError,
      );
    });

    testWidgets('calls onState when state changes', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onState: (context, state) => Text('state $state'),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('state 1'), findsOneWidget);
    });

    testWidgets('calls onState when states changes', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onState: (context, state) => Text('state $state'),
            transition: (context, child) => AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              child: child,
            ),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('state 1'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();

      expect(find.text('state 2'), findsOneWidget);

      store.updateWithValue(3);
      await tester.pump();

      expect(find.text('state 3'), findsOneWidget);
    });

    testWidgets('calls onState when states changes with distincted',
        (tester) async {
      var rebuildCount = 0;
      final _store = MockDistinctStore();

      await tester.pumpWidget(
        MockWidget(
          child:
              ScopedBuilder<MockDistinctStore, String, CountState>.transition(
            store: _store,
            onState: (context, state) {
              rebuildCount++;
              return Text('$rebuildCount');
            },
          ),
        ),
      );
      expect(rebuildCount, equals(1));
      expect(find.text('1'), findsOneWidget);

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      _store.updateWithValue(1);
      await tester.pump();

      expect(rebuildCount, equals(7));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('should trigger onState when states changes with distincted',
        (tester) async {
      var rebuildCount = 0;
      final _store = MockDistinctStore();

      await tester.pumpWidget(
        MockWidget(
          child:
              ScopedBuilder<MockDistinctStore, String, CountState>.transition(
            store: _store,
            distinct: (state) => state.id,
            onState: (context, state) {
              rebuildCount++;
              return Text('$rebuildCount');
            },
          ),
        ),
      );
      expect(rebuildCount, equals(1));
      expect(find.text('1'), findsOneWidget);

      _store
        ..updateWithValue(1)
        ..updateWithValue(1)
        ..updateWithValue(1)
        ..updateWithValue(1)
        ..updateWithValue(1)
        ..updateWithValue(1);
      await tester.pump();

      expect(rebuildCount, equals(2));
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('calls onState and onLoading when state changes',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
            transition: (context, child) => AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              child: child,
            ),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 1'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 2'), findsOneWidget);
    });

    testWidgets('calls onState, onLoading and onError when state changes',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
            transition: (context, child) => AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              child: child,
            ),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 1'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 2'), findsOneWidget);

      store.updateWithError('error');
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('calls onState when filter is true and an state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onState: (context, state) => Text('state $state'),
            filter: (state) => true,
            transition: (context, child) => AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              child: child,
            ),
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
    });

    testWidgets('calls onState when filter is false and an state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onState: (context, state) => Text('state $state'),
            filter: (state) => false,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsNothing);
    });

    testWidgets('calls onState when filter is true and an state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
            filter: (state) => true,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
    });

    testWidgets(
        '''onStateBuilder not called when state is emitted and Notfilter is applied''',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
            filter: (state) => false,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsNothing);
    });

    testWidgets('calls onError when an error is emitted', (tester) async {
      store.updateWithError('error');

      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onError: (context, error) => Text(error ?? ''),
            transition: (context, child) => AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              child: child,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('calls onError and onState when an error and state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onError: (context, error) => Text('$error'),
            onState: (context, state) => const Text('state'),
            transition: (context, child) => AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              child: child,
            ),
          ),
        ),
      );

      store.updateWithError('error');
      await tester.pump();
      expect(find.text('state'), findsNothing);
      expect(find.text('error'), findsOneWidget);

      store.updateWithValue(1);
      await tester.pump();
      expect(find.text('state'), findsOneWidget);
      expect(find.text('error'), findsNothing);
    });

    testWidgets('calls onLoading when loading is emitted', (tester) async {
      store.enableLoading();

      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onLoading: (context) => const Text('loading'),
            transition: (context, child) => AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              child: child,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('loading'), findsOneWidget);
    });

    testWidgets('calls onLoading and onState when an load and state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onLoading: (context) => const Text('loading'),
            onState: (context, state) => const Text('state'),
            transition: (context, child) => AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              child: child,
            ),
          ),
        ),
      );

      store.enableLoading();
      await tester.pump();
      expect(find.text('loading'), findsOneWidget);

      store.updateWithValue(1);
      await tester.pump();
      expect(find.text('state'), findsOneWidget);
    });

    testWidgets('calls onLoading and onError when an load and error is emitted',
        (tester) async {
      store.enableLoading();

      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('loading'), findsOneWidget);

      store.updateWithError('error');
      await tester.pump();
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets(
        'not calls onLoading and onState when an load and state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onLoading: (context) => const Text('loading'),
            onState: (context, state) => const Text('state'),
          ),
        ),
      );

      store.disableLoading();
      await tester.pump();
      expect(find.text('loading'), findsNothing);

      store.updateWithValue(1);
      await tester.pump();
      expect(find.text('state'), findsOneWidget);
    });

    testWidgets(
        '''calls onState when value is emitted and calls onLoading when loading is emitted''',
        (tester) async {
      store.updateWithValue(1);

      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>.transition(
            store: store,
            onLoading: (context) => const Text('loading'),
            onState: (context, state) => Text('state $state'),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);

      store.enableLoading();
      await tester.pump();
      expect(find.text('loading'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();
      store.disableLoading();
      await tester.pump();
      expect(find.text('loading'), findsNothing);
      expect(find.text('state 2'), findsOneWidget);
    });
  });
}
