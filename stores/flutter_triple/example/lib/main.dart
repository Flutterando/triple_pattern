import 'package:flutter/material.dart';

import 'counter.dart';
import 'package:flutter_triple/flutter_triple.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final counter = CounterStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: counter.undo,
            icon: Icon(Icons.arrow_back_ios),
          ),
          IconButton(
            onPressed: counter.redo,
            icon: Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
      body: Center(
        child: ScopedConsumer<CounterStore, Exception, int>(
          store: counter,
          onLoadingListener: (context, isLoading) {},
          onErrorListener: (context, error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
              ),
            );
          },
          onLoadingBuilder: (context) => Text('Carregando...'),
          onStateBuilder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You have pushed the button 399 this many times:'),
                Text(
                  '$state',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: TripleBuilder<CounterStore, Exception, int>(
        store: counter,
        builder: (context, triple) {
          return FloatingActionButton(
            onPressed: triple.isLoading ? null : counter.increment,
            tooltip: triple.isLoading ? 'no-active' : 'Increment',
            backgroundColor:
                triple.isLoading ? Colors.grey : Theme.of(context).primaryColor,
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}
