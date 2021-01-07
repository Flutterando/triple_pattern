# flutter_triple

Implementation of the Segmented State Pattern, nicknamed Triple.


## State Segmentation

The SSP segments the state into 3 reactive parts, the state value (state), the error object (error), and the state loading action (loading).

.

![Triple](https://github.com/Flutterando/triple_pattern/raw/master/schema.png)

These segments are observed in a listener or separate listeners. They can also be combined to obtain a new segment, always starting from the 3 main segments.

## The Package

This package introduces Stores in the pre-implemented segment pattern using the Streams API (StreamStore) and the ValueNotifier object (NotifierStore).

Stores already offer by default an observer (**store.observer()**) and **store.update()** (Update State), **store.setLoading()** (To change the loading), **store.setError()** (To change the error).
It also has the mixin **MementoMixin** that uses the pattern design **Memento** to undo or redo the state value, therefore, the **store.undo()** and **store.redo() methods** are also added to Store by this mixin.
Using the ValueNotifier (NotifierStore), the properties *state*, *loading*, and *error* are reactive thanks to the extension [rx_notifier](https://pub.dev/packages/rx_notifier).

The Package also has **Builder Widgets** to observe changes in the state in the Flutter widget tree.

## Maintaining the State with Streams

To create a Store that will be responsible for the State Logic, create a class and inherit from **StreamStore**:

```dart
class Counter extends StreamStore {}
```

You can also put types in the state value and in the exception object that we will be working on in this Store:

```dart
class Counter extends StreamStore<Exception, int> {}
```

We ended by assigning an initial value for the state of this Store by invoking the constructor of the parent class (super):

```dart
class Counter extends StreamStore<Exception, int> {

    Counter() : super(0);
}
```

It is available in the Store 3 methods to change the segments **(update, setError, and setLoading)**. 
Let's start by incrementing the state:

```dart
class Counter extends StreamStore<Exception, int> {

    Counter() : super(0);

    void increment(){
        update(state + 1);
    }
}
```

This code is enough to make the counter work.
Let's add a little bit of asynchronous code to introduce the methods **setError** and **setLoading**

```dart
class Counter extends StreamStore<Exception, int> {

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

Here we experience the change of states and the other segments of loading and error. 
> **NOTE**: To use **NotifierStore** it is the same as we saw on **StreamStore**.

The 3 segments operate separately but can be "heard" together. Now we will see how to observe this store.

## Observers and Builders

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
    onLoading: (context) => CircularProgressIndicator(),
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

The type of selectors changes depending on the reactive tool you are using in the Stores. For example, if you are using **StreamStore** then your selectors will be Streams, however,  if you are using **NotifierStore** then your selectors will be ValueListenable;

```dart
//StreamStore
Stream<int> myState$ = counter.selectState;
Stream<Exception> myError$ = counter.selectError;
Stream<bool> myLoading$ = counter.selectLoading;

//NotifierStore
ValueListenable<int> myState$ = counter.selectState;
ValueListenable<Exception?> myError$ = counter.selectError;
ValueListenable<bool> myLoading$ = counter.selectLoading;

```

## Maintaining the State with ValueNotifier

[ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) is an implementation of [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) and is present in the entire ecosystem of Flutter, from ScrollController to TabController.

Using the *ChangeNotifier* API means reusing everything that already exists in Flutter.

The ValueNotifier used in this Store is extended by the library [rx_notifier](https://pub.dev/packages/rx_notifier) which brings the possibility of applying **functional reactive programming (TFRP)**, listening to changes in their values ​​in a transparent way as does the [MobX](https://pub.dev/packages/mobx).

A Store based on **ValueNotifier** its called **NotifierStore**:

```dart
class Counter extends NotifierStore<Exception, int> {

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

Our selectors (selectState, selectError, and selectBool) now will be **ValueListenable** that can be listen separately using **.addListener()** or in the Widget Tree with **AnimatedBuilder** both from Flutter:

```dart

store.selectError.addListener(() => print(store.state));

...

Widget builder(BuildContext context){
    return AnimatedBuilder(
        animation: store.selectState,
        builder: (_, __, ___) => Text(store.state);
    );
}

```

Or listen to reactions transparently using the **rxObserver** or in the widget tree with the **RxBuilder**:

```dart

rxObserver(() => print(store.state));

...

Widget builder(BuildContext context){
    return RxBuilder(
        builder: (_) => Text(store.state);
    );
}

```

For more information about the extension read the documentation for [rx_notifier](https://pub.dev/packages/rx_notifier)

> **IMPORTANT**: You can also continue to use the **Triple** (**observer**, **ScopedBuilder** and **TripleBuilder**);

## Memento with MementoMixin

You can add, undo or redo a state using the Memento Pattern. 
This means that you can return to the previous state using the method **undo()** and also advance with the method **redo()**.

```dart

class Counter extends StreamStore<Exception, int> with MementoMixin {}

```

## Questions and Problems

The **issues** channel is open for questions, to report problems and suggestions, do not hesitate to use this communication channel.

> **LET'S BE REFERENCES TOGETHER**








