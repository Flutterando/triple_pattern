import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

import '../mocks/mocks.dart';

void main() {
  group('ScopedListener', () {
    late MockStore store;

    setUpAll(() {
      store = MockStore();
    });

    testWidgets('should throw an error if no listeners are defined',
        (tester) async {
      // ignore: prefer_typing_uninitialized_variables
      var nullableListener;
      expect(
        () => MockWidget(
          child: TripleListener<MockStore, String, int>(
            store: store,
            listener: nullableListener,
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
          child: TripleListener<MockStore, String, int>(
            store: store,
            distinct: (triple) => triple,
            listener: (context, triple) {},
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
          child: TripleListener<MockStore, String, int>(
            store: store,
            listener: (context, triple) {},
            filter: (triple) => true,
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
          child: TripleListener<MockStore, String, int>(
            store: store,
            listener: (context, triple) {
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
          child: TripleListener<MockStore, String, int>(
            store: store,
            listener: (context, triple) {
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
        TripleListener<MockStore, String, int>(
          store: store,
          listener: (context, triple) {
            count++;
          },
          filter: (state) => state.state > 1,
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
          child: TripleListener<MockStore, String, int>(
            store: store,
            listener: (context, triple) {
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
