import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

import '../mocks/mocks.dart';

void main() {
  group('ScopedConsumer', () {
    late MockStore store;

    setUpAll(() {
      store = MockStore();
    });

    testWidgets(
        'throws AssertionError if either onState, onError, or onLoading is not provided',
        (tester) async {
      expect(() => ScopedConsumer(store: store), throwsAssertionError);
    });

    testWidgets('calls onLoading initially and onState when state changes',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onStateBuilder: (context, state) => Text('state $state'),
            onLoadingBuilder: (context) => const Text('loading'),
            onErrorBuilder: (context, error) => Text('$error'),
          ),
        ),
      );
      store.updateWithState(1);

      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 1'), findsOneWidget);

      store.updateWithState(2);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 2'), findsOneWidget);
    });

    testWidgets('calls onError when an error is emitted', (tester) async {
      store.updateWithError('First');

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onErrorBuilder: (context, error) => Text('Error: $error'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Error: First'), findsOneWidget);
    });

    testWidgets('calls onLoading when loading is emitted', (tester) async {
      store.enableLoading();

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onLoadingBuilder: (context) => const Text('loading'),
            onStateBuilder: (context, state) => Text('state $state'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('loading'), findsOneWidget);
      expect(find.text('state'), findsNothing);
    });
  });
}
