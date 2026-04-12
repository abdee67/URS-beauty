// If your Supabase auth supports updating metadata:
import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

import '../entities/customer_entity.dart';

class UpdateCustomerProfile {
  final AuthRepository repo;
  UpdateCustomerProfile(this.repo);

  Future<Either<Failures, void>> call(CustomerEntity updatedData) {
    return repo.updateCustomerProfile(updatedData);
  }
}
