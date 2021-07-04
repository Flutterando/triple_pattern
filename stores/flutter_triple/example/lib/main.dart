import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Tripple Test', home: MyHomePage());
  }
}

class Counter extends StreamStore<Exception, int> {
  Counter() : super(0);

  Future<void> increment() async {
    setLoading(true);

    await Future.delayed(Duration(seconds: 1));

    int value = state + 1;
    if (value < 5) {
      update(value);
    } else {
      setError(Exception('State not can be > 4'));
    }
    setLoading(false);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _counter = Counter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: ScopedBuilder<Counter, Exception, int>(
        store: _counter,
        onState: (state, counter) {
          print('onState called: $counter');
          return Padding(
            padding: EdgeInsets.all(10),
            child: Text('$counter'),
          );
        },
        onError: (context, error) {
          print('onError called: $error');
          return Center(
            child: Text(
              error.toString(),
              style: TextStyle(color: Colors.red),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() async {
          await _counter.increment();
        }),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
