// ignore_for_file: lines_longer_than_80_chars, avoid_bool_literals_in_conditional_expressions, library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_triple/src/widgets/scoped_builder.dart';
import 'package:triple/triple.dart';

///The typedef [TransitionCallback]
///receive Widget Function(BuildContext context, Widget child,)

///[ScopedConsumer] it's the type Store<TState>
///TState >
class ScopedConsumer<TStore extends BaseStore<TState>, TState> extends StatefulWidget {
  ///The Function [distinct] it's the type [dynamic] and receive the param state it`s the type [TState]
  final dynamic Function(TState state)? distinct;

  ///The Function [filter] it's the type [bool] and receive the param state it`s the type [TState]
  final bool Function(TState state)? filter;

  ///The Function [onStateListener] it's the type [Widget] and receive the params context it's the type [BuildContext]
  ///and state it`s the type [TState]
  final Widget Function(BuildContext context, TState state)? onStateBuilder;

  ///The Function [onErrorListener] it's the type [Widget] and receive the params context it's the type [BuildContext] and
  ///error it`s the type.
  final Widget Function(BuildContext context, dynamic error)? onErrorBuilder;

  ///The Function [onLoadingListener] it's the type [Widget] and receive the param context it`s the type [BuildContext]
  final Widget Function(BuildContext context)? onLoadingBuilder;

  ///The Function [onStateListener] it's the type [Widget] and receive the params context it's the type [BuildContext]
  ///and state it`s the type [TState]
  final void Function(BuildContext context, TState state)? onStateListener;

  ///The Function [onErrorListener] it's the type [Widget] and receive the params context it's the type [BuildContext] and
  ///error it`s the type [dynamic]
  final void Function(BuildContext context, dynamic error)? onErrorListener;

  ///The Function [onLoadingListener] it's the type [Widget] and receive the param context it`s the type [BuildContext]
  final void Function(BuildContext context, bool isLoading)? onLoadingListener;

  ///[store] it's the type [TStore]
  final TStore? store;

  ///[ScopedConsumer] constructor class
  const ScopedConsumer({
    Key? key,
    this.distinct,
    this.filter,
    this.onStateListener,
    this.onErrorListener,
    this.onLoadingListener,
    this.store,
    this.onStateBuilder,
    this.onErrorBuilder,
    this.onLoadingBuilder,
  })  : assert(
          (onStateListener != null || onErrorListener != null || onLoadingListener != null) && (onStateBuilder != null || onErrorBuilder != null || onLoadingBuilder != null),
          'Define at least one listener (onStateListener, onErrorListener, onLoadingListener) or one builder (onStateBuilder, onErrorBuilder, onLoadingBuilder)',
        ),
        assert(
          distinct == null ? true : onStateListener != null,
          'Distinct needs onState implementation',
        ),
        assert(
          filter == null ? true : onStateListener != null,
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
    Widget Function(BuildContext, dynamic)? onErrorBuilder,
    Widget Function(BuildContext)? onLoadingBuilder,
    Widget Function(BuildContext, TState)? onStateBuilder,
    void Function(BuildContext, dynamic)? onErrorListener,
    void Function(BuildContext, bool)? onLoadingListener,
    void Function(BuildContext, TState)? onStateListener,
  }) {
    return ScopedConsumer(
      key: key,
      store: store,
      distinct: distinct,
      filter: filter,
      onStateListener: onStateListener,
      onErrorListener: onErrorListener,
      onLoadingListener: onLoadingListener,
      onStateBuilder: onStateBuilder == null
          ? null
          : (context, state) {
              final child = onStateBuilder.call(context, state);
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
      onLoadingBuilder: onLoadingBuilder == null
          ? null
          : (context) {
              final child = onLoadingBuilder.call(context);
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
      onErrorBuilder: onErrorBuilder == null
          ? null
          : (context, error) {
              final child = onErrorBuilder.call(context, error);
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
  _ScopedConsumerState<TStore, TState> createState() => _ScopedConsumerState<TStore, TState>();
}

class _ScopedConsumerState<TStore extends BaseStore<TState>, TState> extends State<ScopedConsumer<TStore, TState>> {
  Disposer? disposer;

  var _distinct;

  bool isDisposed = false;

  final Function eq = const ListEquality().equals;

  late TStore store;

  TripleEvent get _tripleEvent => store.triple.event;

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
        if (widget.onStateListener != null && !isDisposed && isReload && filter && mounted) {
          widget.onStateListener?.call(context, state);
        }

        if (widget.onStateBuilder != null && !isDisposed && isReload && filter && mounted) {
          setState(() {
            widget.onStateBuilder?.call(context, state);
          });
        }
      },
      onError: (error) {
        if (widget.onErrorListener != null && !isDisposed && mounted) {
          widget.onErrorListener?.call(context, error);
        }

        if (widget.onErrorBuilder != null && !isDisposed && mounted) {
          setState(() {
            widget.onErrorBuilder?.call(context, error);
          });
        }
      },
      onLoading: (isLoading) {
        if (widget.onLoadingListener != null && !isDisposed && isLoading && mounted) {
          widget.onLoadingListener?.call(context, isLoading);
        }
        if (widget.onLoadingBuilder != null && !isDisposed && isLoading && mounted) {
          setState(() {
            widget.onLoadingBuilder?.call(context);
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
        child = store.triple.isLoading ? widget.onLoadingBuilder?.call(context) : widget.onStateBuilder?.call(context, store.state);
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
