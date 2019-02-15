import 'dart:async';
import 'package:dva_dart/src/Model.dart';
import 'package:dva_dart/src/Effect.dart';
import 'package:dva_dart/src/State.dart';
import 'package:dva_dart/src/Action.dart';
import 'package:dva_dart/src/Store.dart';
import 'package:dva_dart/src/Reducer.dart';

enum ContractStatus {
  INITIALISED,
  TESTED,
  ERROR,
  SIGNED,
  SENT,
  REJECTED,
  DEPLOYED
}

//
//
//
//
class TestState implements State {
  final int a;
  final int b;
  final int c;
  TestState(this.a, this.b, this.c);
  @override
  String toString() {
    // TODO: implement toString
    return 'TestState($a,$b,$c)';
  }
}

class MutatedState implements State {
  final String a;
  MutatedState(this.a);
  @override
  String toString() {
    return 'MutatedState(${this.a})';
  }
}

class MyReducerDelegate implements ReducerDelegate {
  @override
  void onReducer(Reducer reducer) {
    print(reducer.toString());
  }
}

void main() async {
  var pl1 = Payload<Map>({'a': 1});

  var pl2 = Payload<Map>({'b': 10});

  Future add(p) async {
    return await p + 1;
  }

  //
  //
  //
  // ReducerWatcher().delegate = MyReducerDelegate();

  DvaModel model =
      DvaModel(nameSpace: 'test', initialState: TestState(1, 2, 3), reducers: {
    'updateState': (State state, Payload payload) {
      return MutatedState(payload.toString());
    },
  }, effects: {
    'asyncAdd': (Payload<Map> payload) async* {
      var added = await add(payload.payloadObject['payload']['a']);
      payload.payloadObject['payload']
          .update('a', (value) => value = added, ifAbsent: () => {'a': added});
      await Future<void>.delayed(Duration(seconds: 1));
      yield PutEffect(key: 'updateState', payload: payload);
    },
    'appending': (Payload payload) async* {
      yield PutEffect(key: 'updateState', payload: payload);
    }
  });

  DvaModel model2 =
      DvaModel(nameSpace: 'test2', initialState: TestState(1, 2, 3), reducers: {
    'updateState': (State state, Payload payload) {
      return MutatedState(payload.toString());
    },
  }, effects: {
    'asyncAdd': (Payload<Map> payload) async* {
      var added = await add(payload.payloadObject['payload']['a']);
      payload.payloadObject['payload']
          .update('a', (value) => value = added, ifAbsent: () => {'a': added});
      await Future<void>.delayed(Duration(seconds: 1));
      yield PutEffect(key: 'updateState', payload: payload);
    },
    'appending': (Payload payload) async* {
      yield PutEffect(key: 'updateState', payload: payload);
    }
  });

  DvaStore store = DvaStore(models: <DvaModel>[model, model2]);
  Action abc1 = createAction('test/asyncAdd')(pl1);
  Action abc2 = createAction('test2/appending')(pl2);
  // Action abc3 = createAction('test/appending')(pl);

  // final StreamSubscription subscription =
  //     store.storeController.stream.listen((onData) {
  //   print(onData);
  // });
  // store.dispatch(abc1);
  // store.dispatch(abc2);

  // 初始化一个监听

  store.stateStream.listen((onData) {
    print(onData);
  });
  store.dispatch(abc1);
  store.dispatch(abc2);

  // store.dispatch(abc3);

  // var initState = State(initialState: {'abc': '@@@'});
  // var result = DvaStore(abc, initState);
  // var putInitialized = PutEffect(actionType: abc.type);
  // var putReducer=Reducer(actionType: abc.type)

  // print(putInitialized.actionType);

  // result.dispatch(abc);
  // print(result.mapActionToState(result.currentState, abc));

  //print(abc.payload.payload['foo']['baz']);

  // var result = asynchronousNaturalsTo(
  //     n: Future.value(100),
  //     k: (d) async {
  //       return await d + 1;
  //     }).last;
  // print(await result);

  // print(result);
  // var eee = ContractStatus.REJECTED.toString();

  // var value = ({Payload payload, Function callFunc}) async* {
  //   yield callFunc(payload);
  // };

  // var key = 'func';
  // Map effect = Map.fromEntries([MapEntry(key, value)]);

  // effect['func'](payload: pl, callFunc: print).toList().then((d) => d);
}
