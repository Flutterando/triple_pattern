// ignore_for_file: type_annotate_public_apis, always_declare_return_types
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';

void main() {
  test('instance', () {
    expect(
      ScopedListener(
        store: CounterStore(),
        onState: (context, state) => log(state.toString()),
        child: Container(),
      ),
      isA<ScopedListener>(),
    );
  });
  test('throw assert when no have onState, onLoading, onError', () {
    expect(
      ScopedListener(
        store: CounterStore(),
        onState: (context, state) => log(state.toString()),
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
        onState: (context, state) => log(state.toString()),
        child: Container(),
      ),
      isA<ScopedListener>(),
    );
    expect(
      () => ScopedListener(
        store: CounterStore(),
        distinct: (s) => s,
        onLoading: (context, isLoading) => log(isLoading.toString()),
        child: Container(),
      ),
      throwsAssertionError,
    );
  });
  test('''throw assert when have filter but don't have onState''', () {
    expect(
      ScopedListener(
        store: CounterStore(),
        onState: (context, state) => log(state.toString()),
        child: Container(),
      ),
      isA<ScopedListener>(),
    );
    expect(
      () => ScopedListener(
        store: CounterStore(),
        filter: (s) => true,
        onLoading: (context, isLoading) => log(isLoading.toString()),
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
          store: counter,
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
          store: counter,
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
          store: counter,
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
          store: counter,
          onState: rebuild,
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
  final CounterStore store;
  final bool withFilter;
  final List? onLoading;
  final List? onState;
  final List? onError;

  const TestCounterPage({
    Key? key,
    required this.store,
    this.withFilter = false,
    this.onLoading,
    this.onState,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: store.undo,
            icon: const Icon(Icons.arrow_back_ios),
          ),
          IconButton(
            onPressed: store.redo,
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
      body: Center(
        child: ScopedListener<CounterStore, Exception, CounterState>(
          store: store,
          distinct: (state) => state.value,
          filter: withFilter ? (state) => state.value != 2 : null,
          onLoading: (context, isLoading) => onLoading?.add(0),
          onState: (context, state) => onState?.add(0),
          onError: (context, error) => onError?.add(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times:'),
              Text(
                '${store.state.value}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: store.increment,
        tooltip: 'Increment',
        backgroundColor: Colors.grey,
        child: const Icon(Icons.add),
      ),
    );
  }
}
