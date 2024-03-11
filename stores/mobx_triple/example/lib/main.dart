// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:mobx_triple/mobx_triple.dart';

import 'counter.dart';

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
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
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
  final counter = Counter();

  Widget _floatingButton(bool active) {
    return FloatingActionButton(
      onPressed: active ? counter.increment : null,
      tooltip: active ? 'Increment' : 'no-active',
      backgroundColor: active ? Theme.of(context).primaryColor : Colors.grey,
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: counter.undo,
            icon: Icon(
              Icons.arrow_back_ios,
            ),
          ),
          IconButton(
            onPressed: counter.redo,
            icon: Icon(
              Icons.arrow_forward_ios,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScopedBuilder(
                store: counter,
                onLoading: (_) {
                  return Text(
                    !counter.isLoading ? 'You have pushed the button this many times:' : 'Carregando...',
                  );
                }),
            ScopedBuilder(
              store: counter,
              onState: (_, int state) {
                return Text(
                  '$state',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: ScopedBuilder(
        store: counter,
        onError: (_, error) => _floatingButton(error == null),
        onLoading: (_) => _floatingButton(!counter.isLoading),
        onState: (_, __) => _floatingButton(true),
      ),
    );
  }
}
