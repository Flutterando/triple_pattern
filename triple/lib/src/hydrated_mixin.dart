import 'package:meta/meta.dart';

import 'store.dart';

class _MutableFlags {
  bool hasInitiated = false;
}

abstract class HydratedDelegate {
  Future get(String key);
  Future save(String key, dynamic value);
  Future clear();
}

abstract class Serializable<T> {
  Map<String, dynamic> toMap();
  T fromMap(Map<String, dynamic> map);
}

class MemoryHydratedDelegate implements HydratedDelegate {
  dynamic _cachedValue;

  @override
  Future<void> clear() async {
    _cachedValue = null;
  }

  @override
  Future get(String key) async {
    return _cachedValue;
  }

  @override
  Future save(String key, value) async {
    assert(value is num || value is String || value is bool || value is List<String> || value is Map || value is Set || value is Serializable, 'not valid value');
    _cachedValue = value;
  }
}

mixin HydratedMixin<Error extends Object, State extends Object> on Store<Error, State> {
  final _flags = _MutableFlags();
  String get keyName => runtimeType.toString();

  bool get hasInitiated => _flags.hasInitiated;

  @protected
  @override
  void update(newState, {bool force = false}) {
    if (newState is Serializable) {
      _delegate.save(keyName, newState.toMap());
    } else {
      _delegate.save(keyName, newState);
    }
    super.update(newState, force: force);
  }

  @override
  void initStore() async {
    final s = await _delegate.get(runtimeType.toString());
    if (s != null) {
      late State value;
      if (state is Serializable) {
        value = (state as Serializable).fromMap(s);
      } else {
        value = s;
      }
      _flags.hasInitiated = true;
      update(value);
    }
  }
}

void setTripleHydratedDelegate(HydratedDelegate delegate) => _delegate = delegate;

HydratedDelegate _delegate = MemoryHydratedDelegate();
