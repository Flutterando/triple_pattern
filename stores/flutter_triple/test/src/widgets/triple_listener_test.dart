import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

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
          child: TripleListener<MockStore, int>(
            store: store,
            listener: (context, triple) {},
            child: Container(),
          ),
        ),
      );
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should trigger listener when state changes', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MockWidget(
          child: TripleListener<MockStore, int>(
            store: store,
            listener: (context, triple) {
              called = true;
            },
            child: Container(),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(called, equals(true));
    });

    testWidgets('''
should not trigger listener when state changes but filter returns false''', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MockWidget(
          child: TripleListener<MockStore, int>(
            store: store,
            listener: (context, triple) {
              called = true;
            },
            filter: (state) => true,
            child: Container(),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(called, equals(true));
    });

    testWidgets('''
should not trigger listener when state changes but distinct returns false''', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MockWidget(
          child: TripleListener<MockStore, int>(
            store: store,
            listener: (context, triple) {
              called = true;
            },
            distinct: (state) => true,
            child: Container(),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(called, equals(true));
    });

    testWidgets('should trigger listener when error is thrown', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MockWidget(
          child: TripleListener<MockStore, int>(
            store: store,
            listener: (context, triple) {
              called = true;
            },
            child: Container(),
          ),
        ),
      );

      store.updateWithError('');
      await tester.pump();

      expect(called, equals(true));
    });
  });
}
