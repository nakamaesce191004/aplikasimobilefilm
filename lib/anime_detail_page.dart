import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'providers/watchlist_provider.dart';
import 'models/anime.dart';
import 'models/review.dart'; // Added
import 'services/anime_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/comment_section.dart'; // Import CommentSection

class AnimeDetailPage extends StatefulWidget {
  final Anime anime;

  const AnimeDetailPage({super.key, required this.anime});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = AnimeService().getAnimeReviews(widget.anime.malId);
  }

  void _watchTrailer(BuildContext context) async {
    final query = Uri.encodeComponent('${widget.anime.title} trailer');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF141414),
            actions: [
               Consumer<WatchlistProvider>(
                builder: (context, provider, child) {
                  final isSaved = provider.isAnimeInWatchlist(widget.anime.malId);
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? const Color(0xFFFF005D) : Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      if (isSaved) {
                        provider.removeAnimeFromWatchlist(widget.anime.malId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.anime.title} removed from Watchlist')),
                        );
                      } else {
                        provider.addAnimeToWatchlist(widget.anime);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.anime.title} added to Watchlist')),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.anime.image,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(color: Colors.grey[900]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.anime.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF005D),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Score: ${widget.anime.score}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.anime.type} • ${widget.anime.releaseDate}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                   const SizedBox(height: 16),
                   Text(
                    widget.anime.description,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                   ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _watchTrailer(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Watch Trailer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF005D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Watch official trailer on YouTube.',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),

                  const SizedBox(height: 32),
                  // Reviews Section (New)
                  // Unified Reviews & Comments Section
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      final apiReviews = snapshot.data;
                      return CommentSection(
                        contentId: 'anime_${widget.anime.malId}', 
                        apiReviews: apiReviews
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
