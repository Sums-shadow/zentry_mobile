// Classe pour représenter une image avec ses coordonnées GPS
class TronconImage {
  final String path;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final DateTime datePrise;

  TronconImage({
    required this.path,
    this.latitude,
    this.longitude,
    this.altitude,
    DateTime? datePrise,
  }) : datePrise = datePrise ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'datePrise': datePrise.toIso8601String(),
    };
  }

  factory TronconImage.fromJson(Map<String, dynamic> json) {
    return TronconImage(
      path: json['path'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      altitude: json['altitude'] as double?,
      datePrise: DateTime.parse(json['datePrise'] as String),
    );
  }

  TronconImage copyWith({
    String? path,
    double? latitude,
    double? longitude,
    double? altitude,
    DateTime? datePrise,
  }) {
    return TronconImage(
      path: path ?? this.path,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      datePrise: datePrise ?? this.datePrise,
    );
  }
}

class Troncon {
  final int? id;
  final int projetId; // Référence au projet parent
  final String? pkDebut;
  final String? pkFin;
  final double? distance;
  final DateTime dateCreation;
  final double? latitude;
  final double? longitude;
  final double? altitude; // Nouveau champ altitude
  final bool sync; // Nouveau champ sync pour la synchronisation
  
  // 1️⃣ INFORMATIONS GÉNÉRALES
  final double? longueurTroncon;
  final double? largeurEmprise;
  final String? classeRoute;
  final String? profilTopographique;
  final String? conditionsClimatiques;

  // 2️⃣ ÉTAT DE LA CHAUSSÉE
  final String? typeChaussee;
  final bool presenceNidsPoules;
  final bool zonesErosion;
  final bool zonesEauStagnante;
  final bool bourbiers;
  final bool deformations;

  // 3️⃣ DÉGRADATIONS SPÉCIFIQUES
  final String? typeSol;

  // 4️⃣ OUVRAGES D'ART & ASSAINISSEMENT
  final String? etatPontsDalots;
  final bool? busesFonctionnelles;
  final bool exutoiresZonesEvac;
  final bool zonesErosionDepots;
  final bool drainageSuffisant;

  // 5️⃣ SÉCURITÉ ROUTIÈRE
  final bool signalisationVerticale;
  final bool signalisationHorizontale;
  final bool glissieresSecurite;
  final String? visibilite;
  final bool zonesSensibles;

  // 6️⃣ VILLAGES ET EMPRISE
  final int? nombreVillages;
  final List<String> occupationSol;
  final List<String> equipementsSociaux;

  // 7️⃣ RECOMMANDATIONS TECHNIQUES
  final List<String> interventionsSuggerees;
  final Map<String, String> observationsInterventions;
  final String? observationsGenerales;

  // 8️⃣ IMAGES ET DOCUMENTATION - Modifié pour utiliser TronconImage
  final List<TronconImage> images;

  Troncon({
    this.id,
    required this.projetId,
    this.pkDebut,
    this.pkFin,
    this.distance,
    DateTime? dateCreation,
    this.latitude,
    this.longitude,
    this.altitude, // Ajout du paramètre altitude
    this.sync = false, // Valeur par défaut false pour la synchronisation
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

  Troncon copyWith({
    int? id,
    int? projetId,
    String? pkDebut,
    String? pkFin,
    double? distance,
    DateTime? dateCreation,
    double? latitude,
    double? longitude,
    double? altitude, // Ajout du paramètre altitude
    bool? sync, // Ajout du paramètre sync
    double? longueurTroncon,
    double? largeurEmprise,
    String? classeRoute,
    String? profilTopographique,
    String? conditionsClimatiques,
    String? typeChaussee,
    bool? presenceNidsPoules,
    bool? zonesErosion,
    bool? zonesEauStagnante,
    bool? bourbiers,
    bool? deformations,
    String? typeSol,
    String? etatPontsDalots,
    bool? busesFonctionnelles,
    bool? exutoiresZonesEvac,
    bool? zonesErosionDepots,
    bool? drainageSuffisant,
    bool? signalisationVerticale,
    bool? signalisationHorizontale,
    bool? glissieresSecurite,
    String? visibilite,
    bool? zonesSensibles,
    int? nombreVillages,
    List<String>? occupationSol,
    List<String>? equipementsSociaux,
    List<String>? interventionsSuggerees,
    Map<String, String>? observationsInterventions,
    String? observationsGenerales,
    List<TronconImage>? images, // Modifié pour utiliser TronconImage
  }) {
    return Troncon(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      pkDebut: pkDebut ?? this.pkDebut,
      pkFin: pkFin ?? this.pkFin,
      distance: distance ?? this.distance,
      dateCreation: dateCreation ?? this.dateCreation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude, // Ajout de l'altitude
      sync: sync ?? this.sync, // Ajout du sync
      longueurTroncon: longueurTroncon ?? this.longueurTroncon,
      largeurEmprise: largeurEmprise ?? this.largeurEmprise,
      classeRoute: classeRoute ?? this.classeRoute,
      profilTopographique: profilTopographique ?? this.profilTopographique,
      conditionsClimatiques: conditionsClimatiques ?? this.conditionsClimatiques,
      typeChaussee: typeChaussee ?? this.typeChaussee,
      presenceNidsPoules: presenceNidsPoules ?? this.presenceNidsPoules,
      zonesErosion: zonesErosion ?? this.zonesErosion,
      zonesEauStagnante: zonesEauStagnante ?? this.zonesEauStagnante,
      bourbiers: bourbiers ?? this.bourbiers,
      deformations: deformations ?? this.deformations,
      typeSol: typeSol ?? this.typeSol,
      etatPontsDalots: etatPontsDalots ?? this.etatPontsDalots,
      busesFonctionnelles: busesFonctionnelles ?? this.busesFonctionnelles,
      exutoiresZonesEvac: exutoiresZonesEvac ?? this.exutoiresZonesEvac,
      zonesErosionDepots: zonesErosionDepots ?? this.zonesErosionDepots,
      drainageSuffisant: drainageSuffisant ?? this.drainageSuffisant,
      signalisationVerticale: signalisationVerticale ?? this.signalisationVerticale,
      signalisationHorizontale: signalisationHorizontale ?? this.signalisationHorizontale,
      glissieresSecurite: glissieresSecurite ?? this.glissieresSecurite,
      visibilite: visibilite ?? this.visibilite,
      zonesSensibles: zonesSensibles ?? this.zonesSensibles,
      nombreVillages: nombreVillages ?? this.nombreVillages,
      occupationSol: occupationSol ?? this.occupationSol,
      equipementsSociaux: equipementsSociaux ?? this.equipementsSociaux,
      interventionsSuggerees: interventionsSuggerees ?? this.interventionsSuggerees,
      observationsInterventions: observationsInterventions ?? this.observationsInterventions,
      observationsGenerales: observationsGenerales ?? this.observationsGenerales,
      images: images ?? this.images,
    );
  }
} 