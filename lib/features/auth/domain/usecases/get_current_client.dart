import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

import '../entities/customer_entity.dart';

class GetCurrentCustomer {
  final AuthRepository repo;
  GetCurrentCustomer(this.repo);

  Future<Either<Failures, CustomerEntity>> call() {
    return repo.getCurrentCustomer();
  }
}
