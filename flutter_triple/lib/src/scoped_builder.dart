import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

class ScopedBuilder<TState extends Object, TError extends Object>
    extends StatefulWidget {
  final Widget Function(BuildContext context, TState state) onState;
  final Widget Function(BuildContext context, TError? error)? onError;
  final Widget Function(BuildContext context)? onLoading;
  final Store<TState, TError> store;

  const ScopedBuilder(
      {Key? key,
      required this.onState,
      this.onError,
      this.onLoading,
      required this.store})
      : super(key: key);

  @override
  _ScopedBuilderState<TState, TError> createState() =>
      _ScopedBuilderState<TState, TError>();
}

class _ScopedBuilderState<TState extends Object, TError extends Object>
    extends State<ScopedBuilder<TState, TError>> {
  bool isLoading = false;
  bool isError = false;
  Disposer? disposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (disposer != null) {
      disposer!.call();
    }
    disposer = widget.store.observer(
      onState: () {
        setState(() {
          isError = false;
        });
      },
      onError: () {
        if (widget.onError != null)
          setState(() {
            isError = true;
          });
      },
      onLoading: () {
        if (widget.onLoading != null)
          setState(() {
            isLoading = widget.store.loading;
          });
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
    return Stack(
      children: [
        isError || widget.onError == null
            ? widget.onState(context, widget.store.state)
            : widget.onError!.call(context, widget.store.error),
        if (widget.onLoading != null && isLoading)
          widget.onLoading!.call(context),
      ],
    );
  }
}
