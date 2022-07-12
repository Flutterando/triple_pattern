# Example

### Page

```dart
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
        child: ScopedBuilder(
          store: counter,
          onLoading: (_) => Text('Carregando...'),
          onState: (_, state) {
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
```

### Store

```dart
import 'package:flutter_triple/flutter_triple.dart';

class Counter extends StreamStore<Exception, int> with MementoMixin {
  Counter() : super(0);

  Future<void> increment() async {
    setLoading(true);
    await Future.delayed(Duration(milliseconds: 1000));
    update(state + 1);
    setLoading(false);
  }
}
```

Welcome to Triple!

Design Pattern for State Management.

## For more

[Link to doc](https://triple.flutterando.com.br)
