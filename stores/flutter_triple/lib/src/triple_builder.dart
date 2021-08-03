import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

class TripleBuilder<TStore extends Store<TError, TState>, TError extends Object,
    TState extends Object> extends StatefulWidget {
  final Widget Function(BuildContext context, Triple<TError, TState> triple)
      builder;
  final bool Function(Triple<TError, TState> triple)? filter;
  final dynamic Function(Triple<TError, TState> state)? distinct;
  final TStore store;

  const TripleBuilder({
    Key? key,
    required this.store,
    required this.builder,
    this.filter,
    this.distinct,
  }) : super(key: key);

  @override
  _TripleBuilderState<TStore, TError, TState> createState() =>
      _TripleBuilderState<TStore, TError, TState>();
}

class _TripleBuilderState<TStore extends Store<TError, TState>,
        TError extends Object, TState extends Object>
    extends State<TripleBuilder<TStore, TError, TState>> {
  Widget? child;

  var _distinct;

  bool isDisposed = false;

  final Function eq = const ListEquality().equals;

  Disposer? disposer;

  void _listener(dynamic value) {
    final value = widget.distinct?.call(widget.store.triple);
    bool isReload = true;
    if (value != null) {
      isReload = value is List ? !eq(value, _distinct) : value != _distinct;
    }
    _distinct = value;

    final filter = widget.filter?.call(widget.store.triple) ?? true;
    if (!isDisposed && isReload && filter) {
      setState(() {
        child = widget.builder(context, widget.store.triple);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (disposer != null) {
      disposer!.call();
    }
    disposer = widget.store.observer(
      onState: _listener,
      onError: _listener,
      onLoading: _listener,
    );
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
    disposer?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      child = widget.builder(context, widget.store.triple);
      _distinct = widget.distinct?.call(widget.store.triple);
    }
    return child!;
  }
}
