import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

class ScopedBuilder<TState extends Object, TError extends Object,
    TStore extends Store<TState, TError>> extends StatefulWidget {
  final Widget Function(BuildContext context, TState state)? onState;
  final Widget Function(BuildContext context, TError? error)? onError;
  final Widget Function(BuildContext context, bool isLoading)? onLoading;
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
  _ScopedBuilderState<TState, TError, TStore> createState() =>
      _ScopedBuilderState<TState, TError, TStore>();
}

class _ScopedBuilderState<TState extends Object, TError extends Object,
        TStore extends Store<TState, TError>>
    extends State<ScopedBuilder<TState, TError, TStore>> {
  Widget? child;

  Disposer? disposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (disposer != null) {
      disposer!.call();
    }
    disposer = widget.store.observer(
      onState: () {
        if (widget.onState != null) {
          setState(() {
            child = widget.onState!(context, widget.store.state);
          });
        }
      },
      onError: () {
        if (widget.onError != null) {
          setState(() {
            child = widget.onError!(context, widget.store.error);
          });
        }
      },
      onLoading: () {
        if (widget.onLoading != null &&
            (widget.onState == null ? true : widget.store.loading)) {
          setState(() {
            child = widget.onLoading!(context, widget.store.loading);
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
      if (widget.onState != null) {
        child = widget.onState!(context, widget.store.state);
      } else if (widget.onError != null) {
        child = widget.onError!(context, widget.store.error);
      } else if (widget.onLoading != null) {
        child = widget.onLoading!(context, widget.store.loading);
      }
    }
    return child!;
  }
}
