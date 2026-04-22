import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';

abstract class ApiService {
  ApiService({SupabaseClient? client})
    : client = client ?? SupabaseConfig.client;

  final SupabaseClient client;

  Future<Map<String, dynamic>> invokeFunction(
    String functionName, {
    Object? body,
    HttpMethod method = HttpMethod.post,
  }) async {
    try {
      final response = await client.functions.invoke(
        functionName,
        body: body,
        method: method,
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw Failures(message: 'Unexpected response from $functionName.');
    } on FunctionException catch (error) {
      throw Failures(message: _buildFunctionErrorMessage(functionName, error));
    } catch (error) {
      if (error is Failures) {
        rethrow;
      }
      throw Failures(message: error.toString());
    }
  }

  Map<String, dynamic> requireMap(dynamic data, {required String context}) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Failures(message: 'Unexpected $context response format.');
  }

  String? _normalizeFunctionError(dynamic details) {
    if (details is Map<String, dynamic>) {
      final message = details['message']?.toString().trim();
      if (message?.isNotEmpty == true) {
        return message;
      }
    }

    if (details is Map) {
      final message = details['message']?.toString().trim();
      if (message?.isNotEmpty == true) {
        return message;
      }
    }

    final normalized = details?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String _buildFunctionErrorMessage(
    String functionName,
    FunctionException error,
  ) {
    final normalizedMessage =
        _normalizeFunctionError(error.details) ?? error.reasonPhrase;

    final lowerCasedMessage = normalizedMessage?.toLowerCase() ?? '';
    if (lowerCasedMessage.contains('requested function was not found') ||
        lowerCasedMessage.contains('function not found') ||
        lowerCasedMessage.contains('no route matched')) {
      if (kDebugMode) {
        print(
          'Supabase Edge Function "$functionName" was not found. '
          'Deploy it to the same Supabase project configured in this app, '
          'then try the payment again.',
        );
      }
      return 'Supabase Edge Function "$functionName" was not found. '
          'Deploy it to the same Supabase project configured in this app, '
          'then try the payment again.';
    }

    return normalizedMessage ?? 'Failed to invoke $functionName.';
  }
}
