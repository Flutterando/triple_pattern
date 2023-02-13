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
      var onLoadingListenerCalled = false;
      var onErrorListenerCalled = false;
      var onStateListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onStateBuilder: (context, state) => Text('state $state'),
            onStateListener: (context, state) => onStateListenerCalled = true,
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = true,
            onErrorListener: (context, error) => onErrorListenerCalled = true,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
      expect(onStateListenerCalled, true);
      expect(onErrorListenerCalled, false);
      expect(onLoadingListenerCalled, false);
    });
    testWidgets('calls onStateBuilder with transition when an state is emitted',
        (tester) async {
      var onLoadingListenerCalled = false;
      var onErrorListenerCalled = false;
      var onStateListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>.transition(
            store: store,
            onStateBuilder: (context, state) => Text('state $state'),
            onStateListener: (context, state) => onStateListenerCalled = true,
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = true,
            onErrorListener: (context, error) => onErrorListenerCalled = true,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
      expect(onStateListenerCalled, true);
      expect(onErrorListenerCalled, false);
      expect(onLoadingListenerCalled, false);
    });

    testWidgets('calls onStateBuilder when filted and an state is emitted',
        (tester) async {
      var onLoadingListenerCalled = false;
      var onErrorListenerCalled = false;
      var onStateListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onStateBuilder: (context, state) => Text('state $state'),
            onStateListener: (context, state) => onStateListenerCalled = true,
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = true,
            onErrorListener: (context, error) => onErrorListenerCalled = true,
            filter: (state) => true,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
      expect(onStateListenerCalled, true);
      expect(onErrorListenerCalled, false);
      expect(onLoadingListenerCalled, false);
    });

    testWidgets(
        'onStateBuilder not called when state is filtered and emitted is true',
        (tester) async {
      var onLoadingListenerCalled = false;
      var onErrorListenerCalled = false;
      var onStateListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onStateBuilder: (context, state) => Text('state $state'),
            onStateListener: (context, state) => onStateListenerCalled = true,
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = true,
            onErrorListener: (context, error) => onErrorListenerCalled = true,
            filter: (state) => true,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsOneWidget);
      expect(onStateListenerCalled, true);
      expect(onErrorListenerCalled, false);
      expect(onLoadingListenerCalled, false);
    });

    testWidgets(
        'onStateBuilder not called when state is filtered and emitted is false',
        (tester) async {
      var onLoadingListenerCalled = false;
      var onErrorListenerCalled = false;
      var onStateListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onStateBuilder: (context, state) => Text('state $state'),
            onStateListener: (context, state) => onStateListenerCalled = true,
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = true,
            onErrorListener: (context, error) => onErrorListenerCalled = true,
            filter: (state) => false,
          ),
        ),
      );
      store.updateWithValue(1);

      await tester.pump();
      expect(find.text('state 1'), findsNothing);
      expect(onStateListenerCalled, false);
      expect(onErrorListenerCalled, false);
      expect(onLoadingListenerCalled, false);
    });

    // testWidgets('calls onStateBuilder when distinct and an state is emitted',
    //     (tester) async {
    //   final _store = MockDistinctStore();
    //   var onLoadingListenerCalled = false;
    //   var onErrorListenerCalled = false;
    //   var onStateListenerCalled = false;

    //   await tester.pumpWidget(
    //     MockWidget(
    //       child: ScopedConsumer<MockDistinctStore, String, CountState>(
    //         store: _store,
    //         onStateBuilder: (context, state) => Text('state $state'),
    //         onErrorBuilder: (context, error) => Text('error $error'),
    //         onStateListener: (context, state) => onStateListenerCalled = true,
    //         onLoadingListener: (context, isLoading) =>
    //             onLoadingListenerCalled = true,
    //         onErrorListener: (context, error) => onErrorListenerCalled = true,
    //         distinct: (state) => 1,
    //       ),
    //     ),
    //   );
    //   store.updateWithValue(1);
    //   await tester.pump();
    //   store.updateWithValue(1);
    //   await tester.pump();
    //   store.updateWithValue(1);
    //   await tester.pump();
    //   store.updateWithValue(0);
    //   await tester.pump();

    //   expect(find.text('state 0'), findsOneWidget);
    //   expect(onStateListenerCalled, true);
    //   expect(onErrorListenerCalled, false);
    //   expect(onLoadingListenerCalled, false);
    // });

    // testWidgets(
    //     'not called onStateBuilder when distinct and an state is emitted',
    //     (tester) async {
    //   var onLoadingListenerCalled = false;
    //   var onErrorListenerCalled = false;
    //   var onStateListenerCalled = false;

    //   await tester.pumpWidget(
    //     MockWidget(
    //       child: ScopedConsumer<MockStore, String, int>(
    //         store: store,
    //         onStateBuilder: (context, state) => Text('state $state'),
    //         onStateListener: (context, state) => onStateListenerCalled = true,
    //         onLoadingListener: (context, isLoading) =>
    //             onLoadingListenerCalled = true,
    //         onErrorListener: (context, error) => onErrorListenerCalled = true,
    //         distinct: (state) => 0,
    //       ),
    //     ),
    //   );
    //   store.updateWithValue(0);
    //   await tester.pump();
    //   store.updateWithValue(0);
    //   await tester.pump();
    //   store.updateWithValue(0);
    //   await tester.pump();
    //   store.updateWithValue(1);
    //   await tester.pump();

    //   expect(find.text('state 0'), findsOneWidget);
    //   expect(onStateListenerCalled, true);
    //   expect(onErrorListenerCalled, false);
    //   expect(onLoadingListenerCalled, false);
    // });

    // testWidgets('called any builder when distinct and an state is emitted',
    //     (tester) async {
    //   var onLoadingListenerCalled = false;
    //   var onErrorListenerCalled = false;
    //   var onStateListenerCalled = false;

    //   await tester.pumpWidget(
    //     MockWidget(
    //       child: ScopedConsumer<MockStore, String, int>(
    //         store: store,
    //         onErrorBuilder: (context, state) => const Text('error'),
    //         onStateBuilder: (context, state) => Text('state $state'),
    //         onStateListener: (context, state) => onStateListenerCalled = true,
    //         onLoadingListener: (context, isLoading) =>
    //             onLoadingListenerCalled = true,
    //         onErrorListener: (context, error) => onErrorListenerCalled = true,
    //         distinct: (state) => 1,
    //       ),
    //     ),
    //   );
    //   store.updateWithValue(0);
    //   await tester.pump();
    //   store.updateWithValue(0);
    //   await tester.pump();
    //   store.updateWithValue(0);
    //   await tester.pump();
    //   store.updateWithValue(1);
    //   await tester.pump();

    //   expect(find.text('error'), findsOneWidget);
    //   expect(onStateListenerCalled, false);
    //   expect(onErrorListenerCalled, true);
    //   expect(onLoadingListenerCalled, false);
    // });

    // testWidgets(
    //     'onStateBuilder not called when state with filter and distinct is true',
    //     (tester) async {
    //   var onLoadingListenerCalled = false;
    //   var onErrorListenerCalled = false;
    //   var onStateListenerCalled = false;

    //   await tester.pumpWidget(
    //     MockWidget(
    //       child: ScopedConsumer<MockStore, String, int>(
    //         store: store,
    //         onStateBuilder: (context, state) => Text('state $state'),
    //         onStateListener: (context, state) => onStateListenerCalled = true,
    //         onLoadingListener: (context, isLoading) =>
    //             onLoadingListenerCalled = true,
    //         onErrorListener: (context, error) => onErrorListenerCalled = true,
    //         filter: (state) => true,
    //         distinct: (state) => 1,
    //       ),
    //     ),
    //   );
    //   store.updateWithValue(1);

    //   await tester.pump();
    //   expect(find.text('state 1'), findsOneWidget);
    //   expect(onStateListenerCalled, true);
    //   expect(onErrorListenerCalled, false);
    //   expect(onLoadingListenerCalled, false);
    // });

    testWidgets('calls onError when an error is emitted', (tester) async {
      var onLoadingListenerCalled = false;
      var onErrorListenerCalled = false;
      var onStateListenerCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onErrorBuilder: (context, error) => Text('Error: $error'),
            onErrorListener: (context, error) => onErrorListenerCalled = true,
            onStateListener: (context, state) => onStateListenerCalled = true,
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = true,
          ),
        ),
      );
      store.updateWithError('true');

      await tester.pump();

      expect(find.text('Error: true'), findsOneWidget);
      expect(onErrorListenerCalled, true);
      expect(onLoadingListenerCalled, false);
      expect(onStateListenerCalled, false);
    });

    testWidgets('calls onLoading when loading is emitted', (tester) async {
      var onLoadingListenerCalled = false;
      var onErrorListenerCalled = false;
      var onStateListenerCalled = false;
      await tester.pumpWidget(
        MockWidget(
          child: ScopedConsumer<MockStore, String, int>(
            store: store,
            onLoadingBuilder: (context) => const Text('loading'),
            onLoadingListener: (context, isLoading) =>
                onLoadingListenerCalled = isLoading,
            onErrorListener: (context, error) => onErrorListenerCalled = true,
            onStateListener: (context, state) => onStateListenerCalled = true,
          ),
        ),
      );
      store.enableLoading();
      await tester.pump();
      expect(find.text('loading'), findsOneWidget);
      expect(onLoadingListenerCalled, true);
      expect(onErrorListenerCalled, false);
      expect(onStateListenerCalled, false);
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
