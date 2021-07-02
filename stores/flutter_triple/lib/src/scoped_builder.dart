import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

typedef TransitionCallback = Widget Function(BuildContext context, Widget child);

class ScopedBuilder<TStore extends Store<TError, TState>, TError extends Object, TState extends Object> extends StatefulWidget {
  final dynamic Function(TState state)? distinct;
  final bool Function(TState state)? filter;
  final Widget Function(BuildContext context, TState state)? onState;
  final Widget Function(BuildContext context, TError? error)? onError;
  final Widget Function(BuildContext context)? onLoading;
  final TStore store;

  const ScopedBuilder({Key? key, this.distinct, this.filter, this.onState, this.onError, this.onLoading, required this.store})
      : assert(onState != null || onError != null || onLoading != null, 'Define at least one listener (onState, onError or onLoading)'),
        assert(distinct == null ? true : onState != null, 'Distinct needs onState implementation'),
        assert(filter == null ? true : onState != null, 'Filter needs onState implementation'),
        super(key: key);

  factory ScopedBuilder.transition({
    Key? key,
    required TStore store,
    dynamic Function(TState)? distinct,
    bool Function(TState)? filter,
    TransitionCallback? transition,
    Widget Function(BuildContext, TError?)? onError,
    Widget Function(BuildContext)? onLoading,
    Widget Function(BuildContext, TState)? onState,
  }) {
    return ScopedBuilder(
      key: key,
      store: store,
      distinct: distinct,
      filter: filter,
      onState: onState == null
          ? null
          : (context, state) {
              final child = onState.call(context, state);
              if (transition != null) {
                return transition(context, child);
              } else {
                return AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: child);
              }
            },
      onLoading: onLoading == null
          ? null
          : (context) {
              final child = onLoading.call(context);
              if (transition != null) {
                return transition(context, child);
              } else {
                return AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: child);
              }
            },
      onError: onError == null
          ? null
          : (context, error) {
              final child = onError.call(context, error);
              if (transition != null) {
                return transition(context, child);
              } else {
                return AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: child);
              }
            },
    );
  }

  @override
  _ScopedBuilderState<TStore, TError, TState> createState() => _ScopedBuilderState<TStore, TError, TState>();
}

class _ScopedBuilderState<TStore extends Store<TError, TState>, TError extends Object, TState extends Object> extends State<ScopedBuilder<TStore, TError, TState>> {
  Disposer? disposer;

  var _distinct;

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
          setState(() {});
        }
      },
      onError: (error) {
        if (widget.onError != null && !isDisposed) {
          setState(() {});
        } else if (widget.onError == null && widget.onState != null && !isDisposed) {
          setState(() {});
        }
      },
      onLoading: (isLoading) {
        if (widget.onLoading != null && !isDisposed && isLoading) {
          setState(() {});
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
    Widget? child;

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

    return child!;
  }
}
