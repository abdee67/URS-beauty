class AppStrings {
  static DateTime asLocalDateTime(dynamic value) {
    final parsed = DateTime.parse(value.toString());
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static bool isReviewedFromString(dynamic value) {
    return value.toString().toLowerCase() == 'true';
  }

  static String? nullableString(dynamic value) {
    final normalized = value?.toString().trim() ?? '';
    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return null;
    }
    return normalized;
  }

  static int asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static String asString(dynamic value) {
    return value.toString();
  }

  static double asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String && value.trim().isNotEmpty) {
      return double.tryParse(value.trim()) ?? 0.0;
    }
    return 0.0;
  }
}
