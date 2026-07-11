import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/failures.dart';

extension ErrorHandler on Object {
  Future<T> run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Failures {
      rethrow;
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['message'] != null) {
        throw Failures(message: details['message'].toString());
      }
      throw Failures(message: e.reasonPhrase ?? 'Function invocation failed');
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  void requireValue(String value, String message) {
    if (value.trim().isEmpty) {
      throw Failures(message: message);
    }
  }
}