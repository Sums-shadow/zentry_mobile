class Projet {
  final int? id;
  final String nom;
  final String? troncon; // Rendu optionnel
  final String? pkdebut;
  final String? pkfin;
  final String province;
  final DateTime date;
  final String? agent;
  final String? description;

  Projet({
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

  Projet copyWith({
    int? id,
    String? nom,
    String? troncon,
    String? pkdebut,
    String? pkfin,
    String? province,
    DateTime? date,
    String? agent,
    String? description,
  }) {
    return Projet(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      troncon: troncon ?? this.troncon,
      pkdebut: pkdebut ?? this.pkdebut,
      pkfin: pkfin ?? this.pkfin,
      province: province ?? this.province,
      date: date ?? this.date,
      agent: agent ?? this.agent,
      description: description ?? this.description,
    );
  }
} 