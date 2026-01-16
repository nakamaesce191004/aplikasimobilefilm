import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/anime_service.dart';
import '../models/movie.dart';
import '../models/anime.dart';
import '../models/unified_content.dart';
import '../pages/content_detail_page.dart';

class UniversalSearchDelegate extends SearchDelegate {
  final ApiService _apiService = ApiService();
  final AnimeService _animeService = AnimeService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141414),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _apiService.searchMovies(query),
        _animeService.searchAnime(query),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }

        final movieResults = (snapshot.data?[0] as List<Movie>?) ?? [];
        final animeResults = (snapshot.data?[1] as List<Anime>?) ?? [];
        final combinedResults = [...movieResults, ...animeResults];

        if (combinedResults.isEmpty) {
          return const Center(child: Text('No results found', style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          itemCount: combinedResults.length,
          itemBuilder: (context, index) {
            final item = combinedResults[index];
            
            if (item is Movie) {
              return ListTile(
                leading: Image.network(
                  item.fullPosterUrl,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => const Icon(Icons.movie, color: Colors.white),
                ),
                title: Text(item.title, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Movie • ${item.releaseDate.split('-')[0]}', 
                  style: const TextStyle(color: Colors.white70)
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentDetailPage(content: UnifiedContent.fromMovie(item)),
                    ),
                  );
                },
              );
            } else if (item is Anime) {
               return ListTile(
                leading: Image.network(
                  item.image,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => const Icon(Icons.movie, color: Colors.white),
                ),
                title: Text(item.title, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Anime • ${item.score > 0 ? "★ ${item.score}" : ""}', 
                  style: const TextStyle(color: Colors.white70)
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentDetailPage(content: UnifiedContent.fromAnime(item)),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
