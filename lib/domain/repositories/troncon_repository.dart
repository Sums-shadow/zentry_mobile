import '../entities/troncon.dart';

abstract class TronconRepository {
  Future<Troncon> createTroncon(Troncon troncon);
  Future<List<Troncon>> getAllTroncons();
  Future<List<Troncon>> getTronconsByProjetId(int projetId);
  Future<Troncon?> getTronconById(int id);
  Future<Troncon> updateTroncon(Troncon troncon);
  Future<void> deleteTroncon(int id);
} 