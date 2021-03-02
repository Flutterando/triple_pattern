# mobx_triple

Implementation of the Segmented State Pattern, nicknamed Triple.


## State Segmentation

The SSP segments the state into 3 reactive parts, the state value (state), the error object (error), and the state loading action (loading).

.

![Triple](https://github.com/Flutterando/triple_pattern/raw/master/schema.png)

These segments are observed in a listener or separate listeners. They can also be combined to obtain a new segment, always starting from the 3 main segments.

## The Package

This package introduces Stores in the pre-implemented segment pattern using MobX**(MobXStore)**).

Stores already offer by default an observer (**store.observer()**) and **store.update()**(Update state), **store.setLoading()**(Change loading), **store.setError()**(Change Error).
It also has the mixin **MementoMixin** that uses the pattern design **Memento** to undo or redo the state value, therefore, **store.undo()** and **store.redo()** are also added to Store by this mixin.

The Package also has **Builder Widgets** to observe changes in the state in the Flutter widget tree.

## Maintaining the State with MobXStore

A Store based on **MobX** its called **MobXStore**:

```dart
class Counter extends MobXStore<int, Exception> {

    Counter() : super(0);

    Future<void> increment() async {
        setLoading(true);

        await Future.delayer(Duration(seconds: 1));

        int value = state + 1;
        if(value < 5) {
            update(value);
        } else {
            setError(Exception('Error: state not can be > 4'))
        }
        setLoading(false);
    }
}
```

Our selectors (selectState, selectError, and selectBool) now will be **Observable** that can be listen separately using **.observer()** or in the Widget Tree with **Observer** both from flutter_mobx:

```dart

store.selectError.observer((_) => print(store.state));

...

Widget builder(BuildContext context){
    return Observer(
        builder: (_) => Text(store.state);
    );
}

```

For more information about the extension read the documentation for [flutter_mobx](https://pub.dev/packages/flutter_mobx)

> **IMPORTANT**: You can also continue to use the **Triple** (**observer**, **ScopedBuilder** and **TripleBuilder**);


### observer

We can observe the segments separately or together by using **store.observer()**;

```dart
counter.observer(
    onState: (state) => print(state),
    onError: (error) => print(error),
    onLoading: (loading) => print(loading),
);
```
On Widgets we can observe on a Builder with ScopedBuilder or observe all changes with TripleBuilder.

### ScopedBuilder

Use **ScopedBuilder** to listen the segments, likewise the method **store.observer()**;

```dart
ScopedBuilder(
    store: counter,
    onState: (context, state) => Text('$state'),
    onError: (context, error) => Text(error.toString()),
    onLoading: (context, loading) => CircularProgressIndicator(),
);
```

> **NOTE**: On ScopedBuilder the **onLoading** is only called when "true". This means that if the state is modified or an error is added, the widget to be built will be the **onState** or **onError**. However, it is very important to change Loading to "false" when the loading action is completed. **observers** of Triple *DO NOT PROPAGATE REPEATED OBJECTS* (more on this in the section on **distinct**). This is a behavior exclusive to ScopedBuilder.

### TripleBuilder

Use **TripleBuilder** to listen all segment modifications and reflect them in the Widgets tree.

```dart
TripleBuilder(
    store: counter,
    builder: (context, triple) => Text('${triple.state}'),
);
```

> **NOTE**: The **TripleBuilder** builder is called when there is any change in the segments. Its use is recommended only if you are interested in listening to all segments at the same time.

### Distinct

By default, the Store's observer does not react to repeated objects. This behavior is beneficial as it avoids state reconstructions and notifications if the segment has not been changed.

It is good practice to overwrite the **operation==** of the state value and error. A good tip is also to use the package [equatable](https://pub.dev/packages/equatable) to simplify this type of comparison.

## Selectors

We can recover the reactivity of the segments individually for transformations or combinations. We then have 3 selectors that can be retrieved as Store properties: **store.selectState**, **store.selectError** and **store.selectLoading**.

```dart
Observable<int> myState$ = counter.selectState;
Observable<Exception?> myError$ = counter.selectError;
Observable<bool> myLoading$ = counter.selectLoading;

```

## https://github.com/Flutterando/triple_pattern

You can add, undo or redo a state using the Memento Pattern. 
This means that you can return to the previous state using the method **undo()** and also advance with the method **redo()**.

```dart

class Counter extends MobXStore<int, Exception> with MementoMixin {}

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

You can use the ** execute **method** and pass on Future to perform the same steps described in the previous example:

```dart

  @override
  Future<void> fetchData(){
   execute(() => repository.fetch());
  }

```
for users using **dartz** using Clean Architecture for example, they can also run the Either class using the **executeEither** method:

```dart
 @override
  Future<void> fetchData(){
   executeEither(() => myUsecase());
  }
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


## Questions and Problems

The **issues** channel is open for questions, to report problems and suggestions, do not hesitate to use this communication channel.

> **LET'S BE REFERENCES TOGETHER**








