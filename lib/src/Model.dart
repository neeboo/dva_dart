import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:dva_dart/src/Effect.dart';
import 'package:dva_dart/src/Reducer.dart';
import 'package:dva_dart/src/Action.dart';

abstract class BaseModel<S, T, D> {
  String nameSpace;
  S initialState;
  T reducers;
  D effects;
}

abstract class ReducerDelegate {
  void onReducer(DvaReducer transition);
}

class DvaModel<S>
    implements BaseModel<S, Map<String, dynamic>, Map<String, dynamic>> {
  final PublishSubject _actionSubject = PublishSubject();
  final PublishSubject<PutEffect> _putSubject = PublishSubject<PutEffect>();
  final PublishSubject<CallEffect> _callSubject = PublishSubject<CallEffect>();

  String nameSpace;
  Stream<S> get state => _stateSubject.stream;
  S initialState;
  Map<String, dynamic> reducers;
  Map<String, dynamic> effects;
  List<String> _allEffectKeys;
  Function _storeDispatch;

  ///
  BehaviorSubject<S> _stateSubject;
  S get currentState => _stateSubject.value;
  DvaModel({
    String nameSpace,
    S initialState,
    Map<String, dynamic> reducers,
    Map<String, dynamic> effects,
  }) {
    this.nameSpace = nameSpace ?? '';
    this.initialState = initialState ?? {};
    this.reducers = reducers ?? {};
    this.effects = effects ?? {};
    // this.subscriptions = subscriptions ?? {};
    _stateSubject = BehaviorSubject<S>.seeded(initialState);
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

  void setAllEffectKeys(List<String> keys) {
    _allEffectKeys = keys;
  }

  void setStoreDispatch(Function cb) {
    _storeDispatch = cb;
  }

  void debounceEffect(key, payload) {
    try {
      var foundEffect = _allEffectKeys.singleWhere((k) {
        return k == key;
      });
      if (foundEffect != null) {
        _storeDispatch(createAction(key)(payload));
      }
    } catch (e) {
      throw 'There is no Effect key found: $key';
    }
  }

  void dispose() {
    _putSubject.close();
    _callSubject.close();
    _actionSubject.close();
    _stateSubject.close();
  }

  void onReducer(DvaReducer<S, PutEffect> reducer) => null;

  Stream<DvaEffect> transform(Stream<DvaEffect> effect) => effect;
  Stream<S> mapPutEffectToReducer(S currentState, PutEffect effect) async* {
    if (reducers.containsKey(effect.key)) {
      var state = reducers[effect.key](currentState, effect.payload);
      yield state;
    } else {
      debounceEffect(effect.key, effect.payload);
      // yield null;
    }
  }

  void _bindStateSubject() {
    PutEffect currentPutEffect;
    (transform(_putSubject) as Observable<PutEffect>)
        .concatMap((PutEffect put) {
      currentPutEffect = put;
      return mapPutEffectToReducer(_stateSubject.value, put);
    }).forEach(
      (S nextState) {
        if (currentState == nextState) return;
        final transition = DvaReducer(
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

  ReducerWatcher._internal();
}
