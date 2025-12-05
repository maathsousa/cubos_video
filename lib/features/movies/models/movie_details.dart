class MovieDetails {
  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final DateTime? releaseDate;
  final int? runtime; // duração em minutos
  final List<String> genres;
  final int? budget; // orçamento
  final List<String> productionCompanies;
  final String? director;
  final List<String> cast; // elenco principal

  MovieDetails({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.releaseDate,
    this.runtime,
    required this.genres,
    this.budget,
    required this.productionCompanies,
    this.director,
    required this.cast,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final dateStr = json['release_date'] as String?;
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(dateStr);
      } catch (_) {}
    }

    final genresJson = json['genres'] as List<dynamic>? ?? [];
    final companiesJson =
        json['production_companies'] as List<dynamic>? ?? [];

    // credits pode vir junto com append_to_response=credits
    final credits = json['credits'] as Map<String, dynamic>?;

    String? director;
    final castNames = <String>[];

    if (credits != null) {
      final crew = credits['crew'] as List<dynamic>? ?? [];
      final cast = credits['cast'] as List<dynamic>? ?? [];

      // diretor
      try {
        final directorEntry = crew.firstWhere(
          (c) => (c['job'] as String?) == 'Director',
          orElse: () => null,
        );
        if (directorEntry != null) {
          director = directorEntry['name'] as String?;
        }
      } catch (_) {}

      // elenco principal (por exemplo 10 primeiros nomes)
      for (final c in cast.take(10)) {
        final name = c['name'] as String?;
        if (name != null && name.isNotEmpty) {
          castNames.add(name);
        }
      }
    }

    return MovieDetails(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      originalTitle: json['original_title'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: parsedDate,
      runtime: json['runtime'] as int?,
      genres: genresJson
          .map((g) => (g as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      budget: json['budget'] as int?,
      productionCompanies: companiesJson
          .map(
              (c) => (c as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      director: director,
      cast: castNames,
    );
  }

  String? get fullPosterUrl {
    if (posterPath == null) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String? get fullBackdropUrl {
    if (backdropPath == null) return null;
    return 'https://image.tmdb.org/t/p/w780$backdropPath';
  }

  String get releaseYear {
    if (releaseDate == null) return '';
    return releaseDate!.year.toString();
  }

  String get formattedRuntime {
    if (runtime == null || runtime == 0) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  String get formattedBudget {
    if (budget == null || budget == 0) return '';
    // orçamento em milhões só pra ficar mais amigável
    final millions = budget! / 1000000;
    return '\$${millions.toStringAsFixed(1)}M';
  }
}
