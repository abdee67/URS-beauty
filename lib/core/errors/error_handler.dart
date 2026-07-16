import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/failures.dart';

extension ErrorHandler on Object {
  Future<T> serviceError<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Failures {
      rethrow;
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['message'] != null) {
        throw Failures(message: details['message'].toString());
      }
      throw Failures(
        message: friendlyMessage(e),
      );
    } on PostgrestException catch (e) {
      throw Failures(message: friendlyMessage(e));
    } catch (e) {
      throw Failures(message: friendlyMessage(e));
    }
  }

  Future<Either<Failures, T>> repoErrorHnadler<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return Right(await operation());
    } on Failures catch (failure) {
      return Left(failure);
    } catch (error) {
      return Left(Failures(message: friendlyMessage(error)));
    }
  }

  void requireValue(String value, String message) {
    if (value.trim().isEmpty) {
      throw Failures(message: message);
    }
  }

  String friendlyMessage(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');
    final lower = text.toLowerCase();
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Please check your internet connection and try again.';
    }
    if (lower.contains('otp') || lower.contains('token')) {
      return 'That verification code did not work. Please check it and try again.';
    }
    if (lower.contains('storage')) {
      return 'We could not upload your file. Please try again.';
    }
    if (lower.contains('duplicate')) {
      return 'This information already exists. Please sign in or continue onboarding.';
    }
    if (lower.contains('password')) {
      return 'We could not save that password. Use at least 8 characters with a mix of letters and numbers.';
    }
    return text.isEmpty ? 'Something went wrong. Please try again.' : text;
  }
}
