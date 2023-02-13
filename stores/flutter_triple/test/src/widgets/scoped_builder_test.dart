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

    testWidgets('calls onState when distinct is true and an state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
            distinct: (state) => state != 0,
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();
      store.updateWithValue(1);
      await tester.pump();
      store.updateWithValue(1);
      await tester.pump();
      store.updateWithValue(0);
      await tester.pump();

      expect(find.text('state 0'), findsOneWidget);
    });

    testWidgets(
        'not called onState when distinct is false and an state is emitted',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
            distinct: (state) => 10,
          ),
        ),
      );

      expect(store.state, 0);
      expect(find.text('state 0'), findsOneWidget);
    });

    testWidgets('calls onError when an error is emitted', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onError: (context, error) => Text('$error'),
          ),
        ),
      );

      store.updateWithError('error');
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
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
          ),
        ),
      );

      store.enableLoading();
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
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
          ),
        ),
      );

      store.enableLoading();
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
}
