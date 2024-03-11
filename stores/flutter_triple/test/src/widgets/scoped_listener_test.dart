import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/src/widgets/scoped_listener.dart';

import '../mocks/mocks.dart';

void main() {
  group('ScopedListener', () {
    late MockStore store;

    setUp(() {
      store = MockStore();
    });

    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            onState: (context, state) {},
            child: Container(),
          ),
        ),
      );
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should throw an error if no listeners are defined', (tester) async {
      expect(
        () => MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            child: Container(),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('should trigger onState when state changes with distinct', (tester) async {
      final states = [];

      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            onState: (context, state) {
              states.add(state);
            },
            distinct: (state) => state,
            child: Container(),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();
      store.updateWithValue(1);
      await tester.pump();
      store.updateWithValue(1);
      await tester.pump();

      expect(states.length, equals(1));
    });

    testWidgets('should trigger onState when states changes', (tester) async {
      final states = [];

      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            onState: (context, state) {
              states.add(state);
            },
            child: Container(),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();
      store.updateWithValue(2);
      await tester.pump();
      store.updateWithValue(3);
      await tester.pump();

      expect(states.length, equals(3));
    });
    testWidgets('should trigger onState and onLoading when states and load changes', (tester) async {
      final states = [];
      var onLoadingisCalled = false;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            onState: (context, state) {
              states.add(state);
            },
            onLoading: (context, isLoading) {
              onLoadingisCalled = isLoading;
            },
            child: Container(),
          ),
        ),
      );
      store.enableLoading();
      await tester.pump();
      store.updateWithValue(1);
      await tester.pump();
      store.updateWithValue(2);
      await tester.pump();
      store.updateWithValue(3);
      await tester.pump();

      expect(states.length, equals(3));
      expect(onLoadingisCalled, true);
    });

    testWidgets('should throw an error if distinct is defined but onState is not', (tester) async {
      expect(
        () => MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            distinct: (state) => state,
            child: Container(),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('should throw an error if filter is defined but onState is not', (tester) async {
      expect(
        () => MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            filter: (state) => true,
            child: Container(),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('should trigger onState when state changes', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            onState: (context, state) {
              count++;
            },
            child: Container(),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(count, equals(1));
    });

    testWidgets('''
should not trigger onState when state changes but filter returns false''', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        ScopedListener<MockStore, int>(
          store: store,
          onState: (context, state) {
            count++;
          },
          filter: (state) => false,
          child: Container(),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(count, equals(0));
    });
    testWidgets('''
should not trigger onState when state changes but filter and  returns false''', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        ScopedListener<MockStore, int>(
          store: store,
          onState: (context, state) {
            count++;
          },
          distinct: (state) => false,
          filter: (state) => false,
          child: Container(),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(count, equals(0));
    });

    testWidgets('should trigger onError when error is thrown', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, int>(
            store: store,
            onError: (context, error) {
              count++;
            },
            child: Container(),
          ),
        ),
      );

      store.updateWithError('');
      await tester.pump();

      expect(count, equals(1));
    });
  });
}
