import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cubos_video/config/tmdb_config.dart';
import 'package:cubos_video/features/movies/models/movie_summary.dart';
import 'package:cubos_video/features/movies/models/movie_details.dart';



class TmdbApiService {
  static const String _baseUrl = 'api.themoviedb.org';
  static const String _basePath = '/3';

  final http.Client _client;

  TmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MovieSummary>> getPopularMovies({int page = 1}) async {
    final uri = Uri.https(
      _baseUrl,
      '$_basePath/movie/popular',
      {
        'api_key': TmdbConfig.apiKey,
        'language': 'pt-BR',
        'page': page.toString(),
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar filmes populares: ${response.statusCode} ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return results
        .map((json) => MovieSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 🔎 Busca por nome
  Future<List<MovieSummary>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final uri = Uri.https(
      _baseUrl,
      '$_basePath/search/movie',
      {
        'api_key': TmdbConfig.apiKey,
        'language': 'pt-BR',
        'query': query,
        'page': page.toString(),
        'include_adult': 'false',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar filmes: ${response.statusCode} ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return results
        .map((json) => MovieSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 🎭 Filmes por gênero (usado nas tabs)
  Future<List<MovieSummary>> getMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final uri = Uri.https(
      _baseUrl,
      '$_basePath/discover/movie',
      {
        'api_key': TmdbConfig.apiKey,
        'language': 'pt-BR',
        'with_genres': genreId.toString(),
        'sort_by': 'popularity.desc',
        'page': page.toString(),
        'include_adult': 'false',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar filmes por gênero: ${response.statusCode} ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return results
        .map((json) => MovieSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 🎬 Detalhes do filme (com créditos)
  Future<MovieDetails> getMovieDetails(int movieId) async {
    final uri = Uri.https(
      _baseUrl,
      '$_basePath/movie/$movieId',
      {
        'api_key': TmdbConfig.apiKey,
        'language': 'pt-BR',
        'append_to_response': 'credits',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar detalhes do filme: ${response.statusCode} ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return MovieDetails.fromJson(data);
  }
}

