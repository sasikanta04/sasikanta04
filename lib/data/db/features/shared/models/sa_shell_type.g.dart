// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sa_shell_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaShellTypeAdapter extends TypeAdapter<SaShellType> {
  @override
  final int typeId = 10;

  @override
  SaShellType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaShellType(
      id:   fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SaShellType obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaShellTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
