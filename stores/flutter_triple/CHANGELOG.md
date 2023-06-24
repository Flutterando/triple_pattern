  ## [2.1.0] - 2023-06-24
  - feat: Automatic setLoading after call update or setError method.
  
  ## [2.0.0] - 2023-03-16

  - **[BREAKING CHANGES]**: `StreamStore` and `NotifierStore` will now just be called `Store`. 
  - **[BREAKING CHANGES]**: It is no longer necessary to declare the exception value in `Stores`, this value will be dynamic by default.
  ```dart
  // before
  class MyStore extends NotifierStore<Exception, Data> {}

  // now
  class MyStore extends Store<Data> {}
  ```
  - **[feat]**: All `RxNotifier` features will be available for `Triple`.

  ```dart
  Widget build(BuildContext context){
    context.select(() => [store.state, store.error, store.loading]);
    ...
  }
  ```
  - **[feat]**: New Widgets! (**ScopedConsumer**, **ScopedListener**, **TripleConsumer** and **TripleListener**);

  - **[BREAKING CHANGES]**: `Store.executeEither` removed.


## [1.3.0] - 

- Added TripleListener.
Use TripleListener to listen all segment modifications and reflect them in the listener callback.

exemple:
```dart

TripleListener(
    store: counter,
    listener: (context, triple) => print(triple.state),
    child: Container()
),
```

- Added ScopedListener.
Use ScopedListener to listen all segment modifications and reflect them in the recpective segment listener callbacks.

exemple:
```dart

ScopedListener(
    store: counter,
    onState: (context, state) => print(state),
    onError: (context, error) => print(error.toString()),
    onLoading: (context, isLoading) => print(isLoading),
    child: Container()
),
```

- Added TripleConsumer.
Use TripleConsumer to listen all segment modifications and reflect them in the Widgets tree and listener callback.

exemple:
```dart

TripleConsumer(
    store: counter,
    listener: (context, triple) => print(triple.state),
    builder: (context, triple) => Text('${triple.state}'),
),
```

- Added ScopedConsumer.
Use ScopedListener to listen all segment modifications and reflect them in the recpective segment Widgets tree and listener callbacks.

exemple:
```dart

ScopedConsumer(
    store: counter,
    onStateListener: (context, state) => print(state),
    onErrorListener: (context, error) => print(error.toString()),
    onLoadingListener: (context, isLoading) => print(isLoading),
    onState: (context, state) => Text('${triple.state}'),
    onError: (context, error) => Text('${triple.state}',
    onLoading: (context, isLoading) => Text('${triple.state}',
),
```


## [1.2.8] - 

- fix: Added Mounted

## [1.2.7+4] - 2022-07-12

- Update Documentation

## [1.2.7+2] - 2022-02-24

- Update triple

## [1.2.6] - 2022-01-10

- Update triple;

## [1.2.5] - 2021-10-21

- Update triple;
- Added Store.when for a value of one of three mapped possibilities.
- Added @protected on update, setError, setLoading.

## [1.2.4+3] - 2021-08-05

- Update triple;

## [1.2.3+2] - 2021-07-17

- Fix ScopedBuild in first event in triple;

## [1.2.1] - 2021-07-04

- Fix [#41](https://github.com/Flutterando/triple_pattern/issues/41)

## [1.2.0] - 2021-07-02

- Added [factory] **ScopedBuilder.transition** for customization of main widget.

```dart
ScopedBuilder.transition(
   store: counter,
   transition: (_, child) {
   return AnimatedSwitcher(
       duration: Duration(milliseconds: 400),
       child: child,
     );
   },
   onLoading: (_) => Text('Loading...'),
   onState: (_, state) => Text('$state'),
 ),
```

## [1.0.6] - 2021-05-10

- Update Triple package

## [1.0.5+1] - 2021-03-30

- Updated RxNotifier
- Updated Triple
- Updated documentation

## [1.0.0] - 2021-03-03

The Initial version providers:

- StreamStore and NotifierStore
- RxNotifier support
- Triple Tracking
- rxObserver
- ScopedBuilder and TripleBuilder
