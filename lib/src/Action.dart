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

class Payload {
  Map _payloadStore;

  Map get payload => this._payloadStore;

  String get payloadString => json.encode(this.payload);

  Payload(this._payloadStore);

  factory Payload.create() {
    return Payload(Map());
  }

  /// create map for store
  void update({String key, dynamic value}) {
    _payloadStore.update(key, (val) => value, ifAbsent: () => value);
  }

  /// build all payload to map
  Payload build() {
    return this;
  }

  /// enode json
  @override
  String toString() => this.payloadString;
}

typedef ActionCreator(dynamic type);

ActionCreator createAction(dynamic type) {
  return (payload) => Action(type: type.toString(), payload: payload);
}
