# Triple - Segmented State Pattern

When we talk about a single flow state, we end up solving architecture problems early, as we will have only one data flow for each state. 
In addition to the maintainability and earchitectural facility, we also have the possibility of increasing this flow with other standards such as the Observer, which gives reactivity to the component when it is modified and Memento, which makes it possible to revert or redo this state.

A beautiful example of a single flow pattern is the BLoC, giving the reactivity to a state enabling all transformations in that flow. This (although complicated for some), consolidates very well in the architecture of a project, even the limits of this practice are beneficial for not allowing the developer to resort to other solutions outside the architecture and the standard for his feature.

There are other ways to promote reactivity in a property instead of the entire object, such as MobX's Observable and Flutter's ValueNotifier, and that gives us a good deal of freedom. However, we lost some important limits for architecture, which may put the maintenance of the project in check in the future. Therefore, it needs a standard to impose limits on the individual reactivity of each property and thereby improve the maintainability of the components responsible for managing the states of the application.
## State, Error, Loading
.
![schema](schema.png)

When we work with a single flow state, that is, when the reactivity is in the object and not in its properties, we can have more control over the data being processed before reaching a listener.
For example, if your logic manages an X state and wants to make it Y just assign the value.
```dart
MyState state = X();
state = Y();
```
However, the flow can contain asynchronous elements and it is always interesting to inform that the state is being loaded. This is quite common in Software to Mobile development with APIs for example.
```dart
MyState state = X();
state = Loading();
state = await getY(); // return Y
```
The recovery of these data can also fail, and this makes the existence of an error state pertinent.
```dart
MyState state = X();
state = Loading();
try{
  state = await getY();
} catch(e) {
  state = Error();
}

```
As we are talking about a single flow we use a Object Orientation principle, the POLYMORPHISM, to share these 3 responsibilities (State Value, Loading or Error).
```dart
abstract class MyState {}

class X extends MyState
class Y extends MyState
class Loading extends MyState
class Error extends MyState
```
With that we have a unique Flow of **MyState**, because as the objects X, Y, Loading and Error inherit from **MyState**.
```dart
X is MyState; // it,s true!
Y is MyState; // it,s true!
Loading is MyState; // it,s true!
Error is MyState; // it,s true too!
```
Thank you so much Object Orientation Mother! :)

Now, as we have the possibility of having reactivity by property with MobX or ValueNotifier, we would not need Polymorphism if we divide the responsibility of Loading and Error for separate properties.And so we have a triple fork making Loading and Error actions post or pre change of state.
An example using MobX:
```dart
...
@observable 
ProductData state = ProductData.empty();

@observable 
bool loading = false;

@observable 
Exception? error;

@action
Future<void> fetchProducts() async {
  loading = true;
  try{
    state = await repository.getProducts(); // return ProductData
  } catch(e){
    error = Exception('Error');
  }
  loading = false;
}
```

In short, we have 3 flows, the state that has the state value, the error that holds the exceptions and the bool loading that informs when the loading action is in effect.
Being able to listen to these 3 actions separately helps to transform them and combine them into other actions, enriching your Store (Class with the logic responsible for managing the state of your component).
As the movement of the state is always around the trio State, Error and Loading, it is worth this bifurcation for standardization.

## Observando os Fluxos

Having 3 separate streams we can have 3 different listeners, for example, we hear the error to launch it in the form of "SnackBar" and when there are Loadings we launch a Dialog, but if we need to add to this state a pattern like "memento" we will have to put the 3 properties in a generic object.

To close the pattern of the 3 Flows we can create a generic object, its properties can be reactive as well as the object itself. Let's look at an example with MobX.

```dart

class Triple<State, Error> {
  final State state;
  final Error? error;
  final bool loading;

  Triple({required this.state, this.error, this.loading = false});

  Triple<State, Error> copyWith({State? state, Error? error, bool? loading}){
    return Triple<State, Error>(
      state: state ?? this.state,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
}

```

