import 'package:urs_beauty/features/deals/data/model/deal_model.dart';

abstract class DealsRemoteDataSource {
  Future <List<DealModel>> getDeals();
}