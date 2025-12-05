import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmdbConfig {
  static String get apiKey {
    final key = dotenv.env['TMDB_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'TMDB_API_KEY não encontrada. Configure no arquivo .env.',
      );
    }
    return key;
  }
}
