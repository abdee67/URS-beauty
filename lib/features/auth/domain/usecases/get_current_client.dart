import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';

import '../entities/client.dart';
import '../../data/repositories/auth_repository_impl.dart';

class GetCurrentClient {
  final AuthRepositoryImpl repo;
  GetCurrentClient(this.repo);

  Future<Either<Failures, Client>> call() {
    return repo.getCurrentClient();
  }
}
