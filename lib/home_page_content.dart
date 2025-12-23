import 'package:flutter/material.dart';
import 'models/movie.dart';
import 'models/anime.dart';
import 'services/api_service.dart';
import 'services/anime_service.dart';
import 'movie_section.dart';
import 'anime_section.dart';
import 'trending_hero_section.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late Future<List<Movie>> _trendingMovies;
  late Future<List<Movie>> _popularMovies;
  late Future<List<Movie>> _nowPlayingMovies;
  late Future<List<Anime>> _topAiringAnime;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    final animeApi = AnimeService();
    _trendingMovies = api.getTrendingMovies();
    _popularMovies = api.getMoviesByCategory('popular');
    _nowPlayingMovies = api.getMoviesByCategory('now_playing');
    _topAiringAnime = animeApi.getTopAiring();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        _buildTrendingSection(),
        _buildAnimeSectionBuilder('🌟 Top Airing Anime', _topAiringAnime),
        _buildSectionBuilder('Popular Movies', _popularMovies),
        _buildSectionBuilder('Now Playing', _nowPlayingMovies),
      ],
    );
  }

  Widget _buildTrendingSection() {
    return FutureBuilder<List<Movie>>(
      future: _trendingMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const SizedBox(
             height: 400,
             child: Center(child: CircularProgressIndicator(color: Color(0xFFFF005D))),
           );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return TrendingHeroSection(movies: snapshot.data!);
      },
    );
  }

  Widget _buildSectionBuilder(String title, Future<List<Movie>> future) {
    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: Theme.of(context).textTheme.titleLarge),
                 const SizedBox(height: 10),
                 const Center(child: CircularProgressIndicator(color: Color(0xFFFF005D))),
               ],
             ),
           );
        } else if (snapshot.hasError) {
          // Hide error sections gracefully or show minimal error
          return const SizedBox.shrink(); 
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return MovieSection(
          title: title,
          movies: snapshot.data!,
        );
      },
    );
  }

  Widget _buildAnimeSectionBuilder(String title, Future<List<Anime>> future) {
    return FutureBuilder<List<Anime>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           // Minimal loader for anime section
           return const SizedBox(height: 100);
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
           return const SizedBox.shrink();
        }

        return AnimeSection(
          title: title,
          animeList: snapshot.data!,
        );
      },
    );
  }
}
