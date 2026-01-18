import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';
import '../models/review.dart';

class AnimeService {
  final String baseUrl = 'https://api.jikan.moe/v4';

  Future<List<Anime>> searchAnime(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/anime?q=$query&sfw'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        return results.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load anime');
      }
    } catch (e) {
      print('Error searching anime: $e');
      return [];
    }
  }

  Future<List<Anime>> getTopAiring({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/top/anime?filter=airing&page=$page&sfw'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
         final List<dynamic> results = data['data'];
        return results.map((json) => Anime.fromJson(json)).toList();
      } else {
         throw Exception('Failed to load top airing anime');
      }
    } catch(e) {
       print('Error fetching top airing: $e');
       return [];
    }
  }

  // Jikan doesn't provide direct streaming links easily, so we mock episodes or return empty
  // For watching, we will construct a search URL to a popular site.
  Future<List<AnimeEpisode>> getEpisodes(int malId) async {
     // We can just return a dummy list to let the UI show "Watch" button that leads to search
     // Or we can fetch episode list from Jikan if needed, but they don't have stream links.
     return List.generate(1, (index) => AnimeEpisode(
       id: 'search', 
       number: 1, 
       url: '' 
     ));
  }
  
  Future<List<Review>> getAnimeReviews(int malId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/anime/$malId/reviews'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        return results.map((json) => Review.fromJikanJson(json)).toList();
      } else {
         throw Exception('Failed to load anime reviews');
      }
    } catch(e) {
       print('Error fetching anime reviews: $e');
       return [];
    }
  }

}
