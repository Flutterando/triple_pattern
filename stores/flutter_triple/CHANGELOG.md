 ## [1.1.0] - 2021-06-27

 - Added [optional] **ScopedBuilder.create** for customization of main widget.
 ```dart 
 ScopedBuilder<Counter, Exception, int>(
    store: counter,
    create: (_, child) {
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: child,
      );
    },
    onLoading: (_) => Text('Loading...'),
    onState: (_, state) => Text('$state'),
  ),
 ```
 ## [1.0.6] - 2021-05-10

 - Update Triple package
 
 ## [1.0.5+1] - 2021-03-30

- Updated RxNotifier
- Updated Triple
- Updated documentation
 ## [1.0.0] - 2021-03-03

The Initial version providers:
- StreamStore and NotifierStore
- RxNotifier support
- Triple Tracking
- rxObserver
- ScopedBuilder and TripleBuilder
