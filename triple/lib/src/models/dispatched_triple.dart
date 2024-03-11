import 'package:triple/triple.dart';

///[DispatchedTriple] class
class DispatchedTriple<State> {
  ///[_triple] it's the type Triple<Error, State>
  late final Triple<State> _triple;

  ///[storeTypeName] it's the type [String]
  late final String storeTypeName;

  ///[state] it's a get and it's the type [String]
  State get state => _triple.state;

  ///[error] it's a get and it's the type [dynamic]
  dynamic get error => _triple.error;

  ///[isLoading] it's a get and it's the type [bool]
  bool get isLoading => _triple.isLoading;

  ///[event] it's a get and it's the type [TripleEvent]
  TripleEvent get event => _triple.event;

  ///[DispatchedTriple] constructor class
  DispatchedTriple(Triple<State> triple, Type storeType) {
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
