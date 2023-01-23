// ignore_for_file: lines_longer_than_80_chars, avoid_bool_literals_in_conditional_expressions, library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_triple/src/widgets/scoped_builder.dart';
import 'package:triple/triple.dart';

///The typedef [TransitionCallback]
///receive Widget Function(BuildContext context, Widget child,)

///[ScopedConsumer] it's the type <TStore extends Store<TError, TState>, TError extends Object,
///TState extends Object>
class ScopedConsumer<TStore extends Store<TError, TState>,
    TError extends Object, TState extends Object> extends StatefulWidget {
  ///The Function [distinct] it's the type [dynamic] and receive the param state it`s the type [TState]
  final dynamic Function(TState state)? distinct;

  ///The Function [filter] it's the type [bool] and receive the param state it`s the type [TState]
  final bool Function(TState state)? filter;

  ///The Function [onState] it's the type [Widget] and receive the params context it's the type [BuildContext]
  ///and state it`s the type [TState]
  final Widget Function(BuildContext context, TState state)? onStateBuilder;

  ///The Function [onError] it's the type [Widget] and receive the params context it's the type [BuildContext] and
  ///error it`s the type [TError]
  final Widget Function(BuildContext context, TError? error)? onErrorBuilder;

  ///The Function [onLoading] it's the type [Widget] and receive the param context it`s the type [BuildContext]
  final Widget Function(BuildContext context)? onLoadingBuilder;

  ///The Function [onState] it's the type [Widget] and receive the params context it's the type [BuildContext]
  ///and state it`s the type [TState]
  final void Function(BuildContext context, TState state)? onState;

  ///The Function [onError] it's the type [Widget] and receive the params context it's the type [BuildContext] and
  ///error it`s the type [TError]
  final void Function(BuildContext context, TError? error)? onError;

  ///The Function [onLoading] it's the type [Widget] and receive the param context it`s the type [BuildContext]
  final void Function(BuildContext context, bool isLoadding)? onLoading;

  ///[store] it's the type [TStore]
  final TStore? store;

  ///[ScopedConsumer] constructor class
  const ScopedConsumer({
    Key? key,
    this.distinct,
    this.filter,
    this.onState,
    this.onError,
    this.onLoading,
    this.store,
    this.onStateBuilder,
    this.onErrorBuilder,
    this.onLoadingBuilder,
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

  ///[ScopedConsumer.transition] it's a [factory]
  factory ScopedConsumer.transition({
    Key? key,
    TStore? store,
    dynamic Function(TState)? distinct,
    bool Function(TState)? filter,
    TransitionCallback? transition,
    Widget Function(BuildContext, TError?)? onError,
    Widget Function(BuildContext)? onLoading,
    Widget Function(BuildContext, TState)? onState,
  }) {
    return ScopedConsumer(
      key: key,
      store: store,
      distinct: distinct,
      filter: filter,
      onStateBuilder: onState == null
          ? null
          : (context, state) {
              final child = onState.call(context, state);
              if (transition != null) {
                return transition(context, child);
              } else {
                return AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  child: child,
                );
              }
            },
      onLoadingBuilder: onLoading == null
          ? null
          : (context) {
              final child = onLoading.call(context);
              if (transition != null) {
                return transition(context, child);
              } else {
                return AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  child: child,
                );
              }
            },
      onErrorBuilder: onError == null
          ? null
          : (context, error) {
              final child = onError.call(context, error);
              if (transition != null) {
                return transition(context, child);
              } else {
                return AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  child: child,
                );
              }
            },
    );
  }

  @override
  _ScopedConsumerState<TStore, TError, TState> createState() =>
      _ScopedConsumerState<TStore, TError, TState>();
}

class _ScopedConsumerState<TStore extends Store<TError, TState>,
        TError extends Object, TState extends Object>
    extends State<ScopedConsumer<TStore, TError, TState>> {
  Disposer? disposer;

  var _distinct;

  bool isDisposed = false;

  final Function eq = const ListEquality().equals;

  var _tripleEvent = TripleEvent.state;
  late TStore store;

  @override
  void initState() {
    super.initState();
    store = widget.store ?? getTripleResolver<TStore>();
    _tripleEvent = store.triple.event;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    disposer?.call();

    disposer = store.observer(
      onState: (state) {
        final value = widget.distinct?.call(state);
        var isReload = true;
        if (value != null) {
          isReload = value is List ? !eq(value, _distinct) : value != _distinct;
        }
        _distinct = value;

        final filter = widget.filter?.call(state) ?? true;
        if (widget.onState != null &&
            !isDisposed &&
            isReload &&
            filter &&
            mounted) {
          setState(() {
            widget.onState?.call(context, state);
            _tripleEvent = TripleEvent.state;
          });
        }
      },
      onError: (error) {
        if (widget.onError != null && !isDisposed && mounted) {
          setState(() {
            widget.onError?.call(context, error);
            _tripleEvent = TripleEvent.error;
          });
        } else if (widget.onError == null &&
            widget.onState != null &&
            !isDisposed) {
          setState(() {
            widget.onError?.call(context, error);
            _tripleEvent = TripleEvent.error;
          });
        }
      },
      onLoading: (isLoading) {
        if (widget.onLoading != null && !isDisposed && isLoading && mounted) {
          setState(() {
            _tripleEvent = TripleEvent.loading;
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
    Widget? child;

    switch (_tripleEvent) {
      case TripleEvent.loading:
        child = store.triple.isLoading
            ? widget.onLoadingBuilder?.call(context)
            : widget.onStateBuilder?.call(context, store.state);
        break;
      case TripleEvent.error:
        child = widget.onErrorBuilder?.call(context, store.error);
        break;
      case TripleEvent.state:
        child = widget.onStateBuilder?.call(context, store.state);
        _distinct = widget.distinct?.call(store.state);
        break;
    }
    child ??= widget.onLoadingBuilder?.call(context);
    child ??= widget.onErrorBuilder?.call(context, store.error);
    child ??= widget.onStateBuilder?.call(context, store.state);

    return child!;
  }
}
