import 'dart:convert';

class Action {
  final String type;
  final dynamic payload;
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

typedef ActionCreator(dynamic type);

ActionCreator createAction(dynamic type) {
  return (payload) => Action(type: type.toString(), payload: payload);
}
