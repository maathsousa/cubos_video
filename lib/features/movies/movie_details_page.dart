import 'package:flutter/material.dart';
import 'package:cubos_video/services/tmdb_api_service.dart';
import 'models/movie_details.dart'; // ⬅️ ajuste o caminho/nome do seu model se for diferente

class MovieDetailsPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const MovieDetailsPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final _tmdbService = TmdbApiService();
  late Future<MovieDetails> _futureDetails;

  @override
  void initState() {
    super.initState();
    _futureDetails = _tmdbService.getMovieDetails(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FutureBuilder<MovieDetails>(
        future: _futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar detalhes do filme.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final movie = snapshot.data!;

          // ⬇️ Ajuste os nomes conforme o seu model
          final posterUrl = movie.fullPosterUrl; // ex: getter com URL completa
          final rating = movie.voteAverage; // double
          final title = movie.title;
          final originalTitle = movie.originalTitle ?? '';
          final year = movie.releaseYear; // ex: "2019"
          final genres = movie.genres; // List<String>
          final overview = movie.overview ?? '';
          final director = movie.director ?? '-';
          final runtime = movie.formattedRuntime;
          final budget = movie.formattedBudget;
          final producers = movie.productionCompanies.join(', ');
          final cast = movie.cast.join(', ');

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Botão voltar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          backgroundColor: colorScheme.surfaceContainerHighest
                              .withAlpha(80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 2,
                          shadowColor: Colors.black12,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                        label: Text(
                          'Voltar',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                ),

                // Topo preto + poster centralizado
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 32,
                      right: 32,
                      bottom: 32,
                    ),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: posterUrl != null
                              ? Image.network(posterUrl, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.movie,
                                    size: 48,
                                    color: Colors.black54,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Conteúdo branco
                SliverToBoxAdapter(
                  child: Container(
                    color: colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Nota
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: '/ 10',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurface.withAlpha(1000),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Título
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Título original
                        if (originalTitle.isNotEmpty)
                          Text(
                            'Título original: $originalTitle',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withAlpha(1000),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Ano & duração
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _InfoPill(label: 'Ano', value: year),
                            const SizedBox(width: 12),
                            _InfoPill(label: 'Duração', value: runtime),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Gêneros
                        if (genres.isNotEmpty)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: genres
                                .map((g) => _TagChip(text: g))
                                .toList(),
                          ),

                        const SizedBox(height: 24),

                        // Descrição
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Descrição',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withAlpha(1000),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          overview,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: colorScheme.onSurface.withAlpha(1000),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Orçamento & Produtoras
                        _LabeledBox(label: 'ORÇAMENTO:', value: budget),
                        const SizedBox(height: 8),
                        _LabeledBox(label: 'PRODUTORAS:', value: producers),

                        const SizedBox(height: 24),

                        // Diretor
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Diretor',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withAlpha(1000),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            director.isNotEmpty ? director : '-',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withAlpha(1000),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Elenco
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Elenco',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withAlpha(1000),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            cast,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withAlpha(1000),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Pill "Ano / Duração" estilo Figma
class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withAlpha(1000),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de gênero
class _TagChip extends StatelessWidget {
  final String text;

  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withAlpha(100), // borda fininha
          width: 1,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withAlpha(1000),
        ),
      ),
    );
  }
}

/// Caixinha "ORÇAMENTO: $ ..." / "PRODUTORAS: ..."
class _LabeledBox extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withAlpha(1000),
          ),
          children: [
            const TextSpan(text: '  '),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
