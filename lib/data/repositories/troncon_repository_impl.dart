import '../../domain/entities/troncon.dart';
import '../../domain/repositories/troncon_repository.dart';
import '../datasources/troncon_local_datasource.dart';
import '../models/troncon_model.dart';

class TronconRepositoryImpl implements TronconRepository {
  final TronconLocalDataSource localDataSource;

  TronconRepositoryImpl({required this.localDataSource});

  @override
  Future<Troncon> createTroncon(Troncon troncon) async {
    final tronconModel = TronconModel.fromEntity(troncon);
    final createdTroncon = await localDataSource.createTroncon(tronconModel);
    return createdTroncon.toEntity();
  }

  @override
  Future<List<Troncon>> getAllTroncons() async {
    final tronconModels = await localDataSource.getAllTroncons();
    return tronconModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Troncon>> getTronconsByProjetId(int projetId) async {
    final tronconModels = await localDataSource.getTronconsByProjetId(projetId);
    return tronconModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Troncon?> getTronconById(int id) async {
    final tronconModel = await localDataSource.getTronconById(id);
    return tronconModel?.toEntity();
  }

  @override
  Future<Troncon> updateTroncon(Troncon troncon) async {
    final tronconModel = TronconModel.fromEntity(troncon);
    final updatedTroncon = await localDataSource.updateTroncon(tronconModel);
    return updatedTroncon.toEntity();
  }

  @override
  Future<void> deleteTroncon(int id) async {
    await localDataSource.deleteTroncon(id);
  }
} 