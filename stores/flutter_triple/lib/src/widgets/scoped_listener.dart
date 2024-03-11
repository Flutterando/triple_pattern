// ignore_for_file: lines_longer_than_80_chars, avoid_bool_literals_in_conditional_expressions, library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

///[ScopedListener] it's the type <TStore extends Store<TError, TState>, TError extends Object,
///TState extends Object>
class ScopedListener<TStore extends BaseStore<TState>, TState> extends StatefulWidget {
  ///The Function [distinct] it's the type [dynamic] and receive the param state it`s the type [TState]
  final dynamic Function(TState state)? distinct;

  ///The Function [filter] it's the type [bool] and receive the param state it`s the type [TState]
  final bool Function(TState state)? filter;

  ///The Function [onState] it's the type [Widget] and receive the params context it's the type [BuildContext]
  ///and state it`s the type [TState]
  final void Function(BuildContext context, TState state)? onState;

  ///The Function [onError] it's the type [Widget] and receive the params context it's the type [BuildContext] and
  ///error it`s the type [dynamic]
  final void Function(BuildContext context, dynamic error)? onError;

  ///The Function [onLoading] it's the type [Widget] and receive the param context it`s the type [BuildContext]
  final void Function(BuildContext context, bool isLoadding)? onLoading;

  ///[store] it's the type [TStore]
  final TStore? store;

  /// The widget which will be rendered as a descendant of the [ScopedListener].
  final Widget child;

  ///[ScopedListener] constructor class
  const ScopedListener({
    Key? key,
    this.distinct,
    this.filter,
    this.onState,
    this.onError,
    this.onLoading,
    this.store,
    required this.child,
  })  : assert(
          onState != null || onError != null || onLoading != null,
          'Define at least one listener (onState, onError or onLoading)',
        ),
        assert(
          distinct == null ? true : onState != null,
          'Distinct needs onState implementation',
        ),
        assert(
          filter == null ? true : onState != null,
          'Filter needs onState implementation',
        ),
        super(key: key);

  @override
  _ScopedListenerState<TStore, TState> createState() => _ScopedListenerState<TStore, TState>();
}

class _ScopedListenerState<TStore extends BaseStore<TState>, TState> extends State<ScopedListener<TStore, TState>> {
  Disposer? disposer;

  var _distinct;

  bool isDisposed = false;

  final Function eq = const ListEquality().equals;

  late TStore store;

  @override
  void initState() {
    super.initState();
    store = widget.store ?? getTripleResolver<TStore>();
  }

  @override
  void didChangeDependencies() {
    disposer?.call();
    super.didChangeDependencies();

    disposer = store.observer(
      onState: (state) {
        final value = widget.distinct?.call(state);
        var isReload = true;
        if (value != null) {
          isReload = value is List ? !eq(value, _distinct) : value != _distinct;
        }
        _distinct = value;

        final filter = widget.filter?.call(state) ?? true;
        if (widget.onState != null && !isDisposed && isReload && filter && mounted) {
          widget.onState!(context, state);
        }
      },
      onError: (error) {
        if (widget.onError != null && !isDisposed && mounted) {
          widget.onError!(context, error);
        } else if (widget.onError == null && widget.onState != null && !isDisposed) {
          widget.onError!(context, error);
        }
      },
      onLoading: (isLoading) {
        if (widget.onLoading != null && !isDisposed && isLoading && mounted) {
          widget.onLoading!(context, isLoading);
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
    return widget.child;
  }
}
