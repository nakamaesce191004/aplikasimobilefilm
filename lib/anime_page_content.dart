import 'package:flutter/material.dart';
import 'services/anime_service.dart';
import 'models/anime.dart';
import 'anime_detail_page.dart';

class AnimePageContent extends StatefulWidget {
  const AnimePageContent({super.key});

  @override
  State<AnimePageContent> createState() => _AnimePageContentState();
}

class _AnimePageContentState extends State<AnimePageContent> {
  final AnimeService _animeService = AnimeService();
  late Future<List<Anime>> _topAiringFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Anime>? _searchResults;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _topAiringFuture = _animeService.getTopAiring();
  }

  void _performSearch() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _animeService.searchAnime(_searchController.text);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search Anime (Jikan API)...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Color(0xFFFF005D)),
                onPressed: _performSearch,
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults != null
                  ? _buildAnimeList(_searchResults!)
                  : FutureBuilder<List<Anime>>(
                      future: _topAiringFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.white)));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No anime found',
                                  style: TextStyle(color: Colors.white)));
                        }
                        return _buildAnimeList(snapshot.data!);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAnimeList(List<Anime> animes) {
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
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnimeDetailPage(anime: anime),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    anime.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (ctx, _, __) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                anime.score > 0 ? '★ ${anime.score}' : 'N/A',
                style: const TextStyle(color: Color(0xFFFF005D), fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
