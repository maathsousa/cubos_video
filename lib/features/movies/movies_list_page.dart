import 'package:flutter/material.dart';

import 'package:cubos_video/services/auth_service.dart';
import 'package:cubos_video/services/tmdb_api_service.dart';
import 'package:cubos_video/services/theme_controller.dart';

import 'models/movie_summary.dart';
import 'movie_details_page.dart';

class _GenreTab {
  final String label;
  final int? genreId; // null = populares

  const _GenreTab(this.label, this.genreId);
}

class MoviesListPage extends StatefulWidget {
  const MoviesListPage({super.key});

  @override
  State<MoviesListPage> createState() => _MoviesListPageState();
}

class _MoviesListPageState extends State<MoviesListPage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _tmdbService = TmdbApiService();
  final _searchController = TextEditingController();
  int _selectedGenreIndex = 0;

  static const _tabs = <_GenreTab>[
    _GenreTab('Populares', null),
    _GenreTab('Ação', 28),
    _GenreTab('Aventura', 12),
    _GenreTab('Comédia', 35),
  ];

  late TabController _tabController;
  late Future<List<MovieSummary>> _futureMovies;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _reloadMovies();
    });
    _futureMovies = _loadMovies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<MovieSummary>> _loadMovies() {
    // Se estiver buscando por nome, ignora o gênero
    if (_searchQuery.isNotEmpty) {
      return _tmdbService.searchMovies(_searchQuery);
    }

    final currentTab = _tabs[_selectedGenreIndex];

    if (currentTab.genreId != null) {
      return _tmdbService.getMoviesByGenre(currentTab.genreId!);
    }

    // fallback
    return _tmdbService.getPopularMovies();
  }

  void _reloadMovies() {
    setState(() {
      _futureMovies = _loadMovies();
    });
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _searchQuery = value.trim();
      _futureMovies = _loadMovies();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _futureMovies = _loadMovies();
    });
  }

  void _onGenreSelected(int index) {
    setState(() {
      _selectedGenreIndex = index;
      _searchQuery = '';
      _searchController.clear();
      _futureMovies = _loadMovies();
    });
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isDark = themeController.themeMode == ThemeMode.dark;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Tema escuro'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeController.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _authService.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBar normal: cor não muda ao rolar
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filmes'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openSettings,
            ),
          ],
        ),
        body: FutureBuilder<List<MovieSummary>>(
          future: _futureMovies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Erro ao carregar filmes:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final movies = snapshot.data ?? [];

            if (movies.isEmpty) {
              return const Center(child: Text('Nenhum filme encontrado.'));
            }

            return CustomScrollView(
              slivers: [
                // Busca
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _onSearchSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Pesquise filmes',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : null,
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Tabs tipo chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 22),
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        final selected = index == _selectedGenreIndex;

                        final colorScheme = Theme.of(context).colorScheme;
                        final primary = colorScheme.primary;
                        final outline = colorScheme.outline.withAlpha(50);
                        final textColor = selected
                            ? Colors.white
                            : colorScheme.onSurface;

                        return GestureDetector(
                          onTap: () => _onGenreSelected(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected ? primary : outline,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tab.label,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Lista de filmes
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final movie = movies[index];
                      final posterUrl = movie.fullPosterUrl;
                      final genresLabel = movie.genresLabel;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MovieDetailsPage(
                                  movieId: movie.id,
                                  movieTitle: movie.title,
                                ),
                              ),
                            );
                          },
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: posterUrl != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Imagem
                                        Image.network(
                                          posterUrl,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              24,
                                              16,
                                              16,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withAlpha(1000),
                                                ],
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                10.0,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    movie.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    genresLabel,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withAlpha(950),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.movie, size: 40),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: movies.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
