import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/navigation_provider.dart';
import 'watchlist_page.dart'; // Add WatchlistPage import
import 'home_page_content.dart';
import 'pages/content_grid_page.dart'; // Import generic grid page
import 'services/api_service.dart';
import 'services/anime_service.dart';
import 'models/movie.dart';
import 'models/anime.dart';
import 'pages/content_detail_page.dart';

// Daftar kategori untuk TabBar horizontal
const List<String> categories = [
  'Home',
  'Series',
  'Movies',
];



class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the navigation provider to rebuild when index changes
    final navigation = ref.watch(navigationProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(navigation.currentIndex),
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, navigation.currentIndex),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeTabContainer();
      case 1:
        // Watchlist is now index 1
        return const WatchlistPage();
      default:
        return const HomeTabContainer();
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF141414),
        selectedItemColor: const Color(0xFFFF005D),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: (index) {
           // Use ref.read for actions/callbacks
           ref.read(navigationProvider).setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Watchlist'),
        ],
      ),
    );
  }
}

class HomeTabContainer extends StatelessWidget {
  const HomeTabContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildCustomAppBar(context),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            const HomePageContent(),
            ContentGridPage(fetchMethod: (page) => AnimeService().getTopAiring(page: page)), // Series Tab
            ContentGridPage(fetchMethod: (page) => ApiService().getMoviesByCategory('popular', page: page)), // Movies Tab
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
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF005D), Color(0xFF00E5FF)],
            ).createShader(bounds),
            child: const Text(
              'FilmKu',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
              IconButton(
                icon: const Icon(Icons.search, size: 26),
                onPressed: () {
                  showSearch(context: context, delegate: UniversalSearchDelegate());
                },
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
                      builder: (context) => ContentDetailPage(content: item),
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
                      builder: (context) => ContentDetailPage(content: item),
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
