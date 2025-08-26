import 'package:hive/hive.dart';
import '../../domain/entities/projet.dart';

part 'projet_model.g.dart';

@HiveType(typeId: 0)
class ProjetModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String? troncon; // Rendu optionnel

  @HiveField(3)
  String? pkdebut;

  @HiveField(4)
  String? pkfin;

  @HiveField(5)
  String province;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  String? agent;

  @HiveField(8)
  String? description;

  ProjetModel({
    this.id,
    required this.nom,
    this.troncon, // Plus requis
    this.pkdebut,
    this.pkfin,
    this.province = 'Kinshasa',
    DateTime? date,
    this.agent,
    this.description,
  }) : date = date ?? DateTime.now();

  factory ProjetModel.fromEntity(Projet projet) {
    return ProjetModel(
      id: projet.id,
      nom: projet.nom,
      troncon: projet.troncon,
      pkdebut: projet.pkdebut,
      pkfin: projet.pkfin,
      province: projet.province,
      date: projet.date,
      agent: projet.agent,
      description: projet.description,
    );
  }

  Projet toEntity() {
    return Projet(
      id: id,
      nom: nom,
      troncon: troncon,
      pkdebut: pkdebut,
      pkfin: pkfin,
      province: province,
      date: date,
      agent: agent,
      description: description,
    );
  }
} 