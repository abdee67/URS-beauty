import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_entity.dart';

class CreateCustomerAddress {
  final AuthRepository repo;
  CreateCustomerAddress(this.repo);

  Future<Either<Failures, CustomerAddressEntity>> call(
    CustomerAddressInput input,
  ) {
    return repo.createCustomerAddress(input);
  }
}
