// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      id: fields[0] as int,
      title: fields[3] as String,
      url: fields[4] as String,
      author: fields[5] as String,
      kids: (fields[6] as List)?.cast<dynamic>(),
      time: fields[1] as int,
      score: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.author)
      ..writeByte(6)
      ..write(obj.kids);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
