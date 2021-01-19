import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

class ScopedBuilder<TStore extends Store<TError, TState>, TError extends Object, TState extends Object> extends StatefulWidget {
  final dynamic Function(TState state)? distinct;
  final bool Function(TState state)? filter;
  final Widget Function(BuildContext context, TState state)? onState;
  final Widget Function(BuildContext context, TError? error)? onError;
  final Widget Function(BuildContext context)? onLoading;
  final TStore store;

  const ScopedBuilder({Key? key, this.distinct, this.filter, this.onState, this.onError, this.onLoading, required this.store})
      : assert(onState != null || onError != null || onLoading != null, 'Define at least one listener (onState, onError or onLoading)'),
        super(key: key);

  @override
  _ScopedBuilderState<TStore, TError, TState> createState() => _ScopedBuilderState<TStore, TError, TState>();
}

class _ScopedBuilderState<TStore extends Store<TError, TState>, TError extends Object, TState extends Object> extends State<ScopedBuilder<TStore, TError, TState>> {
  Widget? child;

  Disposer? disposer;

  dynamic? _distinct;

  bool isDisposed = false;

  final Function eq = const ListEquality().equals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    disposer?.call();

    disposer = widget.store.observer(
      onState: (state) {
        final value = widget.distinct?.call(state);
        bool isReload = true;
        if (value != null) {
          isReload = value is List ? !eq(value, _distinct) : value != _distinct;
        }
        _distinct = value;

        final filter = widget.filter?.call(state) ?? true;
        if (widget.onState != null && !isDisposed && isReload && filter) {
          setState(() {
            child = widget.onState?.call(context, state);
          });
        }
      },
      onError: (error) {
        if (widget.onError != null && !isDisposed) {
          setState(() {
            child = widget.onError?.call(context, error);
          });
        }
      },
      onLoading: (isLoading) {
        if (widget.onLoading != null && !isDisposed && isLoading) {
          setState(() {
            child = widget.onLoading?.call(context);
          });
        }
      },
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
    if (child == null) {
      switch (widget.store.triple.event) {
        case (TripleEvent.loading):
          child = widget.store.triple.isLoading ? widget.onLoading?.call(context) : widget.onState?.call(context, widget.store.state);
          break;
        case (TripleEvent.error):
          child = widget.onError?.call(context, widget.store.error);
          break;
        case (TripleEvent.state):
          child = widget.onState?.call(context, widget.store.state);
          _distinct = widget.distinct?.call(widget.store.state);
          break;
      }
      if (child == null) {
        child = widget.onLoading?.call(context);
      }
      if (child == null) {
        child = widget.onError?.call(context, widget.store.error);
      }
      if (child == null) {
        child = widget.onState?.call(context, widget.store.state);
      }
    }
    return child!;
  }
}
