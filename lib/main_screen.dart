import 'package:flutter/material.dart';
import 'home_page_content.dart'; // Import konten halaman home
import 'anime_page_content.dart'; // Import konten halaman anime
import 'services/api_service.dart';
import 'services/anime_service.dart';
import 'movies_page_content.dart'; // Import konten halaman Movies
import 'models/movie.dart';
import 'models/anime.dart';
import 'movie_detail_page.dart';
import 'anime_detail_page.dart';

// Daftar kategori untuk TabBar horizontal
const List<String> categories = [
  'Home',
  'Series',
  'Movies',
];

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        // Background color handled by theme, but explicit here for safety if needed
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, 

        appBar: _buildCustomAppBar(context),

        bottomNavigationBar: _buildBottomNavigationBar(context),

        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            HomePageContent(), // Konten Halaman Utama di Tab 'Home'
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tv, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('Series Coming Soon', style: TextStyle(color: Colors.white54, fontSize: 18)),
                ],
              ),
            ),
            MoviesPageContent(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Logo text with gradient or bold color
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF005D), Color(0xFF00E5FF)],
            ).createShader(bounds),
            child: const Text(
              'FilmKu',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white, // Required for ShaderMask
              ),
            ),
          ),

          // Ikon Pencarian dan Profil
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.search, size: 26),
                onPressed: () {
                  showSearch(context: context, delegate: UniversalSearchDelegate());
                },
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF005D), Color(0xFF00E5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
      bottom: TabBar(
        isScrollable: true,
        physics: const BouncingScrollPhysics(),
        indicatorColor: const Color(0xFFFF005D),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        unselectedLabelColor: Colors.white60,
        tabs: categories.map((name) => Tab(text: name)).toList(),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF141414), // Match scaffold for seamless look
        selectedItemColor: const Color(0xFFFF005D),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Shorts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Lainnya'),
        ],
        onTap: (index) {},
      ),
    );
  }
}

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
                      builder: (context) => MovieDetailPage(movie: item),
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
                      builder: (context) => AnimeDetailPage(anime: item),
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
