import 'package:hive_flutter/hive_flutter.dart';
import '../models/projet_model.dart';

abstract class ProjetLocalDataSource {
  Future<ProjetModel> createProjet(ProjetModel projet);
  Future<List<ProjetModel>> getAllProjets();
  Future<ProjetModel?> getProjetById(int id);
  Future<ProjetModel> updateProjet(ProjetModel projet);
  Future<void> deleteProjet(int id);
}

class ProjetLocalDataSourceImpl implements ProjetLocalDataSource {
  static const String _boxName = 'projets';
  static const String _counterKey = 'projet_counter';

  Box<ProjetModel>? _projetsBox;
  Box? _counterBox;

  Future<void> _ensureInitialized() async {
    _projetsBox ??= await Hive.openBox<ProjetModel>(_boxName);
    _counterBox ??= await Hive.openBox('counters');
  }

  int _getNextId() {
    final currentId = _counterBox?.get(_counterKey, defaultValue: 0) ?? 0;
    final nextId = currentId + 1;
    _counterBox?.put(_counterKey, nextId);
    return nextId;
  }

  @override
  Future<ProjetModel> createProjet(ProjetModel projet) async {
    await _ensureInitialized();
    
    final newProjet = ProjetModel(
      id: _getNextId(),
      nom: projet.nom,
      troncon: projet.troncon,
      pkdebut: projet.pkdebut,
      pkfin: projet.pkfin,
      province: projet.province,
      date: projet.date,
      agent: projet.agent,
      description: projet.description,
    );

    await _projetsBox!.put(newProjet.id, newProjet);
    return newProjet;
  }

  @override
  Future<List<ProjetModel>> getAllProjets() async {
    await _ensureInitialized();
    return _projetsBox!.values.toList();
  }

  @override
  Future<ProjetModel?> getProjetById(int id) async {
    await _ensureInitialized();
    return _projetsBox!.get(id);
  }

  @override
  Future<ProjetModel> updateProjet(ProjetModel projet) async {
    await _ensureInitialized();
    await _projetsBox!.put(projet.id, projet);
    return projet;
  }

  @override
  Future<void> deleteProjet(int id) async {
    await _ensureInitialized();
    await _projetsBox!.delete(id);
  }
} 