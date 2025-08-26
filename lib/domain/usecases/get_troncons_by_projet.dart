import '../entities/troncon.dart';
import '../repositories/troncon_repository.dart';

class GetTronconsByProjet {
  final TronconRepository repository;

  GetTronconsByProjet(this.repository);

  Future<List<Troncon>> call(int projetId) async {
    return await repository.getTronconsByProjetId(projetId);
  }
} 