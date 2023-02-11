import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';
import '../mocks/mocks.dart';

void main() {
  group('ScopedBuilder', () {
    late MockStore store;

    setUpAll(() {
      store = MockStore();
    });

    testWidgets('calls builder when state changes', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: TripleBuilder<MockStore, String, int>(
            store: store,
            builder: (context, triple) => Text('state ${triple.state}'),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('state 1'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();

      expect(find.text('state 2'), findsOneWidget);
    });

    testWidgets('calls builder when an error is emitted', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: TripleBuilder<MockStore, String, int>(
            store: store,
            builder: (context, triple) => Text('${triple.error}'),
          ),
        ),
      );

      store.updateWithError('error 1');
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('error 1'), findsOneWidget);
    });

    testWidgets('calls builder when loading is emitted', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: TripleBuilder<MockStore, String, int>(
            store: store,
            builder: (context, triple) => const Text('loading'),
          ),
        ),
      );

      store.enableLoading();
      await tester.pump();

      expect(find.text('loading'), findsOneWidget);
    });
  });
}
