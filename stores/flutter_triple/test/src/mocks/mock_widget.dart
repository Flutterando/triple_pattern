import 'package:flutter/material.dart';

class MockWidget extends StatelessWidget {
  final Widget child;
  const MockWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}
