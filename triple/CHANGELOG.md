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



  ## [1.5.0+1] - 2022-02-24
  - Added `MementoMixin.clearHistory` method.
  - Remove @protected of `MementoMixin.undo` and `MementoMixin.redo` methods.
  ## [1.4.0] - 2021-10-21
  - Added `HydratedMixin.hasInitiated` flag.

  ## [1.3.3] - 2021-10-21
  - Added Store.when for a value of one of three mapped possibilities.
  - Added @protected on update, setError, setLoading.

  ## [1.3.0+1] - 2021-08-20
  
  - Added resolvers;
  ## [1.2.0+3] - 2021-07-17
  
  - Added HydratedMixin and HydratedDelegate;

  ## [1.1.0] - 2021-07-10

 - Remove dartz dependency (Use **EitherAdapter**)
 - Added EitherAdapter interface
  ## [1.0.2] - 2021-05-10

 - fix executeEither

 ## [1.0.0] - 2021-03-03

The Initial version providers:
- abstract Stores
- Triple Objects
- Triple Tracking
