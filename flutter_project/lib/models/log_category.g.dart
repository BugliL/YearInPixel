// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogCategoryAdapter extends TypeAdapter<LogCategory> {
  @override
  final int typeId = 0;

  @override
  LogCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogCategory(
      label: fields[0] as String,
      color: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LogCategory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
