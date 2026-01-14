import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/anime.dart';
import '../widgets/content_section.dart'; // Reuse for item card logic if needed, or build custom grid item
import '../movie_detail_page.dart';
import '../anime_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentGridPage extends StatefulWidget {
  final Future<List<dynamic>> Function(int page) fetchMethod;

  const ContentGridPage({super.key, required this.fetchMethod});

  @override
  State<ContentGridPage> createState() => _ContentGridPageState();
}

class _ContentGridPageState extends State<ContentGridPage> {
  final List<dynamic> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchItems();
    }
  }

  Future<void> _fetchItems() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.fetchMethod(_currentPage);
      
      if (mounted) {
        setState(() {
          if (newItems.isEmpty) {
            _hasMore = false;
          } else {
            _items.addAll(newItems);
            _currentPage++;
          }
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFirstLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstLoad) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF005D)));
    }

    if (_items.isEmpty) {
       return const Center(child: Text('No items found', style: TextStyle(color: Colors.white)));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns for grid view
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(
            child: SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF005D))
            )
          );
        }
        
        final item = _items[index];
        return _buildGridItem(context, item);
      },
    );
  }

  Widget _buildGridItem(BuildContext context, dynamic item) {
    String imageUrl = '';
    String title = '';
    VoidCallback onTap = () {};

    if (item is Movie) {
      imageUrl = item.fullPosterUrl;
      title = item.title;
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MovieDetailPage(movie: item)),
        );
      };
    } else if (item is Anime) {
      imageUrl = item.image;
      title = item.title;
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimeDetailPage(anime: item)),
        );
      };
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
