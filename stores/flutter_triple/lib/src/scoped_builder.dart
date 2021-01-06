import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

class ScopedBuilder<TStore extends Store<TError, TState>, TError extends Object,
    TState extends Object> extends StatefulWidget {
  final Widget Function(BuildContext context, TState state)? onState;
  final Widget Function(BuildContext context, TError? error)? onError;
  final Widget Function(BuildContext context)? onLoading;
  final TStore store;

  const ScopedBuilder(
      {Key? key,
      this.onState,
      this.onError,
      this.onLoading,
      required this.store})
      : assert(onState != null || onError != null || onLoading != null,
            'Define at least one listener (onState, onError or onLoading)'),
        super(key: key);

  @override
  _ScopedBuilderState<TStore, TError, TState> createState() =>
      _ScopedBuilderState<TStore, TError, TState>();
}

class _ScopedBuilderState<TStore extends Store<TError, TState>,
        TError extends Object, TState extends Object>
    extends State<ScopedBuilder<TStore, TError, TState>> {
  Widget? child;

  Disposer? disposer;

  bool isDisposed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    disposer?.call();

    disposer = widget.store.observer(
      onState: (state) {
        if (widget.onState != null && !isDisposed) {
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
        if (widget.onLoading != null && !isDisposed) {
          setState(() {
            child = isLoading
                ? widget.onLoading?.call(context)
                : widget.onState?.call(context, widget.store.state);
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
          child = widget.store.triple.isLoading
              ? widget.onLoading?.call(context)
              : widget.onState?.call(context, widget.store.state);
          break;
        case (TripleEvent.error):
          child = widget.onError?.call(context, widget.store.error);
          break;
        case (TripleEvent.state):
          child = widget.onState?.call(context, widget.store.state);
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
