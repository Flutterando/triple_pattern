import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

class TripleBuilder<TState extends Object, TError extends Object,
    TStore extends Store<TState, TError>> extends StatefulWidget {
  final Widget Function(BuildContext context, Triple<TState, TError> triple)
      builder;
  final bool Function(Triple<TState, TError> triple)? selector;
  final TStore store;

  const TripleBuilder({
    Key? key,
    required this.store,
    required this.builder,
    this.selector,
  }) : super(key: key);

  @override
  _TripleBuilderState<TState, TError, TStore> createState() =>
      _TripleBuilderState<TState, TError, TStore>();
}

class _TripleBuilderState<TState extends Object, TError extends Object,
        TStore extends Store<TState, TError>>
    extends State<TripleBuilder<TState, TError, TStore>> {
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
