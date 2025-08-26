import '../entities/projet.dart';

abstract class ProjetRepository {
  Future<Projet> createProjet(Projet projet);
  Future<List<Projet>> getAllProjets();
  Future<Projet?> getProjetById(int id);
  Future<Projet> updateProjet(Projet projet);
  Future<void> deleteProjet(int id);
} 