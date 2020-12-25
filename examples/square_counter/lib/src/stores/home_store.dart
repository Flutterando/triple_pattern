import 'package:square_counter/src/errors/errors.dart';
import 'package:flutter_triple/flutter_triple.dart';

import 'square_store.dart';

class HomeStore extends StreamStore<List<SquareStore>, SquareError> {
  HomeStore() : super([]);

  void addSquare() {
    if (state.length < 9) {
      final newList = List<SquareStore>.from(state)..add(SquareStore(this, index: state.length + 1));
      setState(newList);
    } else {
      setError(SquareError('Limite de squares atingido!'));
    }
  }

  void removeSquare() async {
    if (state.isNotEmpty) {
      final newList = List<SquareStore>.from(state);
      await newList.last.destroy();
      newList.removeLast();
      setState(newList);
    }
  }
}
