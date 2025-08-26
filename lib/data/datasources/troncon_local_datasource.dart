import 'package:hive_flutter/hive_flutter.dart';
import '../models/troncon_model.dart';

abstract class TronconLocalDataSource {
  Future<TronconModel> createTroncon(TronconModel troncon);
  Future<List<TronconModel>> getAllTroncons();
  Future<List<TronconModel>> getTronconsByProjetId(int projetId);
  Future<TronconModel?> getTronconById(int id);
  Future<TronconModel> updateTroncon(TronconModel troncon);
  Future<void> deleteTroncon(int id);
}

class TronconLocalDataSourceImpl implements TronconLocalDataSource {
  static const String _boxName = 'troncons';
  static const String _counterKey = 'troncon_counter';

  Box<TronconModel>? _tronconsBox;
  Box? _counterBox;

  Future<void> _ensureInitialized() async {
    _tronconsBox ??= await Hive.openBox<TronconModel>(_boxName);
    _counterBox ??= await Hive.openBox('counters');
  }

  int _getNextId() {
    final currentId = _counterBox?.get(_counterKey, defaultValue: 0) ?? 0;
    final nextId = currentId + 1;
    _counterBox?.put(_counterKey, nextId);
    return nextId;
  }

  @override
  Future<TronconModel> createTroncon(TronconModel troncon) async {
    await _ensureInitialized();
    
    final newTroncon = TronconModel(
      id: _getNextId(),
      projetId: troncon.projetId,
      pkDebut: troncon.pkDebut,
      pkFin: troncon.pkFin,
      distance: troncon.distance,
      dateCreation: troncon.dateCreation,
      longueurTroncon: troncon.longueurTroncon,
      largeurEmprise: troncon.largeurEmprise,
      classeRoute: troncon.classeRoute,
      profilTopographique: troncon.profilTopographique,
      conditionsClimatiques: troncon.conditionsClimatiques,
      typeChaussee: troncon.typeChaussee,
      presenceNidsPoules: troncon.presenceNidsPoules,
      zonesErosion: troncon.zonesErosion,
      zonesEauStagnante: troncon.zonesEauStagnante,
      bourbiers: troncon.bourbiers,
      deformations: troncon.deformations,
      typeSol: troncon.typeSol,
      etatPontsDalots: troncon.etatPontsDalots,
      busesFonctionnelles: troncon.busesFonctionnelles,
      exutoiresZonesEvac: troncon.exutoiresZonesEvac,
      zonesErosionDepots: troncon.zonesErosionDepots,
      drainageSuffisant: troncon.drainageSuffisant,
      signalisationVerticale: troncon.signalisationVerticale,
      signalisationHorizontale: troncon.signalisationHorizontale,
      glissieresSecurite: troncon.glissieresSecurite,
      visibilite: troncon.visibilite,
      zonesSensibles: troncon.zonesSensibles,
      nombreVillages: troncon.nombreVillages,
      occupationSol: troncon.occupationSol,
      equipementsSociaux: troncon.equipementsSociaux,
      interventionsSuggerees: troncon.interventionsSuggerees,
      observationsInterventions: troncon.observationsInterventions,
      observationsGenerales: troncon.observationsGenerales,
      images: troncon.images,
      latitude: troncon.latitude,
      longitude: troncon.longitude,
      
    );

    await _tronconsBox!.put(newTroncon.id, newTroncon);
    return newTroncon;
  }

  @override
  Future<List<TronconModel>> getAllTroncons() async {
    await _ensureInitialized();
    return _tronconsBox!.values.toList();
  }

  @override
  Future<List<TronconModel>> getTronconsByProjetId(int projetId) async {
    await _ensureInitialized();
    return _tronconsBox!.values
        .where((troncon) => troncon.projetId == projetId)
        .toList();
  }

  @override
  Future<TronconModel?> getTronconById(int id) async {
    await _ensureInitialized();
    return _tronconsBox!.get(id);
  }

  @override
  Future<TronconModel> updateTroncon(TronconModel troncon) async {
    await _ensureInitialized();
    await _tronconsBox!.put(troncon.id, troncon);
    return troncon;
  }

  @override
  Future<void> deleteTroncon(int id) async {
    await _ensureInitialized();
    await _tronconsBox!.delete(id);
  }
} 