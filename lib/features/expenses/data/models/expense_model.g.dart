// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final typeId = 1;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      categoryId: fields[3] as String,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
      walletId: fields[6] as String?,
      toWalletId: fields[7] as String?,
      typeString: fields[8] as String?,
      merchant: fields[9] as String?,
      tags: (fields[10] as List?)?.cast<String>(),
      receiptPath: fields[11] as String?,
      isRecurring: fields[12] as bool?,
      recurringIntervalString: fields[13] as String?,
      lastGeneratedOccurrence: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
      isDeleted: fields[16] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.walletId)
      ..writeByte(7)
      ..write(obj.toWalletId)
      ..writeByte(8)
      ..write(obj.typeString)
      ..writeByte(9)
      ..write(obj.merchant)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.receiptPath)
      ..writeByte(12)
      ..write(obj.isRecurring)
      ..writeByte(13)
      ..write(obj.recurringIntervalString)
      ..writeByte(14)
      ..write(obj.lastGeneratedOccurrence)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
