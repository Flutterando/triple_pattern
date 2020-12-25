import 'package:triple/triple.dart';

class Counter extends StreamStore<int, Exception> {
  Counter() : super(0);

  Future<void> increment() async {
    setLoading(true);
    await Future.delayed(Duration(milliseconds: 1000));
    setState(state + 1);
    setLoading(false);
  }
}
