import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get chapaPublicKey =>
      dotenv.env['CHAPA_PUBLIC_KEY'] ?? dotenv.env['CHAP_PUBLIC_KEY'] ?? '';
}
