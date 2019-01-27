import 'package:meta/meta.dart';

class Reducer<State, T> {
  final State currentState;
  final T effect;
  final State nextState;

  const Reducer({
    @required this.currentState,
    @required this.effect,
    @required this.nextState,
  })  : assert(currentState != null),
        assert(effect != null),
        assert(nextState != null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reducer<State, T> &&
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
