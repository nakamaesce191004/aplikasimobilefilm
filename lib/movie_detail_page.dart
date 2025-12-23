import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/api_service.dart'; // Added for fetching reviews
import 'package:provider/provider.dart';
import 'providers/watchlist_provider.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
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
               Consumer<WatchlistProvider>(
                builder: (context, provider, child) {
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
                          onPressed: () {
                              final query = Uri.encodeComponent('${widget.movie.title} trailer');
                              final url = 'https://www.youtube.com/results?search_query=$query';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening trailer for ${widget.movie.title}...'),
                                  action: SnackBarAction(
                                    label: 'Open',
                                    onPressed: () {
                                      print('Launch $url');
                                    },
                                  ),
                                ),
                              );
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
                            final provider = Provider.of<WatchlistProvider>(context, listen: false);
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
                        child: Consumer<WatchlistProvider>(
                          builder: (context, provider, child) {
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
                   Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // FutureBuilder for Reviews
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      } else if (snapshot.hasError) {
                        return const Text('Failed to load reviews.', style: TextStyle(color: Colors.white54));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No reviews yet.', style: TextStyle(color: Colors.white54));
                      }

                      final reviews = snapshot.data!;
                      return Column(
                        children: reviews.take(3).map((review) => Column(
                          children: [
                             _buildReviewItem(review.author, review.content, review.rating),
                             const SizedBox(height: 16),
                          ],
                        )).toList(),
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

  Widget _buildReviewItem(String name, String content, double rating) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white10,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (rating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(rating.toString(), style: const TextStyle(color: Colors.amber)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
