// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'troncon_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TronconImageModelAdapter extends TypeAdapter<TronconImageModel> {
  @override
  final int typeId = 2;

  @override
  TronconImageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TronconImageModel(
      path: fields[0] as String,
      latitude: fields[1] as double?,
      longitude: fields[2] as double?,
      altitude: fields[3] as double?,
      datePrise: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TronconImageModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.altitude)
      ..writeByte(4)
      ..write(obj.datePrise);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TronconImageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TronconModelAdapter extends TypeAdapter<TronconModel> {
  @override
  final int typeId = 1;

  @override
  TronconModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TronconModel(
      id: fields[0] as int?,
      projetId: fields[1] as int,
      pkDebut: fields[2] as String?,
      pkFin: fields[3] as String?,
      distance: fields[4] as double?,
      dateCreation: fields[5] as DateTime?,
      latitude: fields[34] as double?,
      longitude: fields[35] as double?,
      altitude: fields[37] as double?,
      sync: fields[38] as bool,
      longueurTroncon: fields[6] as double?,
      largeurEmprise: fields[7] as double?,
      classeRoute: fields[8] as String?,
      profilTopographique: fields[9] as String?,
      conditionsClimatiques: fields[10] as String?,
      typeChaussee: fields[11] as String?,
      presenceNidsPoules: fields[12] as bool,
      zonesErosion: fields[13] as bool,
      zonesEauStagnante: fields[14] as bool,
      bourbiers: fields[15] as bool,
      deformations: fields[16] as bool,
      typeSol: fields[17] as String?,
      etatPontsDalots: fields[18] as String?,
      busesFonctionnelles: fields[19] as bool?,
      exutoiresZonesEvac: fields[20] as bool,
      zonesErosionDepots: fields[21] as bool,
      drainageSuffisant: fields[22] as bool,
      signalisationVerticale: fields[23] as bool,
      signalisationHorizontale: fields[24] as bool,
      glissieresSecurite: fields[25] as bool,
      visibilite: fields[26] as String?,
      zonesSensibles: fields[27] as bool,
      nombreVillages: fields[28] as int?,
      occupationSol:
          fields[29] == null ? [] : (fields[29] as List).cast<String>(),
      equipementsSociaux:
          fields[30] == null ? [] : (fields[30] as List).cast<String>(),
      interventionsSuggerees:
          fields[31] == null ? [] : (fields[31] as List).cast<String>(),
      observationsInterventions:
          fields[32] == null ? {} : (fields[32] as Map).cast<String, String>(),
      observationsGenerales: fields[36] as String?,
      images: fields[39] == null
          ? []
          : (fields[39] as List).cast<TronconImageModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, TronconModel obj) {
    writer
      ..writeByte(39)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projetId)
      ..writeByte(2)
      ..write(obj.pkDebut)
      ..writeByte(3)
      ..write(obj.pkFin)
      ..writeByte(4)
      ..write(obj.distance)
      ..writeByte(5)
      ..write(obj.dateCreation)
      ..writeByte(34)
      ..write(obj.latitude)
      ..writeByte(35)
      ..write(obj.longitude)
      ..writeByte(37)
      ..write(obj.altitude)
      ..writeByte(38)
      ..write(obj.sync)
      ..writeByte(6)
      ..write(obj.longueurTroncon)
      ..writeByte(7)
      ..write(obj.largeurEmprise)
      ..writeByte(8)
      ..write(obj.classeRoute)
      ..writeByte(9)
      ..write(obj.profilTopographique)
      ..writeByte(10)
      ..write(obj.conditionsClimatiques)
      ..writeByte(11)
      ..write(obj.typeChaussee)
      ..writeByte(12)
      ..write(obj.presenceNidsPoules)
      ..writeByte(13)
      ..write(obj.zonesErosion)
      ..writeByte(14)
      ..write(obj.zonesEauStagnante)
      ..writeByte(15)
      ..write(obj.bourbiers)
      ..writeByte(16)
      ..write(obj.deformations)
      ..writeByte(17)
      ..write(obj.typeSol)
      ..writeByte(18)
      ..write(obj.etatPontsDalots)
      ..writeByte(19)
      ..write(obj.busesFonctionnelles)
      ..writeByte(20)
      ..write(obj.exutoiresZonesEvac)
      ..writeByte(21)
      ..write(obj.zonesErosionDepots)
      ..writeByte(22)
      ..write(obj.drainageSuffisant)
      ..writeByte(23)
      ..write(obj.signalisationVerticale)
      ..writeByte(24)
      ..write(obj.signalisationHorizontale)
      ..writeByte(25)
      ..write(obj.glissieresSecurite)
      ..writeByte(26)
      ..write(obj.visibilite)
      ..writeByte(27)
      ..write(obj.zonesSensibles)
      ..writeByte(28)
      ..write(obj.nombreVillages)
      ..writeByte(29)
      ..write(obj.occupationSol)
      ..writeByte(30)
      ..write(obj.equipementsSociaux)
      ..writeByte(31)
      ..write(obj.interventionsSuggerees)
      ..writeByte(32)
      ..write(obj.observationsInterventions)
      ..writeByte(36)
      ..write(obj.observationsGenerales)
      ..writeByte(39)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TronconModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
