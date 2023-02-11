// ignore_for_file: lines_longer_than_80_chars, prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

///[TripleConsumer] class it's the type <TStore extends Store<TError, TState>,
///TError extends Object, TState extends Object>
class TripleConsumer<TStore extends Store<TError, TState>,
    TError extends Object, TState extends Object> extends StatefulWidget {
  ///The Function [builder] it's the type [Widget] and receive
  ///the params context it`s the type [BuildContext] and triple it's
  ///the type Triple<TError, TState>

  final Widget Function(
    BuildContext context,
    Triple<TError, TState> triple,
  ) builder;

  ///The Function [listener] it's the type void and receive
  ///the params context it`s the type [BuildContext] and triple it's
  ///the type Triple<TError, TState>
  final void Function(
    BuildContext context,
    Triple<TError, TState> triple,
  ) listener;

  ///The Function [filter] it's the type [bool] and receive the
  ///param triple it`s the type Triple<TError, TState>

  final bool Function(Triple<TError, TState> triple)? filter;

  ///The Function [distinct] it's the type [dynamic] and receive the
  ///param state it`s the type Triple<TError, TState>
  final dynamic Function(Triple<TError, TState> state)? distinct;

  ///[store] it's the type [TStore]
  final TStore? store;

  ///[TripleConsumer] constructor class
  const TripleConsumer({
    Key? key,
    this.store,
    required this.builder,
    required this.listener,
    this.filter,
    this.distinct,
  }) : super(key: key);

  @override
  _TripleConsumerState<TStore, TError, TState> createState() =>
      _TripleConsumerState<TStore, TError, TState>();
}

class _TripleConsumerState<TStore extends Store<TError, TState>,
        TError extends Object, TState extends Object>
    extends State<TripleConsumer<TStore, TError, TState>> {
  Widget? child;

  var _distinct;

  bool isDisposed = false;

  final Function eq = const ListEquality().equals;

  Disposer? disposer;

  late TStore store;

  @override
  void initState() {
    super.initState();
    store = widget.store ?? getTripleResolver<TStore>();
  }

  void _listener(dynamic value) {
    final value = widget.distinct?.call(store.triple);
    var isReload = true;
    if (value != null) {
      isReload = value is List ? !eq(value, _distinct) : value != _distinct;
    }
    _distinct = value;

    final filter = widget.filter?.call(store.triple) ?? true;
    if (!isDisposed && isReload && filter) {
      setState(() {
        widget.listener(context, store.triple);
        child = widget.builder(context, store.triple);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (disposer != null) {
      disposer!.call();
    }
    disposer = store.observer(
      onState: _listener,
      onError: _listener,
      onLoading: _listener,
    );
  }

  @override
  void dispose() {
    disposer?.call();
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    child = widget.builder(context, store.triple);
    _distinct = widget.distinct?.call(store.triple);
    widget.listener(context, store.triple);
    return child!;
  }
}
