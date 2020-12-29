import 'package:square_counter/src/errors/errors.dart';
import 'package:flutter_triple/flutter_triple.dart';

import 'square_store.dart';

class HomeStore extends NotifierStore<List<SquareStore>, SquareError>
    with MementoMixin {
  HomeStore() : super([]);

  void initializeSquare(List<SquareStore> squares) {
    setState(squares);
  }

  addSquare() async {
    setLoading(true);
    await Future.delayed(Duration(seconds: 1));

    if (state.length < 9) {
      final newList = List<SquareStore>.from(state)
        ..add(SquareStore(this, index: state.length + 1));
      setState(newList);
    } else {
      setError(SquareError('Limite de squares atingido!'));
    }
    setLoading(false);
  }

  void removeSquare() async {
    if (state.isNotEmpty) {
      final newList = List<SquareStore>.from(state);
      newList.removeLast();
      setState(newList);
    }
  }
}
