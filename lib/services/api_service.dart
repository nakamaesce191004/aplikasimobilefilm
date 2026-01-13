2import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

import '../models/review.dart'; // Import the new model

class ApiService {
  final String apiKey = '1f593b971f8e3f13955ba0471d0dac9f';
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    final response = await http.get(Uri.parse('$baseUrl/trending/movie/day?api_key=$apiKey&page=$page'));
    if (response.statusCode == 200) {
      return _parseMovies(response.body);
    } else {
      throw Exception('Failed to load trending movies');
    }
  }
  
  Future<List<Movie>> getMoviesByCategory(String category, {int page = 1}) async {
    // category: 'popular', 'now_playing', 'top_rated'
    final response = await http.get(Uri.parse('$baseUrl/movie/$category?api_key=$apiKey&page=$page'));
    if (response.statusCode == 200) {
      return _parseMovies(response.body);
    } else {
      throw Exception('Failed to load movies for category: $category');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'));
    if (response.statusCode == 200) {
      return _parseMovies(response.body);
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<List<Review>> getMovieReviews(int movieId) async {
    final response = await http.get(Uri.parse('$baseUrl/movie/$movieId/reviews?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  List<Movie> _parseMovies(String responseBody) {
    final Map<String, dynamic> data = json.decode(responseBody);
    final List<dynamic> results = data['results'];
    return results.map((json) => Movie.fromJson(json)).toList();
  }
}

