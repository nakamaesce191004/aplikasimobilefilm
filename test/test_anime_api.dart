import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_film/services/anime_service.dart';

void main() {
  group('AnimeService - Jikan Tests', () {
    final AnimeService service = AnimeService();

    test('getTopAiring returns data from Jikan', () async {
      final results = await service.getTopAiring();
      print('Jikan Top Airing: ${results.length} found');
      if (results.isNotEmpty) {
        print('First item: ${results.first.title} (Score: ${results.first.score})');
      }
      expect(results, isNotNull);
    });

    test('searchAnime returns results for "Naruto"', () async {
      final results = await service.searchAnime('Naruto');
      print('Search Results: ${results.length} found');
       if (results.isNotEmpty) {
        print('First item: ${results.first.title}');
      }
      expect(results, isNotNull);
    });
    
    test('getWatchUrl constructs correct URL', () {
       final url = service.getWatchUrl('One Piece');
       expect(url, contains('gogoanime'));
       expect(url, contains('One%20Piece'));
    });
  });
}
