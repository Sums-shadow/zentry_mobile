// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjetModelAdapter extends TypeAdapter<ProjetModel> {
  @override
  final int typeId = 0;

  @override
  ProjetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjetModel(
      id: fields[0] as int?,
      nom: fields[1] as String,
      troncon: fields[2] as String?,
      pkdebut: fields[3] as String?,
      pkfin: fields[4] as String?,
      province: fields[5] as String,
      date: fields[6] as DateTime?,
      agent: fields[7] as String?,
      description: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjetModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.troncon)
      ..writeByte(3)
      ..write(obj.pkdebut)
      ..writeByte(4)
      ..write(obj.pkfin)
      ..writeByte(5)
      ..write(obj.province)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.agent)
      ..writeByte(8)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
