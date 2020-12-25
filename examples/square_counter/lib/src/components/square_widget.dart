import 'package:square_counter/src/stores/square_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';

class SquareWidget extends StatefulWidget {
  final SquareStore square;

  SquareWidget({Key? key, required this.square}) : super(key: key);

  @override
  _SquareWidgetState createState() => _SquareWidgetState();
}

class _SquareWidgetState extends State<SquareWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: widget.square.increment,
        onLongPress: widget.square.reset,
        child: Card(
          elevation: 7,
                  child: Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 10),
            child: ScopedBuilder(
              store: widget.square,
              onState: (_, state) {
                return Text(
                  "$state",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
