import "dart:async";
import 'Action.dart';

abstract class DvaEffect<T> {
  Completer<T> completer;
}

class PutEffect extends DvaEffect {
  String key;
  Payload payload;
  PutEffect({this.key, this.payload});
  bool operator ==(other) {
    return (other is PutEffect && other.key == this.key);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
  @override
  String toString() {
    return 'PutEffect(${this.key},${this.payload})';
  }
}

abstract class CallableEffect extends DvaEffect implements Function {
  Future call();
}

typedef Future<T> _FutureFunc<T>(params);

class CallEffect<T> extends CallableEffect {
  _FutureFunc<T> futureFunc;
  Object params;
  CallEffect.value(Future<T> value) {
    this.futureFunc = (_) => value;
  }

  CallEffect.func(this.futureFunc, this.params);

  @override
  Future<T> call() async {
    return await futureFunc(this.params);
  }
}
