import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/src/stores/notifier_store.dart';
import 'package:flutter_triple/src/widgets/scoped_listener.dart';

void main() {
  group('ScopedListener', () {
    late TripleTeste store;
    late ScopedListener scopedListener;

    setUp(() {
      store = TripleTeste();
      scopedListener = ScopedListener<TripleTeste, TripleTesteError, int>(
        store: store,
        onState: (context, state) {},
        child: Container(),
      );
    });

    testWidgets('should throw an error if no listeners are defined',
        (tester) async {
      expect(
        () => ScopedListener<TripleTeste, TripleTesteError, int>(
          store: store,
          child: Container(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
        'should throw an error if distinct is defined but onState is not',
        (tester) async {
      expect(
        () => ScopedListener<TripleTeste, TripleTesteError, int>(
          store: store,
          distinct: (state) => state,
          child: Container(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('should throw an error if filter is defined but onState is not',
        (tester) async {
      expect(
        () => ScopedListener<TripleTeste, TripleTesteError, int>(
          store: store,
          filter: (state) => true,
          child: Container(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(scopedListener);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should trigger onState when state changes', (tester) async {
      var count = 0;
      scopedListener = ScopedListener<TripleTeste, TripleTesteError, int>(
        store: store,
        onState: (context, state) {
          count++;
        },
        child: Container(),
      );

      await tester.pumpWidget(scopedListener);
      store.update(1);
      await tester.pump();

      expect(count, equals(1));
    });

    testWidgets(
        'should not trigger onState when state changes but filter returns false',
        (tester) async {
      var count = 0;
      scopedListener = ScopedListener<TripleTeste, TripleTesteError, int>(
        store: store,
        onState: (context, state) {
          count++;
        },
        filter: (state) => state > 1,
        child: Container(),
      );

      await tester.pumpWidget(scopedListener);
      store.update(1);
      await tester.pump();

      expect(count, equals(0));
    });

    testWidgets('should trigger onError when error is thrown', (tester) async {
      var count = 0;
      scopedListener = ScopedListener<TripleTeste, TripleTesteError, int>(
        store: store,
        onError: (context, error) {
          count++;
        },
        child: Container(),
      );

      await tester.pumpWidget(scopedListener);
      store.setError(TripleTesteError(''));
      await tester.pump();

      expect(count, equals(1));
    });
  });
}

class TripleTeste extends NotifierStore<TripleTesteError, int> {
  TripleTeste() : super(0);
}

class TripleTesteError {
  final String message;
  TripleTesteError(this.message);
}
