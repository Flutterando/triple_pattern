import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

import '../mocks/mocks.dart';

void main() {
  group('TripleConsumer', () {
    late MockStore store;

    setUpAll(() {
      store = MockStore();
    });

    testWidgets('calls listener and builder when an state is emitted',
        (tester) async {
      var called = false;

      await tester.pumpWidget(
        MockWidget(
          child: TripleConsumer<MockStore, String, int>(
            store: store,
            builder: (context, triple) => Text('State: ${triple.state}'),
            listener: (context, triple) => called = true,
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('State: 1'), findsOneWidget);
      expect(called, true);
    });

    testWidgets('calls listener and builder when an error is emitted',
        (tester) async {
      var called = false;

      store.updateWithError('First');

      await tester.pumpWidget(
        MockWidget(
          child: TripleConsumer<MockStore, String, int>(
            store: store,
            builder: (context, triple) => Text('Error: ${triple.error}'),
            listener: (context, triple) => called = true,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Error: First'), findsOneWidget);
      expect(called, true);
    });

    testWidgets('calls listener and builder when loading is emitted',
        (tester) async {
      var called = false;

      store.enableLoading();

      await tester.pumpWidget(
        MockWidget(
          child: TripleConsumer<MockStore, String, int>(
            store: store,
            builder: (context, triple) => Text('Loading: ${triple.isLoading}'),
            listener: (context, triple) => called = true,
          ),
        ),
      );

      expect(find.text('Loading: true'), findsOneWidget);
      expect(called, true);
    });
  });
}
