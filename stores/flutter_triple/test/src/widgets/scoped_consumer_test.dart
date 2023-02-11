import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

import '../mocks/mocks.dart';

void main() {
  group('ScopedConsumer', () {
    late MockStore store;

    setUp(() {
      store = MockStore();
    });

    testWidgets(
        'throws AssertionError if either onState, onError, or onLoading is not provided',
        (tester) async {
      expect(() => ScopedConsumer(store: store), throwsAssertionError);
    });

    testWidgets('throws AssertionError if either builder is not provided',
        (tester) async {
      expect(
        () => ScopedConsumer(
          store: store,
          onStateListener: (_, __) {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('calls onStateBuilder when an state is emitted',
        (tester) async {
      var onStateListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onStateBuilder: (context, state) => Text('state $state'),
            onStateListener: (context, state) => onStateListenerCalled = true,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
      expect(onStateListenerCalled, true);
    });

    testWidgets('calls onError when an error is emitted', (tester) async {
      var onErrorListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onErrorBuilder: (context, error) => Text('Error: $error'),
            onErrorListener: (context, error) => onErrorListenerCalled = true,
          ),
        ),
      );
      store.updateWithError('true');

      await tester.pump();

      expect(find.text('Error: true'), findsOneWidget);
      expect(onErrorListenerCalled, true);
    });

    testWidgets('calls onLoading when loading is emitted', (tester) async {
      var onLoadingListenerCalled = false;
      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onLoadingBuilder: (context) => const Text('loading'),
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = isLoading,
          ),
        ),
      );
      store.enableLoading();
      await tester.pump();
      expect(find.text('loading'), findsOneWidget);
      expect(onLoadingListenerCalled, true);
    });

    testWidgets(
        'calls onStateBuilder, onErrorListener and onLoadingListener when an state, load and error is emitted',
        (tester) async {
      var onStateListenerCalled = false;
      var onLoadingListenerCalled = false;
      var onErrorListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onStateListener: (context, state) => onStateListenerCalled = true,
            onErrorListener: (context, error) => onErrorListenerCalled = true,
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = true,
            onStateBuilder: (context, state) => Text('State: $state'),
            onErrorBuilder: (context, error) => Text('Error: $error'),
            onLoadingBuilder: (context) => const Text('Loading'),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();
      store.enableLoading();
      await tester.pump();
      store.updateWithError('true');
      await tester.pump();

      expect(onStateListenerCalled, true);
      expect(onLoadingListenerCalled, true);
      expect(onErrorListenerCalled, true);

      expect(find.text('Error: true'), findsOneWidget);
    });
  });
}
