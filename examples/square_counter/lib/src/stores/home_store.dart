// ignore_for_file: cascade_invocations, lines_longer_than_80_chars

import 'package:mobx_triple/mobx_triple.dart';
import 'package:square_counter/src/errors/errors.dart';

import 'square_store.dart';

class HomeStore extends MobXStore<SquareError, List<SquareStore>> with MementoMixin {
  HomeStore() : super([]);

  void initializeSquare(List<SquareStore> squares) {
    update(squares);
  }

  dynamic addSquare() async {
    setLoading(true);
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (state.length < 9) {
      final newList = List<SquareStore>.from(state);
      newList.add(
        SquareStore(
          this,
          index: state.length + 1,
        ),
      );
      update(newList);
    } else {
      setError(
        SquareError(
          'Limite de squares atingido!',
        ),
      );
    }
    setLoading(false);
  }

  Future<void> removeSquare() async {
    if (state.isNotEmpty) {
      final newList = List<SquareStore>.from(state);
      newList.removeLast();
      update(newList);
    }
  }
}
