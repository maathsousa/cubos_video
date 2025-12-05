class MovieSummary {
  final int id;
  final String title;
  final String? originalTitle;
  final String? posterPath;
  final double voteAverage;
  final String? overview;
  final DateTime? releaseDate;
  final List<int> genreIds;

  MovieSummary({
    required this.id,
    required this.title,
    this.originalTitle,
    this.posterPath,
    required this.voteAverage,
    this.overview,
    this.releaseDate,
    required this.genreIds,
  });

  factory MovieSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final dateStr = json['release_date'] as String?;
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(dateStr);
      } catch (_) {}
    }

    final genreIdsJson = json['genre_ids'] as List<dynamic>? ?? [];

    return MovieSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      originalTitle: json['original_title'] as String?,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      overview: json['overview'] as String?,
      releaseDate: parsedDate,
      genreIds: genreIdsJson.map((g) => g as int).toList(),
    );
  }

  String? get fullPosterUrl {
    if (posterPath == null) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get releaseYear {
    if (releaseDate == null) return '';
    return releaseDate!.year.toString();
  }

  // Lista de nomes de gêneros (mapeados pelos IDs)
  List<String> get genreNames {
    return genreIds
        .map((id) => _genreMap[id])
        .whereType<String>()
        .toList();
  }

  // Label bonitinha tipo "Ação - Aventura"
  String get genresLabel {
    if (genreNames.isEmpty) return 'Gênero não disponível';
    return genreNames.take(2).join(' - ');
  }

  // Mapa simples de IDs de gênero da TMDB -> nome em PT
  static const Map<int, String> _genreMap = {
    28: 'Ação',
    12: 'Aventura',
    16: 'Animação',
    35: 'Comédia',
    80: 'Crime',
    99: 'Documentário',
    18: 'Drama',
    10751: 'Família',
    14: 'Fantasia',
    36: 'História',
    27: 'Terror',
    10402: 'Música',
    9648: 'Mistério',
    10749: 'Romance',
    878: 'Ficção científica',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'Guerra',
    37: 'Faroeste',
  };
}
