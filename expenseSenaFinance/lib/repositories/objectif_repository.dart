

import 'package:senafinance/models/objectif_model.dart';
import 'package:senafinance/models/versement_model.dart';
import 'package:senafinance/services/objectif_service.dart';

class ObjectifRepository {
  final ObjectifService _service;

  ObjectifRepository({ObjectifService? service})
    : _service = service ?? ObjectifService();

  Future<List<ObjectifModel>> getObjectifs() async {
    final data = await _service.getObjectifs();
    return data.map((json) => ObjectifModel.fromJson(json)).toList();
  }

  Future<ObjectifModel> createObjectif(ObjectifModel objectif) async {
    final data = await _service.createObjectif(objectif.toJson());
    return ObjectifModel.fromJson(data);
  }

  Future<ObjectifModel> updateObjectif(ObjectifModel objectif) async {
    if (objectif.id == null) {
      throw Exception('Impossible de modifier un objectif sans identifiant.');
    }
    final data = await _service.updateObjectif(
      objectif.id.toString(),
      objectif.toJson(),
    );
    return ObjectifModel.fromJson(data);
  }

  Future<ObjectifModel> addMontant(int id, double amount) async {
    final data = await _service.addMontant(id.toString(), amount);
    return ObjectifModel.fromJson(data);
  }

  Future<List<VersementModel>> getVersements(int objectifId) async {
    final data = await _service.getVersements(objectifId.toString());
    return data.map((json) => VersementModel.fromJson(json)).toList();
  }

  Future<void> deleteObjectif(int id) async {
    await _service.deleteObjectif(id.toString());
  }
}
