import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

import '../entities/client.dart';

class GetCurrentClient {
  final AuthRepository repo;
  GetCurrentClient(this.repo);

  Future<Either<Failures, ClientEntity>> call() {
    return repo.getCurrentClient();
  }
}
