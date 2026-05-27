// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sa_shell_no_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaShellNoItemAdapter extends TypeAdapter<SaShellNoItem> {
  @override
  final int typeId = 11;

  @override
  SaShellNoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaShellNoItem(
      id:          fields[0] as String,
      formNo:      fields[1] as String,
      stage:       fields[2] as String?,
      shellTypeId: fields[3] as String,
      status:      fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SaShellNoItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.formNo)
      ..writeByte(2)
      ..write(obj.stage)
      ..writeByte(3)
      ..write(obj.shellTypeId)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaShellNoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
