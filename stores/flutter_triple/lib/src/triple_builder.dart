import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

class TripleBuilder<TStore extends Store<TError, TState>, TError extends Object,
    TState extends Object> extends StatefulWidget {
  final Widget Function(BuildContext context, Triple<TError, TState> triple)
      builder;
  final bool Function(Triple<TError, TState> triple)? selector;
  final TStore store;

  const TripleBuilder({
    Key? key,
    required this.store,
    required this.builder,
    this.selector,
  }) : super(key: key);

  @override
  _TripleBuilderState<TStore, TError, TState> createState() =>
      _TripleBuilderState<TStore, TError, TState>();
}

class _TripleBuilderState<TStore extends Store<TError, TState>,
        TError extends Object, TState extends Object>
    extends State<TripleBuilder<TStore, TError, TState>> {
  Widget? child;

  Disposer? disposer;

  void _listener(dynamic value) {
    final isSelected = widget.selector?.call(widget.store.triple) ?? true;
    if (isSelected) {
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
    super.dispose();
    disposer?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      child = widget.builder(context, widget.store.triple);
    }
    return child!;
  }
}
