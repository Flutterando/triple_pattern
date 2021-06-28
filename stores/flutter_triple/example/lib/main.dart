import 'package:flutter/material.dart';

import 'counter.dart';
import 'package:flutter_triple/flutter_triple.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final counter = Counter();

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
        child: ScopedBuilder<Counter, Exception, int>(
          store: counter,
          create: (_, child) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: child,
            );
          },
          onLoading: (_) => Text('Carregando...'),
          onState: (_, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You have pushed the button this many times:'),
                Text(
                  '$state',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: TripleBuilder<Counter, Exception, int>(
        store: counter,
        builder: (_, triple) {
          return FloatingActionButton(
            onPressed: triple.isLoading ? null : counter.increment,
            tooltip: triple.isLoading ? 'no-active' : 'Increment',
            backgroundColor: triple.isLoading ? Colors.grey : Theme.of(context).primaryColor,
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}
