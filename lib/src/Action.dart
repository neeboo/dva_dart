import 'dart:convert';

class Action<P> {
  final String type;
  final P payload;
  Action({this.type, this.payload});
  @override
  String toString() {
    return 'Action(${this.type},${this.payload})';
  }
}

class Payload<T> {
  T payload;

  Map get payloadObject => {'payload': this.payload};

  String get payloadString => json.encode(this.payloadObject);

  Payload(this.payload);

  /// enode json
  @override
  String toString() => this.payloadString;
}

typedef ActionCreator<T>(T type);

ActionCreator createAction<T>(String type) {
  return (payload) => Action<T>(type: type, payload: payload);
}
