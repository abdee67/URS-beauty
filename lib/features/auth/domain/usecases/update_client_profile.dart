// If your Supabase auth supports updating metadata:
import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

import '../entities/client.dart';

class UpdateClientProfile {
  final AuthRepository repo;
  UpdateClientProfile(this.repo);

  Future<Either<Failures, void>> call(ClientEntity updatedData) {
    return repo.updateClientProfile(updatedData);
  }
}
