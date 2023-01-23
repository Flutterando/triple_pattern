// ignore_for_file: type_annotate_public_apis, always_declare_return_types
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

void main() {
  test('instance', () {
    expect(
      ScopedListener(
        store: CounterStore(),
        onState: (context, state) => print(state),
        child: Container(),
      ),
      isA<ScopedListener>(),
    );
  });
  test('throw assert when no have onState, onLoading, onError', () {
    expect(
      ScopedListener(
        store: CounterStore(),
        onState: (context, state) => print(state),
        child: Container(),
      ),
      isA<ScopedListener>(),
    );
    expect(
      () => ScopedListener(
        store: CounterStore(),
        child: Container(),
      ),
      throwsAssertionError,
    );
  });
  test('''throw assert when have distinct but don't have onState''', () {
    expect(
      ScopedListener(
        store: CounterStore(),
        onState: (context, state) => print(state),
        child: Container(),
      ),
      isA<ScopedListener>(),
    );
    expect(
      () => ScopedListener(
        store: CounterStore(),
        distinct: (s) => s,
        onLoading: (context, isLoading) => print(isLoading),
        child: Container(),
      ),
      throwsAssertionError,
    );
  });
  test('''throw assert when have filter but don't have onState''', () {
    expect(
      ScopedListener(
        store: CounterStore(),
        onState: (context, state) => print(state),
        child: Container(),
      ),
      isA<ScopedListener>(),
    );
    expect(
      () => ScopedListener(
        store: CounterStore(),
        filter: (s) => true,
        onLoading: (context, isLoading) => print(isLoading),
        child: Container(),
      ),
      throwsAssertionError,
    );
  });
  testWidgets('test change state', (WidgetTester tester) async {
    final counter = CounterStore();
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
    final counter = CounterStore();
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
    final counter = CounterStore();
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
    final counter = CounterStore();
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

class CounterStore extends NotifierStore<Exception, CounterState>
    with MementoMixin {
  CounterStore() : super(CounterState(0));

  void increment() {
    if (state.value > 2) {
      update(CounterState(3));
    } else {
      update(state + 1);
    }
  }
}

class TestCounterPage extends StatelessWidget {
  final CounterStore counter;
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
        child: ScopedListener<CounterStore, Exception, CounterState>(
          store: counter,
          distinct: (state) => state.value,
          filter: withFilter ? (state) => state.value != 2 : null,
          onLoading: (context, isLoading) {
            if (isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Carregando...'),
                ),
              );
            }
          },
          onState: (context, state) => rebuild?.add(0),
          onError: (context, error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times:'),
              Text(
                '${counter.state.value}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          TripleListener<CounterStore, Exception, CounterState>(
        store: counter,
        listener: (context, triple) {
          if (triple.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Carregando...'),
              ),
            );
          }
        },
        child: FloatingActionButton(
          onPressed: counter.isLoading ? null : counter.increment,
          tooltip: counter.isLoading ? 'no-active' : 'Increment',
          backgroundColor: counter.isLoading
              ? Colors.grey
              : Theme.of(
                  context,
                ).primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
