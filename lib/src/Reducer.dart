import 'package:meta/meta.dart';

class DvaReducer<S, T> {
  final S currentState;
  final T effect;
  final S nextState;

  const DvaReducer({
    @required this.currentState,
    @required this.effect,
    @required this.nextState,
  })  : assert(currentState != null),
        assert(effect != null),
        assert(nextState != null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DvaReducer<S, T> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          nextState == other.nextState;

  @override
  int get hashCode =>
      currentState.hashCode ^ effect.hashCode ^ nextState.hashCode;

  @override
  String toString() =>
      'Reducer { currentState: $currentState, effect: $effect, nextState: $nextState }';
}
