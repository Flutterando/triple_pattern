// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';

import '../components/square_widget.dart';
import '../stores/home_store.dart';
import '../stores/square_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final store = HomeStore();
  late Disposer _disposer;

  late OverlayEntry loadingOverlay = OverlayEntry(
    builder: (_) {
      return Container(
        alignment: Alignment.center,
        color: Colors.black38,
        child: const CircularProgressIndicator(),
      );
    },
  );

  @override
  void initState() {
    super.initState();

    _disposer = store.observer(
      onLoading: (isLoading) {
        if (store.isLoading) {
          Overlay.of(context)?.insert(loadingOverlay);
        } else {
          loadingOverlay.remove();
        }
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(store.error?.message ?? 'Erro disconhecido'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    store.destroy();
    _disposer();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.030;

    List<SquareWidget> generateSquares(List<SquareStore> squares) {
      return squares.map((square) => SquareWidget(square: square)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Square Counter'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: store.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: store.redo),
        ],
      ),
      body: ScopedBuilder<HomeStore, Exception, List<SquareStore>>(
        store: store,
        onState: (_, squares) {
          if (squares.isEmpty) {
            return const Center(
              child: Text('Adicione um Square'),
            );
          }

          return Padding(
            padding: EdgeInsets.only(left: spacing * 0.75),
            child: Wrap(
              spacing: spacing,
              children: generateSquares(squares),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: store.addSquare,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 5),
          FloatingActionButton(
            onPressed: store.removeSquare,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
