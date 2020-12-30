import 'package:flutter_triple/flutter_triple.dart';

class Counter extends StreamStore<Exception, int> with MementoMixin {
  Counter() : super(0);

  Future<void> increment() async {
    setLoading(true);
    await Future.delayed(Duration(milliseconds: 1000));
    update(state + 1);
    setLoading(false);
  }
}
