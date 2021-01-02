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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (disposer != null) {
      disposer!.call();
    }
    disposer = widget.store.observer(
      onState: (state) {
        if (widget.onState != null) {
          setState(() {
            child = widget.onState!(context, state);
          });
        }
      },
      onError: (error) {
        if (widget.onError != null) {
          setState(() {
            child = widget.onError!(context, error);
          });
        }
      },
      onLoading: (isLoading) {
        if (widget.onLoading != null) {
          setState(() {
            child = isLoading
                ? widget.onLoading!(context)
                : widget.onState!(context, widget.store.state);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    disposer?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      switch (widget.store.triple.event) {
        case (TripleEvent.loading):
          child = widget.onLoading!(context);
          break;
        case (TripleEvent.error):
          child = widget.onError!(context, widget.store.error);
          break;
        case (TripleEvent.state):
          child = widget.onState!(context, widget.store.state);
          break;
      }
    }
    return child!;
  }
}
