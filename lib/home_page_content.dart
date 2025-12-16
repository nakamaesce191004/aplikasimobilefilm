import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/api_service.dart';
import 'movie_section.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late Future<List<Movie>> _trendingMovies;
  late Future<List<Movie>> _popularMovies;
  late Future<List<Movie>> _nowPlayingMovies;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _trendingMovies = api.getTrendingMovies();
    _popularMovies = api.getMoviesByCategory('popular');
    _nowPlayingMovies = api.getMoviesByCategory('now_playing');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        _buildSectionBuilder('🔥 Trending Now', _trendingMovies),
        _buildSectionBuilder('Popular', _popularMovies),
        _buildSectionBuilder('Now Playing', _nowPlayingMovies),
      ],
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading $title: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
             child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No movies found for $title',
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        return MovieSection(
          title: title,
          movies: snapshot.data!,
        );
      },
    );
  }
}
