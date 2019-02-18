import 'dart:async';
import 'package:dva_dart/src/Model.dart';
import 'package:dva_dart/src/Action.dart';
import 'package:rxdart/rxdart.dart';

class DvaStore<S> {
  List<DvaModel> models;
  List<ModelStream<StreamController<S>>> modelStreams;
  DvaModel currentModel;
  List<String> effectKeys = [];

  ///
  ///
  List<ModelInitialState<S>> get modelInitials => models
      .map<ModelInitialState<S>>(
          (m) => ModelInitialState(m.nameSpace, m.initialState))
      .toList();

  ///
  ///
  ///
  DvaStore({models}) {
    this.models = models;
    _createModelStreams();
    _getEffectKeys();
    _setEffectKeysToModel();
    _setDispatchToModel();
  }

  void dispatch(Action action) {
    var found = this._extractAction(action);
    DvaModel foundModel = found[0];
    currentModel = foundModel;
    var foundEffect = found[1];
    var foundPayload = found[2];
    foundModel.dispatch(foundEffect(foundPayload));
    foundModel.state.listen((onData) {
      modelStreams
          .singleWhere((m) {
            return m.nameSpace == foundModel.nameSpace;
          })
          .streamController
          .sink
          .add(onData);
    });
  }

  _createModelStreams() {
    modelStreams = List.generate(models.length, (index) {
      return ModelStream(models[index].nameSpace, BehaviorSubject<S>());
    }, growable: true);
  }

  _extractAction(Action action) {
    var type = action.type;
    String nameSpace = type.split(RegExp(r"/"))[0];
    String effectName = type.split(RegExp(r"/"))[1];

    var model = this.models.singleWhere((m) => m.nameSpace == nameSpace,
        orElse: () => throw NullThrownError);
    var effect = this._getEffect(effectName, model);
    var payload = this._getPayload(action);
    return [model, effect, payload];
  }

  _getEffect(String effectName, DvaModel model) {
    return model.effects.containsKey(effectName)
        ? model.effects[effectName]
        : throw NullThrownError;
  }

  _getPayload(Action action) {
    return action.payload;
  }

  _getEffectKeys() {
    return models.forEach((m) {
      effectKeys.addAll(m.effects.keys.map((d) => '${m.nameSpace}/${d}'));
    });
  }

  void _setEffectKeysToModel() {
    models.forEach((m) {
      m.setAllEffectKeys(effectKeys);
    });
  }

  void _setDispatchToModel() {
    models.forEach((m) {
      m.setStoreDispatch(dispatch);
    });
  }

  void dispose() {
    modelStreams.forEach((ms) {
      ms.streamController.close();
    });
  }

  Stream<S> getStream(String nameSpace) {
    return modelStreams
        .singleWhere((m) {
          return m.nameSpace == nameSpace;
        })
        .streamController
        .stream;
  }

  Stream<S> getStreamAsBroadcast(String nameSpace) {
    return modelStreams
        .singleWhere((m) {
          return m.nameSpace == nameSpace;
        })
        .streamController
        .stream
        .asBroadcastStream();
  }

  S getInitalState(String nameSpace) {
    return models.singleWhere((m) {
      return m.nameSpace == nameSpace;
    }).initialState;
  }

  Stream<S> getModelStream(String nameSpace) {
    return models.singleWhere((m) => m.nameSpace == nameSpace).state;
  }
}

class ModelStream<C> {
  String nameSpace;
  C streamController;
  ModelStream(this.nameSpace, this.streamController);
}

class ModelInitialState<S> {
  String nameSpace;
  S intialState;
  ModelInitialState(this.nameSpace, this.intialState);
}
