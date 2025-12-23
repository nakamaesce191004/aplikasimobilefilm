import 'package:flutter/material.dart';
import 'dart:async'; // Added for Timer
import 'package:provider/provider.dart'; // Added for Watchlist
import 'providers/watchlist_provider.dart'; // Added for Watchlist
import 'providers/navigation_provider.dart'; // Added for Navigation
import 'watchlist_page.dart'; // Added for navigation
import 'models/movie.dart';
import 'movie_detail_page.dart';

class TrendingHeroSection extends StatefulWidget {
  final List<Movie> movies;

  const TrendingHeroSection({super.key, required this.movies});

  @override
  State<TrendingHeroSection> createState() => _TrendingHeroSectionState();
}

class _TrendingHeroSectionState extends State<TrendingHeroSection> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    
    // Auto-scroll every 5 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= widget.movies.take(4).length) {
          nextPage = 0; // Loop back to start
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show top 4 movies as requested
    final trendingMovies = widget.movies.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Text(
            '🔥 Trending Now',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 400, // Adjusted height for image + text below
          child: PageView.builder(
            controller: _pageController,
            itemCount: trendingMovies.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final movie = trendingMovies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailPage(movie: movie),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16), // Full width with padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Large Image (Backdrop/Landscape)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            image: DecorationImage(
                              // Use fullBackdropUrl for landscape view
                              image: NetworkImage(movie.fullBackdropUrl), 
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                             // Optional: subtle gradient for depth
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 2. Info / Text Below Image
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Genres / Metadata
                      Row(
                        children: [
                          Text(
                            _getGenres(movie), // Helper or simplified
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.circle, size: 4, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                             movie.releaseDate.split('-').first,
                             style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Description (Max 2 lines)
                      Text(
                        movie.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                       const SizedBox(height: 16),

                      // Buttons
                      Row(
                        children: [
                           Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Add to Watchlist and Navigate
                                final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
                                watchlistProvider.addToWatchlist(movie);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${movie.title} added to Watchlist')),
                                );

                                // Switch to Watchlist Tab (Index 2)
                                Provider.of<NavigationProvider>(context, listen: false).setIndex(2);
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Watchlist', style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white30),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
         // Pagination Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(trendingMovies.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFFFF005D) : Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getGenres(Movie movie) {
    // Since we don't have genre IDs mapped in the Movie model yet, return mock or generic
    return 'Action • Thriller'; 
  }
}
