import 'package:equatable/equatable.dart';

class SquareError extends Equatable implements Exception {
  final String message;

  SquareError(this.message);

  @override
  String toString() => message;

  @override
  late final List<Object?> props = [message];
}