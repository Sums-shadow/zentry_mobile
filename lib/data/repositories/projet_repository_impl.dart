import '../../domain/entities/projet.dart';
import '../../domain/repositories/projet_repository.dart';
import '../datasources/projet_local_datasource.dart';
import '../models/projet_model.dart';

class ProjetRepositoryImpl implements ProjetRepository {
  final ProjetLocalDataSource localDataSource;

  ProjetRepositoryImpl({required this.localDataSource});

  @override
  Future<Projet> createProjet(Projet projet) async {
    final projetModel = ProjetModel.fromEntity(projet);
    final createdProjet = await localDataSource.createProjet(projetModel);
    return createdProjet.toEntity();
  }

  @override
  Future<List<Projet>> getAllProjets() async {
    final projetModels = await localDataSource.getAllProjets();
    return projetModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Projet?> getProjetById(int id) async {
    final projetModel = await localDataSource.getProjetById(id);
    return projetModel?.toEntity();
  }

  @override
  Future<Projet> updateProjet(Projet projet) async {
    final projetModel = ProjetModel.fromEntity(projet);
    final updatedProjet = await localDataSource.updateProjet(projetModel);
    return updatedProjet.toEntity();
  }

  @override
  Future<void> deleteProjet(int id) async {
    await localDataSource.deleteProjet(id);
  }
} 