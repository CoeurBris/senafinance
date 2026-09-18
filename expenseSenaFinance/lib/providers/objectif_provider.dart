
import 'package:flutter/foundation.dart';
import 'package:senafinance/models/objectif_model.dart';
import 'package:senafinance/models/versement_model.dart';
import 'package:senafinance/repositories/objectif_repository.dart';

class ObjectifProvider extends ChangeNotifier {
  final ObjectifRepository _repository;

  ObjectifProvider({ObjectifRepository? repository})
    : _repository = repository ?? ObjectifRepository();

  List<ObjectifModel> _objectifs = [];
  bool _isLoading = false;
  String? _error;

  List<ObjectifModel> get objectifs => List.unmodifiable(_objectifs);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ObjectifModel> get objectifsActifs =>
      _objectifs.where((o) => !o.estAtteint).toList();

  List<ObjectifModel> get objectifsAtteints =>
      _objectifs.where((o) => o.estAtteint).toList();

  /// Objectif vedette : priorité à la deadline la plus proche, sinon au % le plus avancé
  ObjectifModel? get objectifVedette {
    final actifs = objectifsActifs;
    if (actifs.isEmpty) return null;

    final avecDeadline = actifs.where((o) => o.targetDate != null).toList()
      ..sort((a, b) => a.targetDate!.compareTo(b.targetDate!));

    if (avecDeadline.isNotEmpty) return avecDeadline.first;

    final tries = [...actifs]
      ..sort((a, b) => b.pourcentage.compareTo(a.pourcentage));
    return tries.first;
  }

  Future<void> loadObjectifs() async {
    _setLoading(true);
    _error = null;
    try {
      _objectifs = await _repository.getObjectifs();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createObjectif(ObjectifModel objectif) async {
    _setLoading(true);
    _error = null;
    try {
      final created = await _repository.createObjectif(objectif);
      _objectifs.insert(0, created);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateObjectif(ObjectifModel objectif) async {
    _setLoading(true);
    _error = null;
    try {
      final updated = await _repository.updateObjectif(objectif);
      final index = _objectifs.indexWhere((o) => o.id == updated.id);
      if (index != -1) _objectifs[index] = updated;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addMontant(int id, double amount) async {
    _error = null;
    try {
      final updated = await _repository.addMontant(id, amount);
      final index = _objectifs.indexWhere((o) => o.id == updated.id);
      if (index != -1) {
        _objectifs[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  final Map<int, List<VersementModel>> _versementsByObjectif = {};

  List<VersementModel> versementsOf(int objectifId) =>
      List.unmodifiable(_versementsByObjectif[objectifId] ?? []);

  Future<void> loadVersements(int objectifId) async {
    try {
      final versements = await _repository.getVersements(objectifId);
      _versementsByObjectif[objectifId] = versements;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Rythme moyen d'épargne par mois, basé sur l'historique réel des versements
  double rythmeMensuel(int objectifId) {
    final versements = versementsOf(objectifId);
    if (versements.length < 2) return 0;

    final sorted = [...versements]
      ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    final premier = sorted.first.createdAt!;
    final joursEcoules = DateTime.now().difference(premier).inDays;
    if (joursEcoules <= 0) return 0;

    final total = versements.fold<double>(0, (sum, v) => sum + v.montant);
    final mois = joursEcoules / 30;
    return mois > 0 ? total / mois : 0;
  }

  /// Date estimée d'atteinte de l'objectif au rythme actuel (null si rythme = 0)
  DateTime? dateProjetee(ObjectifModel goal) {
    final rythme = rythmeMensuel(goal.id!);
    if (rythme <= 0 || goal.montantRestant <= 0) return null;

    final moisRestants = goal.montantRestant / rythme;
    final joursRestants = (moisRestants * 30).round();
    return DateTime.now().add(Duration(days: joursRestants));
  }

  /// Montant mensuel nécessaire pour tenir la deadline (null si pas de deadline)
  double? rythmeNecessaire(ObjectifModel goal) {
    if (goal.targetDate == null || goal.montantRestant <= 0) return null;
    final moisRestants =
        goal.targetDate!.difference(DateTime.now()).inDays / 30;
    if (moisRestants <= 0) {
      return goal.montantRestant; // deadline dépassée/imminente
    }
    return goal.montantRestant / moisRestants;
  }

  /// True si le rythme actuel est insuffisant pour tenir la deadline
  bool estEnRetard(ObjectifModel goal) {
    final necessaire = rythmeNecessaire(goal);
    if (necessaire == null) return false;
    final actuel = rythmeMensuel(goal.id!);
    return actuel < necessaire;
  }

  Future<bool> deleteObjectif(int id) async {
    try {
      await _repository.deleteObjectif(id);
      _objectifs.removeWhere((o) => o.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