Then we can use:
```dart
@observable 
var triple = Triple<ProductData, Exception>(state: ProductData.empty());

@action
Future<void> fetchProducts() async {
  triple = triple.copyWith(loading: true);
  try{
    final state = await repository.getProducts(); // return ProductData
    triple = triple.copyWith(loading: false, state: state);
  } catch(e){
    final error = Exception('Error');
    triple = triple.copyWith(loading: false, error: error);
  }
}
```

We now have an object that joins the 3 segmented state properties that can also be accessed and transformed individually using MobX's @computed which automatically distinguishes and only triggers a reaction if the property is really a new object.

```dart
@observable 
var _triple = Triple<ProductData, Exception>(state: ProductData.empty());

@computed
ProductData get state => triple.state;

@computed
Exception get error => triple.error;

@computed
bool get loading => triple.loading;

...
```

With the object bringing together the state and its actions, we can implement other design patterns or just make transformations on the object or separately on its properties.
Let's see a small example of implementation of the Design Pattern Memento that will make it possible for the state to rollback, that is, return to the previous states as a time machine.

```dart
...

@observable 
var _triple = Triple<ProductData, Exception>(state: ProductData.empty());

@computed
ProductData get state => triple.state;
@computed
Exception get error => triple.error;
@computed
bool get loading => triple.loading;

//save all changed states
final List<Triple<ProductData, Exception>> _history = [];

@action
void setState(({ProductData? state, Exception? error, bool? loading}){
  _history.add(_triple);
  _triple = _triple.copyWith(state: state, error: error, loading: true);
}

@action
void undo(){
  if(_history.length > 0){
    _triple = _history.last;
    _history.remove(_triple);
  } else {
    throw Exception('Not have history data');
  }
}

@action
Future<void> fetchProducts() async {
  triple = setState(loading: true);
  try{
    final state = await repository.getProducts(); // return ProductData
    triple = setState(loading: false, state: state);
  } catch(e){
    final error = Exception('Error');
    triple = setState(loading: false, error: error);
  }
}
```

We implemented something very complex, but it is very easy to understand what is happening just by reading the code.
So we come to a standard that can be used to manage states and substates using reactivity individually by property.

The Segmented State (Or Triple) pattern can be abstracted to make its reuse stronger. We will use MobX again as an example, but we can use it in any type of reactivity by property.

```dart
abstract class TripleStore<State, Error> on Store {

  @observable 
  late Triple<State, Error> _triple;

  TripleStore(State initialState){
     _triple = Triple<State, Error>(state: initialState);
  }

  @computed
  State get state => triple.state;
  @computed
  Error get error => triple.error;
  @computed
  bool get loading => triple.loading;

  //save all changed states
  final List<Triple<State, Error>> _history = [];

  @action
  void setState(({State? state, Error? error, bool? loading}){
    _history.add(_triple);
    _triple = _triple.copyWith(state: state, error: error, loading: true);
  }

  @action
  void undo(){
    if(_history.length > 0){
      _triple = _history.last;
      _history.remove(_triple);
    } else {
      throw Exception('Not have history data');
    }
  }
}
```

now you just need to implement **TripleStore** in any MobX Store you want to use.

```dart
class Product = ProductBase with _$Product;

abstract class ProductBase extends TripleStore<ProductData, Exception> with Store {

  ProductBase(): super(ProductData.empty());

  @action
  Future<void> fetchProducts() async {
    triple = setState(loading: true);
    try{
      final state = await repository.getProducts(); // return ProductData
      triple = setState(loading: false, state: state);
    } catch(e){
      final error = Exception('Error');
      triple = setState(loading: false, error: error);
    }
  }
}

```

Once again THANK YOU MOTHER ORIENTATION ON OBJECTS.

## Extension

As we have seen, the purpose of the Segmented State Standard (Triple) helps to standardize the logic of state management. We are working on abstractions (packages) for MobX and also one based on Streams. More details in the documentation of the abstractions themselves.

- triple (Store and StreamStore)
- flutter_triple (NotifierStore, ScopedBuilder)
- mobx_triple (MobXStore)


## Features and bugs

The Segmented State Standard is constantly growing. 
Let us know what you think of all this.
If you agree, leave a Star in that repository representing that you are signing and agreeing to the proposed standard.
