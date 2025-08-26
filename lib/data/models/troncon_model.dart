import 'package:hive/hive.dart';
import '../../domain/entities/troncon.dart';

part 'troncon_model.g.dart';

@HiveType(typeId: 2)
class TronconImageModel extends HiveObject {
  @HiveField(0)
  String path;

  @HiveField(1)
  double? latitude;

  @HiveField(2)
  double? longitude;

  @HiveField(3)
  double? altitude;

  @HiveField(4)
  DateTime datePrise;

  TronconImageModel({
    required this.path,
    this.latitude,
    this.longitude,
    this.altitude,
    DateTime? datePrise,
  }) : datePrise = datePrise ?? DateTime.now();

  factory TronconImageModel.fromEntity(TronconImage tronconImage) {
    return TronconImageModel(
      path: tronconImage.path,
      latitude: tronconImage.latitude,
      longitude: tronconImage.longitude,
      altitude: tronconImage.altitude,
      datePrise: tronconImage.datePrise,
    );
  }

  TronconImage toEntity() {
    return TronconImage(
      path: path,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      datePrise: datePrise,
    );
  }
}

@HiveType(typeId: 1)
class TronconModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int projetId;

  @HiveField(2)
  String? pkDebut;

  @HiveField(3)
  String? pkFin;

  @HiveField(4)
  double? distance;

  @HiveField(5)
  DateTime dateCreation;

  @HiveField(34)
  double? latitude;

  @HiveField(35)
  double? longitude;

  @HiveField(37) // Utiliser le prochain index disponible
  double? altitude;

  @HiveField(38) // Nouveau champ sync pour la synchronisation
  bool sync;

  // 1️⃣ INFORMATIONS GÉNÉRALES
  @HiveField(6)
  double? longueurTroncon;

  @HiveField(7)
  double? largeurEmprise;

  @HiveField(8)
  String? classeRoute;

  @HiveField(9)
  String? profilTopographique;

  @HiveField(10)
  String? conditionsClimatiques;

  // 2️⃣ ÉTAT DE LA CHAUSSÉE
  @HiveField(11)
  String? typeChaussee;

  @HiveField(12)
  bool presenceNidsPoules;

  @HiveField(13)
  bool zonesErosion;

  @HiveField(14)
  bool zonesEauStagnante;

  @HiveField(15)
  bool bourbiers;

  @HiveField(16)
  bool deformations;

  // 3️⃣ DÉGRADATIONS SPÉCIFIQUES
  @HiveField(17)
  String? typeSol;

  // 4️⃣ OUVRAGES D'ART & ASSAINISSEMENT
  @HiveField(18)
  String? etatPontsDalots;

  @HiveField(19)
  bool? busesFonctionnelles;

  @HiveField(20)
  bool exutoiresZonesEvac;

  @HiveField(21)
  bool zonesErosionDepots;

  @HiveField(22)
  bool drainageSuffisant;

  // 5️⃣ SÉCURITÉ ROUTIÈRE
  @HiveField(23)
  bool signalisationVerticale;

  @HiveField(24)
  bool signalisationHorizontale;

  @HiveField(25)
  bool glissieresSecurite;

  @HiveField(26)
  String? visibilite;

  @HiveField(27)
  bool zonesSensibles;

  // 6️⃣ VILLAGES ET EMPRISE
  @HiveField(28)
  int? nombreVillages;

  @HiveField(29, defaultValue: <String>[])
  List<String> occupationSol;

  @HiveField(30, defaultValue: <String>[])
  List<String> equipementsSociaux;

  // 7️⃣ RECOMMANDATIONS TECHNIQUES
  @HiveField(31, defaultValue: <String>[])
  List<String> interventionsSuggerees;

  @HiveField(32, defaultValue: <String, String>{})
  Map<String, String> observationsInterventions;

  @HiveField(36)
  String? observationsGenerales;

  // 8️⃣ IMAGES ET DOCUMENTATION - Modifié pour utiliser TronconImageModel
  @HiveField(39, defaultValue: <TronconImageModel>[])
  List<TronconImageModel> images;

  TronconModel({
    this.id,
    required this.projetId,
    this.pkDebut,
    this.pkFin,
    this.distance,
    DateTime? dateCreation,
    this.latitude,
    this.longitude,
    this.altitude,
    this.sync = false, // Valeur par défaut false
    this.longueurTroncon,
    this.largeurEmprise,
    this.classeRoute,
    this.profilTopographique,
    this.conditionsClimatiques,
    this.typeChaussee,
    this.presenceNidsPoules = false,
    this.zonesErosion = false,
    this.zonesEauStagnante = false,
    this.bourbiers = false,
    this.deformations = false,
    this.typeSol,
    this.etatPontsDalots,
    this.busesFonctionnelles,
    this.exutoiresZonesEvac = false,
    this.zonesErosionDepots = false,
    this.drainageSuffisant = false,
    this.signalisationVerticale = false,
    this.signalisationHorizontale = false,
    this.glissieresSecurite = false,
    this.visibilite,
    this.zonesSensibles = false,
    this.nombreVillages,
    this.occupationSol = const [],
    this.equipementsSociaux = const [],
    this.interventionsSuggerees = const [],
    this.observationsInterventions = const {},
    this.observationsGenerales,
    this.images = const [],
  }) : dateCreation = dateCreation ?? DateTime.now();

  factory TronconModel.fromEntity(Troncon troncon) {
    return TronconModel(
      id: troncon.id,
      projetId: troncon.projetId,
      pkDebut: troncon.pkDebut,
      pkFin: troncon.pkFin,
      distance: troncon.distance,
      dateCreation: troncon.dateCreation,
      latitude: troncon.latitude,
      longitude: troncon.longitude,
      altitude: troncon.altitude,
      sync: troncon.sync, // Ajout du champ sync
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
      occupationSol: List<String>.from(troncon.occupationSol),
      equipementsSociaux: List<String>.from(troncon.equipementsSociaux),
      interventionsSuggerees: List<String>.from(troncon.interventionsSuggerees),
      observationsInterventions: Map<String, String>.from(troncon.observationsInterventions),
      observationsGenerales: troncon.observationsGenerales,
      images: troncon.images.map((img) => TronconImageModel.fromEntity(img)).toList(),
    );
  }

  Troncon toEntity() {
    return Troncon(
      id: id,
      projetId: projetId,
      pkDebut: pkDebut,
      pkFin: pkFin,
      distance: distance,
      dateCreation: dateCreation,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      sync: sync, // Ajout du champ sync
      longueurTroncon: longueurTroncon,
      largeurEmprise: largeurEmprise,
      classeRoute: classeRoute,
      profilTopographique: profilTopographique,
      conditionsClimatiques: conditionsClimatiques,
      typeChaussee: typeChaussee,
      presenceNidsPoules: presenceNidsPoules,
      zonesErosion: zonesErosion,
      zonesEauStagnante: zonesEauStagnante,
      bourbiers: bourbiers,
      deformations: deformations,
      typeSol: typeSol,
      etatPontsDalots: etatPontsDalots,
      busesFonctionnelles: busesFonctionnelles,
      exutoiresZonesEvac: exutoiresZonesEvac,
      zonesErosionDepots: zonesErosionDepots,
      drainageSuffisant: drainageSuffisant,
      signalisationVerticale: signalisationVerticale,
      signalisationHorizontale: signalisationHorizontale,
      glissieresSecurite: glissieresSecurite,
      visibilite: visibilite,
      zonesSensibles: zonesSensibles,
      nombreVillages: nombreVillages,
      occupationSol: occupationSol,
      equipementsSociaux: equipementsSociaux,
      interventionsSuggerees: interventionsSuggerees,
      observationsInterventions: observationsInterventions,
      observationsGenerales: observationsGenerales,
      images: images.map((img) => img.toEntity()).toList(),
    );
  }
} 