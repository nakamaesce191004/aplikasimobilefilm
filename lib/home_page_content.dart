import 'package:flutter/material.dart';
import 'models/movie.dart';
import 'models/anime.dart';
import 'services/api_service.dart';
import 'services/anime_service.dart';
import 'widgets/content_section.dart';
import 'trending_hero_section.dart';
import 'pages/see_all_page.dart';
import 'top_rated_section.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late Future<List<Movie>> _trendingMovies;
  late Future<List<Movie>> _popularMovies;
  late Future<List<Movie>> _nowPlayingMovies;
  late Future<List<Movie>> _topRatedMovies;
  late Future<List<Anime>> _topAiringAnime;

  final ApiService _api = ApiService();
  final AnimeService _animeApi = AnimeService();

  @override
  void initState() {
    super.initState();
    _trendingMovies = _api.getTrendingMovies();
    _popularMovies = _api.getMoviesByCategory('popular');
    _nowPlayingMovies = _api.getMoviesByCategory('now_playing');
    _topRatedMovies = _api.getMoviesByCategory('top_rated');
    _topAiringAnime = _animeApi.getTopAiring();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        _buildTrendingSection(),
        _buildAnimeSectionBuilder('🌟 Top Airing Anime', _topAiringAnime, 
            (page) => _animeApi.getTopAiring(page: page)),
        _buildSectionBuilder('Popular Movies', _popularMovies, 
            (page) => _api.getMoviesByCategory('popular', page: page)),
        _buildSectionBuilder('Now Playing', _nowPlayingMovies, 
            (page) => _api.getMoviesByCategory('now_playing', page: page)),
        _buildTopRatedSection(), // New distinct section
      ],
    );
  }

  Widget _buildTopRatedSection() {
    return FutureBuilder<List<Movie>>(
      future: _topRatedMovies,
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const SizedBox(height: 280, child: Center(child: CircularProgressIndicator(color: Color(0xFFFF005D))));
         } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
           return const SizedBox.shrink();
         }
         
         return TopRatedSection(
           movies: snapshot.data!,
           onSeeAllTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeAllPage(
                  title: '🏆 Top Rated Movies',
                  fetchMethod: (page) => _api.getMoviesByCategory('top_rated', page: page),
                ),
              ),
            );
           },
         );
      },
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

  Widget _buildSectionBuilder(String title, Future<List<Movie>> future, Future<List<Movie>> Function(int) fetchMethod) {
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
          return const SizedBox.shrink(); 
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return ContentSection(
          title: title,
          items: snapshot.data!,
          onSeeAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeAllPage(
                  title: title,
                  fetchMethod: fetchMethod,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimeSectionBuilder(String title, Future<List<Anime>> future, Future<List<Anime>> Function(int) fetchMethod) {
    return FutureBuilder<List<Anime>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const SizedBox(height: 100);
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
           return const SizedBox.shrink();
        }

        return ContentSection(
          title: title,
          items: snapshot.data!,
          onSeeAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeAllPage(
                  title: title,
                  fetchMethod: fetchMethod,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
