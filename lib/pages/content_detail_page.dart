import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../models/anime.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../services/anime_service.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/comment_section.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentDetailPage extends ConsumerStatefulWidget {
  final dynamic content; // Accepts Movie or Anime

  const ContentDetailPage({super.key, required this.content});

  @override
  ConsumerState<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends ConsumerState<ContentDetailPage> {
  late Future<List<Review>> _reviewsFuture;

  bool get isMovie => widget.content is Movie;
  bool get isAnime => widget.content is Anime;

  @override
  void initState() {
    super.initState();
    if (isMovie) {
      _reviewsFuture = ApiService().getMovieReviews((widget.content as Movie).id);
    } else if (isAnime) {
      _reviewsFuture = AnimeService().getAnimeReviews((widget.content as Anime).malId);
    }
  }

  // Getters for unified data access
  String get title => isMovie ? (widget.content as Movie).title : (widget.content as Anime).title;
  String get posterUrl => isMovie ? (widget.content as Movie).fullPosterUrl : (widget.content as Anime).image;
  String get backdropUrl => isMovie ? (widget.content as Movie).fullBackdropUrl : (widget.content as Anime).image; // Anime uses same image usually
  String get overview => isMovie ? (widget.content as Movie).overview : (widget.content as Anime).description;
  String get rating => isMovie ? (widget.content as Movie).voteAverage.toStringAsFixed(1) : (widget.content as Anime).score.toString();
  String get releaseDate => isMovie ? (widget.content as Movie).releaseDate : (widget.content as Anime).releaseDate;
  String get contentId => isMovie ? 'movie_${(widget.content as Movie).id}' : 'anime_${(widget.content as Anime).malId}';

  void _watchTrailer(BuildContext context) async {
    final query = Uri.encodeComponent('$title trailer');
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
                  bool isSaved = false;
                  if (isMovie) {
                    isSaved = provider.isInWatchlist((widget.content as Movie).id);
                  } else {
                    isSaved = provider.isAnimeInWatchlist((widget.content as Anime).malId);
                  }

                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? const Color(0xFFFF005D) : Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      if (isSaved) {
                        if (isMovie) {
                           provider.removeFromWatchlist((widget.content as Movie).id);
                        } else {
                           provider.removeAnimeFromWatchlist((widget.content as Anime).malId);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$title removed from Watchlist')),
                        );
                      } else {
                        if (isMovie) {
                           provider.addToWatchlist(widget.content as Movie);
                        } else {
                           provider.addAnimeToWatchlist(widget.content as Anime);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$title added to Watchlist')),
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
                title,
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
                    backdropUrl,
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
                      if (releaseDate.isNotEmpty) ...[
                        _buildTag(releaseDate.split(RegExp(r'[- ]')).first),
                         const SizedBox(width: 8),
                      ],
                      _buildTag(isMovie ? 'Movie' : 'Anime'), 
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
                        rating,
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
                          Text(
                            isMovie ? 'TMDb Rating' : 'Score',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                          onPressed: () => _watchTrailer(context),
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
                             final provider = ref.read(watchlistProvider);
                             bool isSaved = false;
                             if (isMovie) isSaved = provider.isInWatchlist((widget.content as Movie).id);
                             else isSaved = provider.isAnimeInWatchlist((widget.content as Anime).malId);

                            if (isSaved) {
                                if (isMovie) provider.removeFromWatchlist((widget.content as Movie).id);
                                else provider.removeAnimeFromWatchlist((widget.content as Anime).malId);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$title removed from Watchlist')),
                                );
                            } else {
                                if (isMovie) provider.addToWatchlist(widget.content as Movie);
                                else provider.addAnimeToWatchlist(widget.content as Anime);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$title added to Watchlist')),
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
                        child: Consumer(
                          builder: (context, ref, child) {
                             final provider = ref.watch(watchlistProvider);
                             bool isSaved = false;
                             if (isMovie) isSaved = provider.isInWatchlist((widget.content as Movie).id);
                             else isSaved = provider.isAnimeInWatchlist((widget.content as Anime).malId);

                             return Icon(
                               isSaved ? Icons.check : Icons.add,
                               color: Colors.white
                             );
                          }
                        ),
                      ),
                       const SizedBox(width: 12),
                       OutlinedButton(
                        onPressed: () {}, // Share logic placeholder
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
                    overview,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Unified Reviews & Comments Section
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      final apiReviews = snapshot.data; 
                      return CommentSection(
                        contentId: contentId, 
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
