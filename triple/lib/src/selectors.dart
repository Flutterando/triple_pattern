abstract class Selectors<StateRx, ErrorRx, LoadingRx> {
  ///Select the reativide State segment
  StateRx get selectState;

  ///Select the reativide Error segment
  ErrorRx get selectError;

  ///Select the reativide Loading segment
  LoadingRx get selectLoading;
}
