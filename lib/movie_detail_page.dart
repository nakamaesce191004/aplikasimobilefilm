import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../models/review.dart'; // Added
import '../../services/api_service.dart'; // Added for fetching reviews
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/watchlist_provider.dart';
import 'widgets/comment_section.dart'; // Import CommentSection
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class MovieDetailPage extends ConsumerStatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  ConsumerState<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends ConsumerState<MovieDetailPage> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ApiService().getMovieReviews(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 400.0,
            floating: false,
            pinned: true,
            actions: [
               Consumer(
                builder: (context, ref, child) {
                  final provider = ref.watch(watchlistProvider);
                  final isSaved = provider.isInWatchlist(widget.movie.id);
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? const Color(0xFFFF005D) : Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      if (isSaved) {
                        provider.removeFromWatchlist(widget.movie.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.movie.title} removed from Watchlist')),
                        );
                      } else {
                        provider.addToWatchlist(widget.movie);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.movie.title} added to Watchlist')),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                widget.movie.title,
                textScaleFactor: 1.0,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.movie.fullBackdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                          child: Icon(Icons.movie, size: 50, color: Colors.white24)),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF141414)],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info Row
                  Row(
                    children: [
                      _buildTag(widget.movie.releaseDate.split('-').first),
                      const SizedBox(width: 8),
                      _buildTag('Movie'), // Type hardcoded for now
                      const SizedBox(width: 8),
                      const Spacer(),
                      const Icon(Icons.hd, color: Colors.white54),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Rating Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.movie.voteAverage.toStringAsFixed(1),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Icon(Icons.star_half, color: Colors.amber, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'TMDb Rating',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                              final query = Uri.encodeComponent('${widget.movie.title} trailer');
                              final url = Uri.parse('https://www.youtube.com/results?search_query=$query');
                              
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Could not launch YouTube')),
                                  );
                                }
                              }
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Watch Trailer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                            // Add to Watchlist Logic (Duplicate of AppBar logic, but good for UX)
                            final provider = ref.read(watchlistProvider);
                            if (provider.isInWatchlist(widget.movie.id)) {
                                provider.removeFromWatchlist(widget.movie.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${widget.movie.title} removed from Watchlist')),
                                );
                            } else {
                                provider.addToWatchlist(widget.movie);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${widget.movie.title} added to Watchlist')),
                                );
                            }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Use Consumer to update icon state if needed, or just keep as generic Add/Check
                        child: Consumer(
                          builder: (context, ref, child) {
                             final provider = ref.watch(watchlistProvider);
                             return Icon(
                               provider.isInWatchlist(widget.movie.id) ? Icons.check : Icons.add,
                               color: Colors.white
                             );
                          }
                        ),
                      ),
                      const SizedBox(width: 12),
                       OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.share, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Storyline
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Reviews
                  // Unified Reviews & Comments Section
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      // Pass empty list if loading/error to allow commenting immediately, 
                      // or wait. Ideally we show comments even if API fails.
                      final apiReviews = snapshot.data; 
                      return CommentSection(
                        contentId: 'movie_${widget.movie.id}', 
                        apiReviews: apiReviews
                      );
                    },
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }


}
