import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../models/anime.dart';
import '../models/unified_content.dart';
import '../pages/content_detail_page.dart';

class ContentSection extends StatelessWidget {
  final String title;
  final List<dynamic> items; // Accepts both List<Movie> and List<Anime>
  final VoidCallback? onSeeAllTap;

  const ContentSection({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              InkWell(
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 250, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(context, item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item, int index) {
    String imageUrl = '';
    String title = '';
    String? score;
    VoidCallback onTap = () {};

    if (item is Movie) {
      imageUrl = item.fullPosterUrl;
      title = item.title;
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailPage(content: UnifiedContent.fromMovie(item)),
          ),
        );
      };
    } else if (item is Anime) {
      imageUrl = item.image;
      title = item.title;
      score = item.score.toString();
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailPage(content: UnifiedContent.fromAnime(item)),
          ),
        );
      };
    }

    return Container(
      width: 150,
      margin: EdgeInsets.only(
        left: index == 0 ? 16.0 : 8.0,
        right: index == items.length - 1 ? 16.0 : 0,
        bottom: 10,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: score != null ? Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              score,
                              style: GoogleFonts.inter(
                                color: Colors.white, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ) : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
