import 'package:flutter/material.dart';
import 'dart:async'; // Added for Timer
import 'package:provider/provider.dart'; // Added for Watchlist
import 'providers/watchlist_provider.dart'; // Added for Watchlist
// Added for Navigation
// Added for navigation
import 'models/movie.dart';
import 'movie_detail_page.dart';

import 'package:google_fonts/google_fonts.dart'; // Added
import 'package:url_launcher/url_launcher.dart'; // Added for trailer

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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= widget.movies.take(4).length) {
          nextPage = 0; 
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
    final trendingMovies = widget.movies.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Text(
            '🔥 Trending Now',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 480, // Increased height for better proportions
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
              return Hero(
                tag: 'hero_${movie.id}',
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(movie: movie),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        // 1. Image
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(movie.fullPosterUrl), // Poster is better for vertical hero
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                        
                        // 2. Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.8),
                                Colors.black,
                              ],
                              stops: const [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),

                        // 3. Content
                        Positioned(
                          bottom: 24,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'TMDb ${movie.voteAverage.toStringAsFixed(1)}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    movie.releaseDate.split('-').first,
                                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                           final query = Uri.encodeComponent('${movie.title} trailer');
                                           final url = Uri.parse('https://www.youtube.com/results?search_query=$query');
                                           if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                           }
                                        }, // Plays Trailer on YouTube
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 8,
                                        shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.play_circle_fill, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Play Trailer',
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white30, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                                      onPressed: () {
                                         final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
                                         watchlistProvider.addToWatchlist(movie);
                                         ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${movie.title} added to Watchlist'),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: const Color(0xFF1F1F1F),
                                            ),
                                         );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
         // Pagination Dots
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(trendingMovies.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 24 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? Theme.of(context).primaryColor : Colors.white24,
                borderRadius: BorderRadius.circular(3),
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
