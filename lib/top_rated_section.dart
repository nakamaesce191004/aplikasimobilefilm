import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Added
import 'models/movie.dart';
import 'models/unified_content.dart';
import 'pages/content_detail_page.dart';

class TopRatedSection extends StatelessWidget {
  final List<Movie> movies;
  final VoidCallback? onSeeAllTap;

  const TopRatedSection({
    super.key,
    required this.movies,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700), // Gold accent
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Top Rated Collection',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (onSeeAllTap != null)
                GestureDetector(
                  onTap: onSeeAllTap,
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                       color: const Color(0xFFFFD700), // Gold
                       fontWeight: FontWeight.w600,
                       fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 180, // Landscape height
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Container(
                width: 280, // Wide landscape card
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContentDetailPage(content: UnifiedContent.fromMovie(movie)),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      // Background Image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(movie.fullBackdropUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.9),
                            ],
                            stops: const [0.3, 0.6, 1.0],
                          ),
                        ),
                      ),

                      // Rank Badge (Gold Ribbon effect)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildStarRating(movie.voteAverage),
                                const SizedBox(width: 8),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${_formatVoteCount(movie.voteCount)})',
                                  style: GoogleFonts.inter(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  movie.releaseDate.split('-').first, // Year
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white30),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Movie',
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(double voteAverage) {
    int starCount = 5;
    double rating = voteAverage / 2; // Convert 0-10 to 0-5
    
    return Row(
      children: List.generate(starCount, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Color(0xFFFFD700), size: 14);
        } else if (index < rating && (rating - index) >= 0.5) {
          return const Icon(Icons.star_half, color: Color(0xFFFFD700), size: 14);
        } else {
          return const Icon(Icons.star_border, color: Colors.white24, size: 14);
        }
      }),
    );
  }

  String _formatVoteCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k reviews';
    }
    return '$count reviews';
  }
}
