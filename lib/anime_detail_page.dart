import 'package:flutter/material.dart';
import 'package:mobile_film/webview_player_page.dart';
import 'package:provider/provider.dart';
import 'providers/watchlist_provider.dart';
import 'models/anime.dart';
import 'models/review.dart'; // Added
import 'services/anime_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _watchAnime(BuildContext context) async {
    final AnimeService service = AnimeService();
    final url = service.getWatchUrl(widget.anime.title);
    
    // Webview only supports Android and iOS
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPlayerPage(
            url: url,
            title: 'Watch: ${widget.anime.title}',
          ),
        ),
      );
    } else {
      // Fallback for Windows/Web/Desktop
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch streaming URL')),
          );
        }
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
                      onPressed: () => _watchAnime(context),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Watch in App'),
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
                    'Browse episodes directly within the app.',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),

                  const SizedBox(height: 32),
                  // Reviews Section (New)
                  Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
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
                        children: reviews.map((review) => Column(
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
          ),
        ],
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
