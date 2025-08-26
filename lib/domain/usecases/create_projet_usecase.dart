import '../entities/projet.dart';
import '../repositories/projet_repository.dart';

class CreateProjetUseCase {
  final ProjetRepository repository;

  CreateProjetUseCase(this.repository);

  Future<Projet> call(Projet projet) async {
    return await repository.createProjet(projet);
  }
} 