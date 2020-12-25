import 'package:square_counter/src/stores/square_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';

class SquareWidget extends StatelessWidget {
  final SquareStore square;

  SquareWidget({Key? key, required this.square}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: square.increment,
        onLongPress: square.reset,
        child: Card(
          elevation: 7,
          child: Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: ScopedBuilder(
              store: square,
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
