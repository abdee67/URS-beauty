import 'package:urs_beauty/core/constants/app_strings.dart';
import 'package:urs_beauty/features/stylists/domain/entities/wallets_entity.dart';

class WalletsModel extends WalletsEntity {
  WalletsModel({
    required super.id,
    required super.stylistId,
    required super.balance,
    required super.currency,
    required super.createdAt,
  });

  factory WalletsModel.fromJson(Map<String, dynamic> json) {
    return WalletsModel(
      id: AppStrings.asString(json['id']),
      stylistId: AppStrings.asString(json['stylist_id']),
      balance: AppStrings.asDouble(json['balance']),
      currency: AppStrings.asString(json['currency']),
      createdAt: AppStrings.asLocalDateTime(json['created_at']),
    );
  }

  WalletsEntity toEntity() {
    return WalletsEntity(
      id: id,
      stylistId: stylistId,
      balance: balance,
      currency: currency,
      createdAt: createdAt,
    );
  }
}
