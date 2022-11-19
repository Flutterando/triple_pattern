import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:square_counter/src/stores/square_store.dart';

class SquareWidget extends StatelessWidget with RxMixin {
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
            child: Text(
              '${square.state}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
