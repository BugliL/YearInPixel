// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayEntryAdapter extends TypeAdapter<DayEntry> {
  @override
  final int typeId = 1;

  @override
  DayEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayEntry(
      date: fields[0] as DateTime,
      categoryIndex: fields[1] as int,
      note: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DayEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.categoryIndex)
      ..writeByte(2)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
