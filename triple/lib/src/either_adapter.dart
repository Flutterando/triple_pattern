///[EitherAdapter] abstract class
abstract class EitherAdapter<Left, Right> {
  ///[fold] method
  T fold<T>(
    T Function(Left l) leftF,
    T Function(Right l) rightF,
  );
}
