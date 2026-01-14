import '../models/movie.dart';
import '../models/anime.dart';

enum ContentType { movie, anime }

class UnifiedContent {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String subtitle; // e.g., "Movie • 2023"
  final String rating;
  final String overview;
  final ContentType type;
  final dynamic originalData; // Keep reference to original object

  UnifiedContent({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.subtitle,
    required this.rating,
    required this.overview,
    required this.type,
    required this.originalData,
  });

  factory UnifiedContent.fromMovie(Movie movie) {
    return UnifiedContent(
      id: movie.id,
      title: movie.title,
      posterUrl: movie.fullPosterUrl,
      backdropUrl: movie.fullBackdropUrl,
      subtitle: 'Movie • ${movie.releaseDate.split('-').first}',
      rating: movie.voteAverage.toStringAsFixed(1),
      overview: movie.overview,
      type: ContentType.movie,
      originalData: movie,
    );
  }

  factory UnifiedContent.fromAnime(Anime anime) {
    return UnifiedContent(
      id: anime.malId,
      title: anime.title,
      posterUrl: anime.image,
      backdropUrl: anime.image, // Anime often uses same image
      subtitle: 'Anime • ${anime.score > 0 ? "★ ${anime.score}" : ""}',
      rating: anime.score.toString(),
      overview: anime.description,
      type: ContentType.anime,
      originalData: anime,
    );
  }
}
