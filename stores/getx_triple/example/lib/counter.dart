import 'package:getx_triple/store/getx_store.dart';

class CounterStore extends GetXStore<Exception, int> {
  CounterStore() : super(0);

  increment() => execute(_generateFuture);

  Future<int> _generateFuture() =>
      Future.delayed(Duration(seconds: 1)).then((value) => state + 1);
}
