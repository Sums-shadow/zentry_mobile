import '../entities/troncon.dart';
import '../repositories/troncon_repository.dart';

class CreateTroncon {
  final TronconRepository repository;

  CreateTroncon(this.repository);

  Future<Troncon> call(Troncon troncon) async {
    return await repository.createTroncon(troncon);
  }
} 