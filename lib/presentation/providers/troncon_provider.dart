import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/troncon_local_datasource.dart';
import '../../data/repositories/troncon_repository_impl.dart';
import '../../domain/entities/troncon.dart';
import '../../domain/usecases/create_troncon.dart';
import '../../domain/usecases/get_troncons_by_projet.dart';

// Providers
final tronconLocalDataSourceProvider = Provider<TronconLocalDataSource>((ref) {
  return TronconLocalDataSourceImpl();
});

final tronconRepositoryProvider = Provider<TronconRepositoryImpl>((ref) {
  return TronconRepositoryImpl(
    localDataSource: ref.watch(tronconLocalDataSourceProvider),
  );
});

final createTronconUseCaseProvider = Provider<CreateTroncon>((ref) {
  return CreateTroncon(ref.watch(tronconRepositoryProvider));
});

final getTronconsByProjetUseCaseProvider = Provider<GetTronconsByProjet>((ref) {
  return GetTronconsByProjet(ref.watch(tronconRepositoryProvider));
});

// State providers
final tronconsProvider = StateNotifierProvider<TronconsNotifier, AsyncValue<List<Troncon>>>((ref) {
  return TronconsNotifier(ref.watch(tronconRepositoryProvider));
});

// Provider pour les tronçons d'un projet spécifique
final tronconsByProjetProvider = StateNotifierProvider.family<TronconsByProjetNotifier, AsyncValue<List<Troncon>>, int>((ref, projetId) {
  return TronconsByProjetNotifier(ref.watch(tronconRepositoryProvider), projetId);
});

// Provider pour récupérer un tronçon par ID
final tronconByIdProvider = FutureProvider.family<Troncon?, int>((ref, id) async {
  final repository = ref.watch(tronconRepositoryProvider);
  return await repository.getTronconById(id);
});

class TronconsNotifier extends StateNotifier<AsyncValue<List<Troncon>>> {
  final TronconRepositoryImpl _repository;

  TronconsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTroncons();
  }

  Future<void> loadTroncons() async {
    try {
      state = const AsyncValue.loading();
      final troncons = await _repository.getAllTroncons();
      state = AsyncValue.data(troncons);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Troncon> createTroncon(Troncon troncon) async {
    try {
      final newTroncon = await _repository.createTroncon(troncon);
      await loadTroncons(); // Reload the list
      return newTroncon;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteTroncon(int id) async {
    try {
      await _repository.deleteTroncon(id);
      await loadTroncons(); // Reload the list
    } catch (error) {
      rethrow;
    }
  }
}

class TronconsByProjetNotifier extends StateNotifier<AsyncValue<List<Troncon>>> {
  final TronconRepositoryImpl _repository;
  final int projetId;

  TronconsByProjetNotifier(this._repository, this.projetId) : super(const AsyncValue.loading()) {
    loadTroncons();
  }

  Future<void> loadTroncons() async {
    try {
      state = const AsyncValue.loading();
      final troncons = await _repository.getTronconsByProjetId(projetId);
      state = AsyncValue.data(troncons);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Troncon> createTroncon(Troncon troncon) async {
    try {
      final newTroncon = await _repository.createTroncon(troncon);
      await loadTroncons(); // Reload the list
      return newTroncon;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteTroncon(int id) async {
    try {
      await _repository.deleteTroncon(id);
      await loadTroncons(); // Reload the list
    } catch (error) {
      rethrow;
    }
  }

  Future<void> markAllTronconsAsSynced() async {
    try {
      final troncons = await _repository.getTronconsByProjetId(projetId);
      final unsyncedTroncons = troncons.where((t) => !t.sync).toList();
      
      for (final troncon in unsyncedTroncons) {
        final updatedTroncon = troncon.copyWith(sync: true);
        await _repository.updateTroncon(updatedTroncon);
      }
      
      await loadTroncons(); // Reload the list
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateTronconSyncStatus(int id, bool syncStatus) async {
    try {
      final troncon = await _repository.getTronconById(id);
      if (troncon != null) {
        final updatedTroncon = troncon.copyWith(sync: syncStatus);
        await _repository.updateTroncon(updatedTroncon);
        await loadTroncons(); // Reload the list
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateMultipleTronconsSync(List<int> ids, bool syncStatus) async {
    try {
      for (final id in ids) {
        final troncon = await _repository.getTronconById(id);
        if (troncon != null) {
          final updatedTroncon = troncon.copyWith(sync: syncStatus);
          await _repository.updateTroncon(updatedTroncon);
        }
      }
      await loadTroncons(); // Reload the list
    } catch (error) {
      rethrow;
    }
  }
} 