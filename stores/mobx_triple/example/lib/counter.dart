import 'package:triple/triple.dart';

class Counter extends StreamStore<int, Exception> {
  Counter() : super(0);

  increment() {}
}
