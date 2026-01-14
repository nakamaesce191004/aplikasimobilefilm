import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/movie.dart';
import 'movie_detail_page.dart';

class MoviesPageContent extends StatefulWidget {
  const MoviesPageContent({super.key});

  @override
  State<MoviesPageContent> createState() => _MoviesPageContentState();
}

class _MoviesPageContentState extends State<MoviesPageContent> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final List<Movie> _movies = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchMovies();
    }
  }

  Future<void> _fetchMovies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newMovies = await _apiService.getMoviesByCategory('popular', page: _currentPage);
      
      setState(() {
        if (newMovies.isEmpty) {
          _hasMore = false;
        } else {
          _movies.addAll(newMovies);
          _currentPage++;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error loading movies: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_movies.isEmpty && _isLoading) {
       return const Center(child: CircularProgressIndicator(color: Color(0xFFFF005D)));
    }
    
    // Initial error or empty state
    if (_movies.isEmpty && !_hasMore) {
       return const Center(child: Text('No movies found', style: TextStyle(color: Colors.white)));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _movies.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _movies.length) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF005D)));
        }

        final movie = _movies[index];
        return GestureDetector(
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailPage(movie: movie),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(movie.fullPosterUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    movie.releaseDate.split('-').first,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
