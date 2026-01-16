import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Added
import '../models/movie.dart';
import '../models/anime.dart';
import '../models/unified_content.dart';
import '../pages/content_detail_page.dart';

class SeeAllPage extends StatefulWidget {
  final String title;
  final Future<List<dynamic>> Function(int page) fetchMethod; // Function to fetch data

  const SeeAllPage({
    super.key,
    required this.title,
    required this.fetchMethod,
  });

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  final List<dynamic> _items = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
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
    if (_isBottom && !_isLoading && _hasMore) {
      _fetchItems();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _fetchItems() async {
     if (_isLoading) return;
     
     setState(() {
       _isLoading = true;
     });

     try {
       final newItems = await widget.fetchMethod(_page);
       
       if (mounted) {
         setState(() {
           if (newItems.isEmpty) {
             _hasMore = false;
           } else {
             _items.addAll(newItems);
             _page++;
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
           SnackBar(content: Text('Failed to load more items: $e')),
         );
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15141F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isFirstLoad 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF005D))) 
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _items.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _items.length) {
                  final item = _items[index];
                  return _buildItemCard(context, item);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF005D)),
                  );
                }
              },
            ),
          ),
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    String imageUrl = '';
    String title = '';
    String? rating;
    VoidCallback onTap = () {};

    if (item is Movie) {
      imageUrl = item.fullPosterUrl;
      title = item.title;
      rating = item.voteAverage.toStringAsFixed(1);
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContentDetailPage(content: UnifiedContent.fromMovie(item))),
        );
      };
    } else if (item is Anime) {
      imageUrl = item.image;
      title = item.title;
      rating = item.score.toString();
      onTap = () {
         Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContentDetailPage(content: UnifiedContent.fromAnime(item))),
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
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                   if (rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: GoogleFonts.inter(
                                color: Colors.white, 
                                fontSize: 10, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
