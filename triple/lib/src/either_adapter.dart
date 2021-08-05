abstract class EitherAdapter<Left, Right> {
  T fold<T>(
    T Function(Left l) leftF,
    T Function(Right l) rightF,
  );
}
