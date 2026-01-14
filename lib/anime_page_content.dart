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
  final ScrollController _scrollController = ScrollController();
  final List<Anime> _animes = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchAnime();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchAnime();
    }
  }

  Future<void> _fetchAnime() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newAnimes = await _animeService.getTopAiring(page: _currentPage);
      
      setState(() {
        if (newAnimes.isEmpty) {
          _hasMore = false;
        } else {
          _animes.addAll(newAnimes);
          _currentPage++;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error loading anime: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animes.isEmpty && _isLoading) {
       return const Center(child: CircularProgressIndicator());
    }
    
    // Initial error or empty state (optional to handle better)
    if (_animes.isEmpty && !_hasMore) {
       return const Center(child: Text('No anime found', style: TextStyle(color: Colors.white)));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _animes.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _animes.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final anime = _animes[index];
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
