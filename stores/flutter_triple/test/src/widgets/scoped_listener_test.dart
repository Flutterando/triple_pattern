import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/src/widgets/scoped_listener.dart';

import '../mocks/mocks.dart';

void main() {
  group('ScopedListener', () {
    late MockStore store;

    setUpAll(() {
      store = MockStore();
    });

    testWidgets('should throw an error if no listeners are defined',
        (tester) async {
      expect(
        () => MockWidget(
          child: ScopedListener<MockStore, String, int>(
            store: store,
            child: Container(),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
        'should throw an error if distinct is defined but onState is not',
        (tester) async {
      expect(
        () => MockWidget(
          child: ScopedListener<MockStore, String, int>(
            store: store,
            distinct: (state) => state,
            child: Container(),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('should throw an error if filter is defined but onState is not',
        (tester) async {
      expect(
        () => MockWidget(
          child: ScopedListener<MockStore, String, int>(
            store: store,
            filter: (state) => true,
            child: Container(),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('should render child widget', (tester) async {
      var count = 0;

      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, String, int>(
            store: store,
            onState: (context, state) {
              count++;
            },
            child: Container(),
          ),
        ),
      );
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should trigger onState when state changes', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, String, int>(
            store: store,
            onState: (context, state) {
              count++;
            },
            child: Container(),
          ),
        ),
      );

      store.updateWithState(1);
      await tester.pump();

      expect(count, equals(1));
    });

    testWidgets(
        'should not trigger onState when state changes but filter returns false',
        (tester) async {
      var count = 0;
      await tester.pumpWidget(
        ScopedListener<MockStore, String, int>(
          store: store,
          onState: (context, state) {
            count++;
          },
          filter: (state) => state > 1,
          child: Container(),
        ),
      );

      store.updateWithState(1);
      await tester.pump();

      expect(count, equals(0));
    });

    testWidgets('should trigger onError when error is thrown', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MockWidget(
          child: ScopedListener<MockStore, String, int>(
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
