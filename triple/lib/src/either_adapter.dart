abstract class EitherAdapter<Left, Right> {
  dynamic fold(dynamic Function(Left l) leftF, dynamic Function(Right l) rightF);
}
