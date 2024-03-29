import 'package:mobx_triple/mobx_triple.dart';

class Counter extends MobXStore<int> with MementoMixin {
  Counter() : super(0);

  increment() {
    update(state + 1);
  }
}
