// If your Supabase auth supports updating metadata:
import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';

import '../entities/client.dart';
import '../../data/repositories/auth_repository_impl.dart';

class UpdateClientProfile {
  final AuthRepositoryImpl repo;
  UpdateClientProfile(this.repo);

  Future<Either<Failures, void>> call(Client updatedData) {
    return repo.updateClientProfile(updatedData);
  }
}
