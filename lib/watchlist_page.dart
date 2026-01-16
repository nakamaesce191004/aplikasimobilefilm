import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/watchlist_provider.dart';
import 'pages/content_detail_page.dart';
import 'models/unified_content.dart';
import 'models/movie.dart';
import 'models/anime.dart'; // Import Anime model

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('My Watchlist'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF005D),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Movies'),
              Tab(text: 'Anime'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMovieWatchlist(context, ref),
            _buildAnimeWatchlist(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieWatchlist(BuildContext context, WidgetRef ref) {
    final watchlistProviderRef = ref.watch(watchlistProvider);
    final movies = watchlistProviderRef.watchlist;
      
    if (movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Your movies watchlist is empty', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(context, ref, movie);
      },
    );
  }

  Widget _buildAnimeWatchlist(BuildContext context, WidgetRef ref) {
    final watchlistProviderRef = ref.watch(watchlistProvider);
    final animes = watchlistProviderRef.animeWatchlist;
    
    if (animes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Your anime watchlist is empty', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: animes.length,
      itemBuilder: (context, index) {
        final anime = animes[index];
        return _buildAnimeCard(context, ref, anime);
      },
    );
  }

  Widget _buildMovieCard(BuildContext context, WidgetRef ref, Movie movie) {
    return Stack(
      children: [
         GestureDetector(
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentDetailPage(content: UnifiedContent.fromMovie(movie)),
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
            ]
          )
         ),
         Positioned(
           top: 4,
           right: 4,
           child: GestureDetector(
             onTap: () {
               ref.read(watchlistProvider).removeFromWatchlist(movie.id);
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('${movie.title} removed from Watchlist')),
               );
             },
             child: Container(
               decoration: const BoxDecoration(
                 color: Colors.black54,
                 shape: BoxShape.circle
               ),
               padding: const EdgeInsets.all(6),
               child: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
             )
           )
         )
      ]
    );
  }

  Widget _buildAnimeCard(BuildContext context, WidgetRef ref, Anime anime) {
    return Stack(
      children: [
         GestureDetector(
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentDetailPage(content: UnifiedContent.fromAnime(anime)),
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
                      image: NetworkImage(anime.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
               Text(
                anime.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          )
         ),
         Positioned(
           top: 4,
           right: 4,
           child: GestureDetector(
             onTap: () {
               ref.read(watchlistProvider).removeAnimeFromWatchlist(anime.malId);
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('${anime.title} removed from Watchlist')),
               );
             },
             child: Container(
               decoration: const BoxDecoration(
                 color: Colors.black54,
                 shape: BoxShape.circle
               ),
               padding: const EdgeInsets.all(6),
               child: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
             )
           )
         )
      ]
    );
  }
}
