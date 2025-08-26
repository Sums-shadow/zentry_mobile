import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import '../../data/datasources/projet_local_datasource.dart';
import '../../data/repositories/projet_repository_impl.dart';
import '../../domain/entities/projet.dart';
import '../../domain/entities/troncon.dart';
import '../../domain/usecases/create_projet_usecase.dart';
import '../../core/services/http_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/api_constants.dart';

// Providers
final projetLocalDataSourceProvider = Provider<ProjetLocalDataSource>((ref) {
  return ProjetLocalDataSourceImpl();
});

final projetRepositoryProvider = Provider<ProjetRepositoryImpl>((ref) {
  return ProjetRepositoryImpl(
    localDataSource: ref.watch(projetLocalDataSourceProvider),
  );
});

final createProjetUseCaseProvider = Provider<CreateProjetUseCase>((ref) {
  return CreateProjetUseCase(ref.watch(projetRepositoryProvider));
});

// State providers
final projetsProvider = StateNotifierProvider<ProjetsNotifier, AsyncValue<List<Projet>>>((ref) {
  return ProjetsNotifier(ref.watch(projetRepositoryProvider));
});

// Provider pour récupérer un projet par ID
final projetByIdProvider = FutureProvider.family<Projet?, int>((ref, id) async {
  final repository = ref.watch(projetRepositoryProvider);
  return await repository.getProjetById(id);
});

class ProjetsNotifier extends StateNotifier<AsyncValue<List<Projet>>> {
  final ProjetRepositoryImpl _repository;

  ProjetsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProjets();
  }

  Future<void> loadProjets() async {
    try {
      state = const AsyncValue.loading();
      final projets = await _repository.getAllProjets();
      state = AsyncValue.data(projets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Projet> createProjet(Projet projet) async {
    try {
      final newProjet = await _repository.createProjet(projet);
      await loadProjets(); // Reload the list
      return newProjet;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProjet(int id) async {
    try {
      await _repository.deleteProjet(id);
      await loadProjets(); // Reload the list
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> syncProjet(Projet projet, List<Troncon> troncons) async {
    try {
      // S'assurer que le token d'authentification est configuré
      final token = await AuthService.getAuthToken();
      if (token != null) {
        HttpService.setAuthToken(token);
      }

      // Créer FormData pour envoyer des fichiers
      final formData = FormData();

      // Ajouter les données du projet
      formData.fields.add(MapEntry('projet', '''{
        "id": ${projet.id},
        "nom": "${projet.nom}",
        "description": "${projet.description ?? ''}",
        "province": "${projet.province}",
        "date": "${projet.date.toIso8601String()}",
        "agent": "${projet.agent ?? ''}",
        "troncon": "${projet.troncon ?? ''}"
      }'''));

      // Préparer les données des tronçons (sans les images d'abord)
      final tronconsData = troncons.map((troncon) => {
        'id': troncon.id,
        'projetId': troncon.projetId,
        'pkDebut': troncon.pkDebut,
        'pkFin': troncon.pkFin,
        'distance': troncon.distance,
        'dateCreation': troncon.dateCreation.toIso8601String(),
        'latitude': troncon.latitude,
        'longitude': troncon.longitude,
        'altitude': troncon.altitude,
        'sync': troncon.sync,
        
        // Informations générales
        'longueurTroncon': troncon.longueurTroncon,
        'largeurEmprise': troncon.largeurEmprise,
        'classeRoute': troncon.classeRoute,
        'profilTopographique': troncon.profilTopographique,
        'conditionsClimatiques': troncon.conditionsClimatiques,
        
        // État de la chaussée
        'typeChaussee': troncon.typeChaussee,
        'presenceNidsPoules': troncon.presenceNidsPoules,
        'zonesErosion': troncon.zonesErosion,
        'zonesEauStagnante': troncon.zonesEauStagnante,
        'bourbiers': troncon.bourbiers,
        'deformations': troncon.deformations,
        
        // Dégradations spécifiques
        'typeSol': troncon.typeSol,
        
        // Ouvrages d'art & assainissement
        'etatPontsDalots': troncon.etatPontsDalots,
        'busesFonctionnelles': troncon.busesFonctionnelles,
        'exutoiresZonesEvac': troncon.exutoiresZonesEvac,
        'zonesErosionDepots': troncon.zonesErosionDepots,
        'drainageSuffisant': troncon.drainageSuffisant,
        
        // Sécurité routière
        'signalisationVerticale': troncon.signalisationVerticale,
        'signalisationHorizontale': troncon.signalisationHorizontale,
        'glissieresSecurite': troncon.glissieresSecurite,
        'visibilite': troncon.visibilite,
        'zonesSensibles': troncon.zonesSensibles,
        
        // Villages et emprise
        'nombreVillages': troncon.nombreVillages,
        'occupationSol': troncon.occupationSol,
        'equipementsSociaux': troncon.equipementsSociaux,
        
        // Recommandations techniques
        'interventionsSuggerees': troncon.interventionsSuggerees,
        'observationsInterventions': troncon.observationsInterventions,
        'observationsGenerales': troncon.observationsGenerales,
        
        // Métadonnées des images (sans les fichiers)
        'images': troncon.images.map((image) => {
          'latitude': image.latitude,
          'longitude': image.longitude,
          'altitude': image.altitude,
          'date': image.datePrise.toIso8601String(),
        }).toList(),
      }).toList();

      // Ajouter les données des tronçons
      formData.fields.add(MapEntry('troncons', jsonEncode(tronconsData)));

      // Ajouter les fichiers images
      int imageIndex = 0;
      for (int tronconIndex = 0; tronconIndex < troncons.length; tronconIndex++) {
        final troncon = troncons[tronconIndex];
        for (int imgIndex = 0; imgIndex < troncon.images.length; imgIndex++) {
          final image = troncon.images[imgIndex];
          final file = File(image.path);
          
          if (await file.exists()) {
            final multipartFile = await MultipartFile.fromFile(
              file.path,
              filename: 'troncon_${troncon.id}_image_${imgIndex}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            
            formData.files.add(MapEntry(
              'images[$imageIndex]',
              multipartFile,
            ));
            
            // Ajouter les métadonnées correspondantes
            formData.fields.add(MapEntry('imageMetadata[$imageIndex][tronconId]', '${troncon.id}'));
            formData.fields.add(MapEntry('imageMetadata[$imageIndex][latitude]', '${image.latitude ?? ''}'));
            formData.fields.add(MapEntry('imageMetadata[$imageIndex][longitude]', '${image.longitude ?? ''}'));
            formData.fields.add(MapEntry('imageMetadata[$imageIndex][altitude]', '${image.altitude ?? ''}'));
            formData.fields.add(MapEntry('imageMetadata[$imageIndex][datePrise]', image.datePrise.toIso8601String()));
            
            imageIndex++;
          }
        }
      }

      final response = await HttpService.post(
        ApiConstants.syncProjectEndpoint,
        data: formData,
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': response.data['message'] ?? 'Synchronisation réussie',
        'data': response.data,
      };
    } catch (error) {
      if (error.toString().contains('DioException')) {
        final dioError = error as dynamic;
        return {
          'success': false,
          'statusCode': dioError.response?.statusCode ?? 500,
          'message': dioError.response?.data?['message'] ?? 'Erreur de synchronisation',
          'error': error.toString(),
        };
      }
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Erreur inconnue lors de la synchronisation',
        'error': error.toString(),
      };
    }
  }
} 