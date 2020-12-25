import 'package:mobx_triple/mobx_triple.dart';
import 'package:triple/triple.dart';

class Counter {
  final value = MobXStore<int, Exception>.create(0);

  increment() {
    value.setState(value.state + 1);
  }
}
