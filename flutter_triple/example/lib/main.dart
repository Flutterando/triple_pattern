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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
          IconButton(onPressed: counter.undo, icon: Icon(Icons.arrow_back_ios)),
          IconButton(
              onPressed: counter.redo, icon: Icon(Icons.arrow_forward_ios)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScopedBuilder(
                store: counter,
                onLoading: (_, loading) {
                  return Text(
                    !loading
                        ? 'You have pushed the button this many times:'
                        : 'Carregando...',
                  );
                }),
            ScopedBuilder(
              store: counter,
              onState: (_, int state) {
                return Text(
                  '$state',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: ScopedBuilder(
        store: counter,
        onError: (_, error) => _floatingButton(error == null),
        onLoading: (_, isLoading) => _floatingButton(!isLoading),
        onState: (_, __) => _floatingButton(true),
      ),
    );
  }
}
