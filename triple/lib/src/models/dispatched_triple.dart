import 'package:triple/triple.dart';

class DispatchedTriple<Error extends Object, State extends Object> {
  late final Triple<Error, State> _triple;
  late final String storeTypeName;
  State get state => _triple.state;
  Error? get error => _triple.error;
  bool get isLoading => _triple.isLoading;
  TripleEvent get event => _triple.event;

  DispatchedTriple(Triple<Error, State> triple, Type storeType) {
    _triple = triple;
    storeTypeName = storeType.toString();
  }

  @override
  String toString() {
    if (event == TripleEvent.state) {
      return '$storeTypeName.state = $state';
    } else if (event == TripleEvent.error) {
      return '$storeTypeName.error = $error';
    } else if (event == TripleEvent.loading) {
      return '$storeTypeName.isLoading = $isLoading';
    } else {
      return super.toString();
    }
  }
}
