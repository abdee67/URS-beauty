import 'package:equatable/equatable.dart';

class Failures extends Equatable {
  const Failures({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [runtimeType, message, code];
}

class LocationFailure extends Failures {
  const LocationFailure({required super.message, super.code});
}

class NetworkFailure extends Failures {
  const NetworkFailure({required super.message, super.code});
}

class ValidationFailure extends Failures {
  const ValidationFailure({required super.message, super.code});
}

class PermissionFailure extends Failures {
  const PermissionFailure({required super.message, super.code});
}

class ServerFailure extends Failures {
  const ServerFailure({required super.message, super.code});
}
