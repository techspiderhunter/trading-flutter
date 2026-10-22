// To parse this JSON data, do
//
//     final getBankModel = getBankModelFromJson(jsonString);

import 'dart:convert';

GetBankModel getBankModelFromJson(String str) => GetBankModel.fromJson(json.decode(str));

String getBankModelToJson(GetBankModel data) => json.encode(data.toJson());

class GetBankModel {
  int? id;
  int? bankId;
  String? bank;
  DateTime? createdAt;

  GetBankModel({
    this.id,
    this.bankId,
    this.bank,
    this.createdAt,
  });

  GetBankModel copyWith({
    int? id,
    int? bankId,
    String? bank,
    DateTime? createdAt,
  }) =>
      GetBankModel(
        id: id ?? this.id,
        bankId: bankId ?? this.bankId,
        bank: bank ?? this.bank,
        createdAt: createdAt ?? this.createdAt,
      );

  factory GetBankModel.fromJson(Map<String, dynamic> json) => GetBankModel(
    id: json["id"],
    bankId: json["bank_id"],
    bank: json["bank"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "bank_id": bankId,
    "bank": bank,
    "created_at": createdAt?.toIso8601String(),
  };
}
