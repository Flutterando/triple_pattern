# triple_test

Test Helper for Store of **flutter_triple** with **Mocktail**.
** Inspired by **bloc_test** **


## Create a Mock

```dart
import 'package:bloc_test/bloc_test.dart';

class MockCounterStore extends MockStore<Exception, int> implements CounterStore {}

...

final mock = MockCounterStore();

```

Now creates a stud for the method on Triple Store.

```dart
whenObserve<MyException, int>(
    mock,
    input: () => mock.testAdd(),
    initialState: 0,
    triples: [
      Triple(state: 1),
      Triple(isLoading: true, event: TripleEvent.loading, state: 1),
      Triple(state: 2),
    ],
  );
```

