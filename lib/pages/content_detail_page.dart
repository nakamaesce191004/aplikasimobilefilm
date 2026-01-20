import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/unified_content.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../services/anime_service.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/comment_section.dart';

class ContentDetailPage extends ConsumerStatefulWidget {
  final UnifiedContent content;

  const ContentDetailPage({super.key, required this.content});

  @override
  ConsumerState<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends ConsumerState<ContentDetailPage> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() {
    if (widget.content.type == ContentType.movie) {
      _reviewsFuture = ApiService().getMovieReviews(widget.content.id);
    } else {
      _reviewsFuture = AnimeService().getAnimeReviews(widget.content.id);
    }
  }

  void _watchTrailer(BuildContext context) async {
    final query = Uri.encodeComponent('${widget.content.title} trailer');
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

  void _toggleWatchlist() {
    final provider = ref.read(watchlistProvider);
    final isMovie = widget.content.type == ContentType.movie;
    final id = widget.content.id;
    final isSaved = isMovie 
        ? provider.isInWatchlist(id) 
        : provider.isAnimeInWatchlist(id);

    if (isSaved) {
      if (isMovie) {
        provider.removeFromWatchlist(id);
      } else {
        provider.removeAnimeFromWatchlist(id);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.content.title} removed from Watchlist')),
      );
    } else {
      if (isMovie) {
        provider.addToWatchlist(widget.content.originalData);
      } else {
        provider.addAnimeToWatchlist(widget.content.originalData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.content.title} added to Watchlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow(),
                  const SizedBox(height: 24),
                  _buildRatingHeader(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.content.overview,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildReviewsSection(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 400.0,
      floating: false,
      pinned: true,
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final provider = ref.watch(watchlistProvider);
            final isSaved = widget.content.type == ContentType.movie
                ? provider.isInWatchlist(widget.content.id)
                : provider.isAnimeInWatchlist(widget.content.id);

            return IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? const Color(0xFFFF005D) : Colors.white,
                size: 28,
              ),
              onPressed: _toggleWatchlist,
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.content.title,
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
              widget.content.backdropUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(
                color: Colors.grey.shade900,
                child: const Center(child: Icon(Icons.movie, size: 50, color: Colors.white24)),
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
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        if (widget.content.subtitle.isNotEmpty) ...[
           _buildTag(widget.content.subtitle),
           const SizedBox(width: 8),
        ],
        const Spacer(),
        const Icon(Icons.hd, color: Colors.white54),
      ],
    );
  }

  Widget _buildRatingHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.content.rating,
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
              widget.content.type == ContentType.movie ? 'TMDb Rating' : 'Score',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: _toggleWatchlist,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            side: const BorderSide(color: Colors.white54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final provider = ref.watch(watchlistProvider);
              final isSaved = widget.content.type == ContentType.movie
                  ? provider.isInWatchlist(widget.content.id)
                  : provider.isAnimeInWatchlist(widget.content.id);
              return Icon(isSaved ? Icons.check : Icons.add, color: Colors.white);
            },
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            side: const BorderSide(color: Colors.white54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Icon(Icons.share, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        return CommentSection(
          contentId: '${widget.content.type == ContentType.movie ? "movie" : "anime"}_${widget.content.id}',
          apiReviews: snapshot.data,
        );
      },
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
