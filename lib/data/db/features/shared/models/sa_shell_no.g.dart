// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sa_shell_no.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaShellNoAdapter extends TypeAdapter<SaShellNo> {
  @override
  final int typeId = 5;

  @override
  SaShellNo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaShellNo(
      id:            fields[0] as String,
      formNo:        fields[1] as String,
      stage:         fields[2] as String?,
      frameTypeId:   fields[3] as String,
      frameTypeName: fields[4] as String,
      status:        fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SaShellNo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.formNo)
      ..writeByte(2)
      ..write(obj.stage)
      ..writeByte(3)
      ..write(obj.frameTypeId)
      ..writeByte(4)
      ..write(obj.frameTypeName)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaShellNoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
