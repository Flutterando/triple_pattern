import 'package:flutter_triple/src/stores/notifier_store.dart';

class MockStore extends NotifierStore<String, int> {
  MockStore() : super(0);

  void updateWithValue(int state) => update(state);

  void updateWithError(String error) => setError(error);

  void enableLoading() => setLoading(true);

  void disableLoading() => setLoading(false);
}
