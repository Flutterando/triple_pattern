 ## [1.2.4+2] - 2021-08-05
- Update triple;
 ## [1.2.3+2] - 2021-07-17
- Fix ScopedBuild in first event in triple;

 ## [1.2.1] - 2021-07-04
- Fix [#41](https://github.com/Flutterando/triple_pattern/issues/41)
 ## [1.2.0] - 2021-07-02

 - Added [factory] **ScopedBuilder.transition** for customization of main widget.
 ```dart 
 ScopedBuilder.transition(
    store: counter,
    transition: (_, child) {
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
