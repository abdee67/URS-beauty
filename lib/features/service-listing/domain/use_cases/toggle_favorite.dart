import 'package:urs_beauty/features/service-listing/data/service_repo.dart';

class ToggleFavorite {
  final ServiceRepository _repository;

  ToggleFavorite(this._repository);

  Future<void> execute(String serviceId) async {
    await _repository.toggleFavorite(serviceId);
  }
}