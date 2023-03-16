// ignore_for_file: type_annotate_public_apis, lines_longer_than_80_chars

import 'package:meta/meta.dart';

import 'base_store.dart';

class _MutableFlags {
  bool hasInitiated = false;
}

///[HydratedDelegate] abstract class
abstract class HydratedDelegate {
  ///The method [get] it's the type [Future] and receive the
  ///param [key] it`s the type [String]
  Future get(String key);

  ///The method [save] it's the type [Future] and receive the
  ///params [key] it`s the type [String] and [value] it's the type [dynamic]
  Future save(String key, dynamic value);

  ///The method [clear] it's the type [Future]
  Future clear();
}

///[Serializable] abstract class
abstract class Serializable<T> {
  ///The method [toMap] it's the type Map<String, dynamic>
  Map<String, dynamic> toMap();

  ///The method [fromMap] it's the type generics [T] and receive
  ///the param [map] it's the type Map<String, dynamic>
  T fromMap(Map<String, dynamic> map);
}

///[MemoryHydratedDelegate] class implements [HydratedDelegate]
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
    assert(
      value is num || value is String || value is bool || value is List<String> || value is Map || value is Set || value is Serializable,
      'not valid value',
    );
    _cachedValue = value;
  }
}

///[HydratedMixin] mixin
mixin HydratedMixin<State> on BaseStore<State> {
  final _flags = _MutableFlags();

  ///[keyName] it's a get and it's the type [String]
  String get keyName => runtimeType.toString();

  ///[hasInitiated] it's a get and it's the type [bool]
  bool get hasInitiated => _flags.hasInitiated;

  @protected
  @override
  void update(newState, {bool force = false}) {
    if (newState is Serializable) {
      _delegate.save(keyName, newState.toMap());
    } else {
      _delegate.save(keyName, newState);
    }
    super.update(newState, force: true);
  }

  @override
  Future<void> initStore() async {
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

///The function [setTripleHydratedDelegate] it's the type void and
///receive the param [delegate] it's the type [HydratedDelegate]
void setTripleHydratedDelegate(
  HydratedDelegate delegate,
) =>
    _delegate = delegate;

HydratedDelegate _delegate = MemoryHydratedDelegate();
