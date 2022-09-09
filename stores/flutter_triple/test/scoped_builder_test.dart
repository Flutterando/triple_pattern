// ignore_for_file: type_annotate_public_apis, always_declare_return_types

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

void main() {
  test('instance', () {
    expect(
      ScopedBuilder(
        store: Counter(),
        onState: (s, ss) => Container(),
      ),
      isA<ScopedBuilder>(),
    );
  });
  test('throw assert when no have onState, onLoading, onError', () {
    expect(
      ScopedBuilder(
        store: Counter(),
        onState: (s, ss) => Container(),
      ),
      isA<ScopedBuilder>(),
    );
    expect(() => ScopedBuilder(store: Counter()), throwsAssertionError);
  });
  test('''throw assert when have distinct but don't have onState''', () {
    expect(
      ScopedBuilder(
        store: Counter(),
        onState: (s, ss) => Container(),
      ),
      isA<ScopedBuilder>(),
    );
    expect(
      () => ScopedBuilder(
        store: Counter(),
        distinct: (s) => s,
        onLoading: (c) => Container(),
      ),
      throwsAssertionError,
    );
  });
  test('''throw assert when have filter but don't have onState''', () {
    expect(
      ScopedBuilder(
        store: Counter(),
        onState: (s, ss) => Container(),
      ),
      isA<ScopedBuilder>(),
    );
    expect(
      () => ScopedBuilder(
        store: Counter(),
        filter: (s) => true,
        onLoading: (c) => Container(),
      ),
      throwsAssertionError,
    );
  });
  testWidgets('test change state', (WidgetTester tester) async {
    final counter = Counter();
    await tester.pumpWidget(
      MaterialApp(
        home: TestCounterPage(
          counter: counter,
        ),
      ),
    );
    final buttonFinder = find.byType(FloatingActionButton);
    expect(buttonFinder, findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('test change state store directly', (WidgetTester tester) async {
    final counter = Counter();
    await tester.pumpWidget(
      MaterialApp(
        home: TestCounterPage(
          counter: counter,
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    counter.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    counter.increment();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('test change state filter', (WidgetTester tester) async {
    final counter = Counter();
    await tester.pumpWidget(
      MaterialApp(
        home: TestCounterPage(
          counter: counter,
          withFilter: true,
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    counter.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    counter.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    counter.increment();
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
  });
  testWidgets('test change state distinct', (WidgetTester tester) async {
    final counter = Counter();
    final rebuild = [];
    await tester.pumpWidget(
      MaterialApp(
        home: TestCounterPage(
          counter: counter,
          rebuild: rebuild,
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    expect(rebuild.length, 1);

    counter.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(rebuild.length, 2);

    counter.increment();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(rebuild.length, 3);
    counter.increment();

    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(rebuild.length, 4);
    counter.increment();

    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(rebuild.length, 4);
  });
}

class CounterState {
  final int value;

  CounterState(this.value);

  operator +(int newValue) => CounterState(value + newValue);
}

class Counter extends NotifierStore<Exception, CounterState> with MementoMixin {
  Counter() : super(CounterState(0));

  void increment() {
    if (state.value > 2) {
      update(CounterState(3));
    } else {
      update(state + 1);
    }
  }
}

class TestCounterPage extends StatelessWidget {
  final Counter counter;
  final bool withFilter;
  final List? rebuild;

  const TestCounterPage({
    Key? key,
    required this.counter,
    this.withFilter = false,
    this.rebuild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: counter.undo,
            icon: const Icon(Icons.arrow_back_ios),
          ),
          IconButton(
            onPressed: counter.redo,
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
      body: Center(
        child: ScopedBuilder<Counter, Exception, CounterState>(
          store: counter,
          distinct: (state) => state.value,
          filter: withFilter ? (state) => state.value != 2 : null,
          onLoading: (_) => const Text('Carregando...'),
          onState: (_, state) {
            rebuild?.add(0);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have pushed the button this many times:'),
                Text(
                  '${state.value}',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: TripleBuilder<Counter, Exception, CounterState>(
        store: counter,
        builder: (_, triple) {
          return FloatingActionButton(
            onPressed: triple.isLoading ? null : counter.increment,
            tooltip: triple.isLoading ? 'no-active' : 'Increment',
            backgroundColor: triple.isLoading
                ? Colors.grey
                : Theme.of(
                    context,
                  ).primaryColor,
            child: const Icon(
              Icons.add,
            ),
          );
        },
      ),
    );
  }
}
