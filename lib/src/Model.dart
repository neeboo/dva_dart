import 'package:rxdart/rxdart.dart';
import 'package:dva_dart/src/State.dart';
import 'package:dva_dart/src/Effect.dart';
import 'package:dva_dart/src/Reducer.dart';

abstract class BaseModel {}

abstract class ReducerDelegate {
  void onReducer(Reducer transition);
}

class DvaModel implements BaseModel {
  final PublishSubject _actionSubject = PublishSubject();
  final PublishSubject<PutEffect> _putSubject = PublishSubject<PutEffect>();
  final PublishSubject<CallEffect> _callSubject = PublishSubject<CallEffect>();

  String nameSpace;
  Stream<State> get state => _stateSubject.stream;
  State initialState;
  Map<String, dynamic> reducers;
  Map<String, dynamic> effects;

  ///
  BehaviorSubject<State> _stateSubject;
  State get currentState => _stateSubject.value;
  DvaModel({
    String nameSpace,
    State initialState,
    Map<String, dynamic> reducers,
    Map<String, dynamic> effects,
  }) {
    this.nameSpace = nameSpace ?? '';
    this.initialState = initialState ?? {};
    this.reducers = reducers ?? {};
    this.effects = effects ?? {};
    // this.subscriptions = subscriptions ?? {};
    _stateSubject = BehaviorSubject<State>(seedValue: initialState);
    _bindStateSubject();
  }
  void dispatch(Stream action) {
    action.forEach((s) {
      if (s is PutEffect) {
        _putSubject.sink.add(s);
      } else if (s is CallEffect) {
        _callSubject.sink.add(s);
      } else {
        _actionSubject.sink.add(s);
      }
    });
  }

  void dispose() {
    _putSubject.close();
    _callSubject.close();
    _actionSubject.close();
    _stateSubject.close();
  }

  void onReducer(Reducer<State, PutEffect> reducer) => null;

  Stream<Effect> transform(Stream<Effect> effect) => effect;
  Stream<State> mapPutEffectToReducer(
      State currentState, PutEffect effect) async* {
    if (reducers.containsKey(effect.key)) {
      var state = reducers[effect.key](currentState, effect.payload);
      yield state;
    } else
      yield null;
  }

  void _bindStateSubject() {
    PutEffect currentPutEffect;
    (transform(_putSubject) as Observable<PutEffect>)
        .concatMap((PutEffect put) {
      currentPutEffect = put;
      return mapPutEffectToReducer(_stateSubject.value, put);
    }).forEach(
      (State nextState) {
        if (currentState == nextState) return;
        final transition = Reducer(
          currentState: _stateSubject.value,
          effect: currentPutEffect,
          nextState: nextState,
        );
        ReducerWatcher().delegate?.onReducer(transition);
        onReducer(transition);
        _stateSubject.add(nextState);
      },
    );
  }
}

class ReducerWatcher {
  ReducerDelegate delegate;

  static final ReducerWatcher _singleton = ReducerWatcher._internal();

  factory ReducerWatcher() {
    return _singleton;
  }

  ReducerWatcher._internal() {}
}
