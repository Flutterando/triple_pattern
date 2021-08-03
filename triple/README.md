# Triple

This package is an abstraction of the [Segmented State Pattern](https://triple.flutterando.com.br) that forces architectural barriers to individual reactivities.

This abstraction serves to create implementations of [SSP](https://triple.flutterando.com.br) using any Reactive object as a basis to create a Store (Object responsible for the State Logic of a component).

## How to build a Store?
.

![Triple](https://github.com/Flutterando/triple_pattern/raw/master/schema.png)

Following the [SSP](https://triple.flutterando.com.br/docs/intro), our Store needs to segment the state data in 3 ways, a State (containing the State value), and Error (Containing the exception object of state), and Loading (indicating whether the state value is being loaded). These 3 properties are part of the Triple object that is inherited as a property in the abstract class Store. We will then see step-by-step how to create a Store based on any existing Reactivity system.




### STEP 1: Choose a Reactivity system.

The SSP does not place any requirements on the type of reactivity that can be used in the standard, so the developer must choose the one he likes best to create a Store.
Some examples of reactivity:
- Streams
- ValueNotifier/ChangeNotifier
- MobX

For the next steps we will use "Streams", but feel free about that choice.

### STEP 2: Create a class that inherits from **Store**

As we said, an object **Store** serves to store the state logic of a component.
```dart
abstract class StreamStore extends Store {}
```

It is reasonable to put "generic types" for "error" and "state", we will do that in **StreamStore** and then pass them in **Store**.
> **IMPORTANT**: Inherit generic Object types to prevent the use of dynamics.

and so we have:
```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {}
```

We still need to declare the constructor of the parent class with an initial value of the state and thus we conclude this step:

```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  StreamStore(State state) : super(state);

}
```

### STEP 3: Starts an object with the chosen reactivity.
 

Privately include a reactive property that works with the type **Triple<Error, State>()**:

```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

}
```

### STEP 4: Dispose of the reactive object

Override the **destroy** method that will be called when the Store is disposed.


```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @override
  Future destroy() async {
    await _tripleController.dispose();
  }

}
```

### STEP 5: Override the propagate method.

When the Store decides to propagate a value of type **Triple**, it does so by calling the **propagate()** method. Override this method to direct the flow to your main reactivity control. Don't forget to call the **super.propagate()** method.

```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @protected
  @override
  void propagate(Triple<Error, State> triple){
    super.propagate(triple);
    _tripleController.add(triple);
  }

  @override
  Future destroy() async {
    await _tripleController.dispose();
  }

}
```

> **IMPORTANT**: The method **propagate** is assign with **@protected** because it might only be used within the class **StreamStore**.


### STEP 6: Override the method **observer**

This method is called to listen to the state's segmented events (state, error, and loading). Overwrite by calling the functions of each segment.


```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @protected
  @override
  void propagate(Triple<Error, State> triple){
    _tripleController.add(triple);
  }

  @override
  Disposer observer({
    void Function(State state)? onState,
    void Function(Error error)? onError,
    void Function(bool loading)? onLoading,
  }){
    final _sub = _tripleController.listen((triple){
      if(triple.event == TripleEvent.state){
        onState(triple.state);
      } else if(triple.event == TripleEvent.error){
        onError(triple.error);
      } else if(triple.event == TripleEvent.loading){
        onLoading(triple.loading);
      }
    });
    return () async {
      await _sub.cancel();
    }
  }

  @override
  Future destroy() async {
    await _tripleController.dispose();
  }

}
```

### STEP 7 (OPTIONAL): Define Selectors

It may be interesting to have selectors from each state segment reactively. This is an Error, State and reactive loading.
If you want to have this possibility in the Store, implement the interface **Selectors**:

```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State>
implements Selectors<Stream<Error>, Stream<State>, Stream<bool>>
 {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  @override
  late final Stream<State> selectState = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.state)
      .map((triple) => triple.state);

  @override
  late final Stream<Error> selectError = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.error)
      .where((triple) => triple.error != null)
      .map((triple) => triple.error!);

  @override
  late final Stream<bool> selectLoading = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.loading)
      .map((triple) => triple.loading);

  StreamStore(State state) : super(state);

  ...
```

## Middleware

We can add interceptors and modify the triple when the setLoading, setError or update action is executed.

```dart
class Counter extends StreamStore<Exception, int> {

  Counter(0): super(0);

  ...
  @override
  Triple<Exception, int> middleware(triple){
    if(triple.event == TripleEvent.state){
      return triple.copyWith(state + 2);
    }

    return triple;
  }

}
```

## Executors

A very common pattern in an asynchronous request is:

```dart

  @override
  Future<void> fetchData(){
    setLoading(true);
    try {
      final result = await repository.fetch();
      update(result);
    } catch(e){
      setError(e);
    }
    setLoading(false);
  }

```

You can use the **execute** method and pass on Future to perform the same steps described in the previous example:

```dart

  @override
  Future<void> fetchData(){
   execute(() => repository.fetch());
  }

```
for users using **dartz** using Clean Architecture, for example, they can also run either using the **executeEither** method:

```dart
 @override
  Future<void> fetchData(){
   executeEither(() => myUsecase());
  }
```

## Memento with MementoMixin

You can add, undo or redo a state using the Memento Pattern. 
This means that you can return to the previous state using the method **undo()** and also advance with the method **redo()**.

```dart

class Counter extends StreamStore<Exception, int> with MementoMixin {}

```

## For Tracking

Use the **TripleObserver** singleton for Triple tracker in all Store of your project.

```dart

void main(){
  
  TripleObserver.addListener((triple){
    print(triple);
  });

  runApp(MyApp());
}
```

> This feature can be used to gather information for Firebase Analytic for example.


## Examples

- [flutter_triple](https://pub.dev/packages/flutter_triple) (StreamStore, NotifierStore, ScopedBuilder, TripleBuilder);

- [mobx_triple](https://pub.dev/packages/mobx_triple) (MobXStore);



## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

