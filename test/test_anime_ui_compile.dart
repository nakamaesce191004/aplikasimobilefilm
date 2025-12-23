import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_film/anime_detail_page.dart';
import 'package:mobile_film/models/anime.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('AnimeDetailPage compiles with Jikan model', (WidgetTester tester) async {
    final anime = Anime(
      malId: 1,
      title: 'Test Anime',
      image: 'http://example.com/image.png',
      description: 'Test Description',
      type: 'TV',
      releaseDate: '2023',
      score: 8.5
    );
    
    await tester.pumpWidget(MaterialApp(
      home: AnimeDetailPage(anime: anime),
    ));
    
    expect(find.text('Test Anime'), findsOneWidget);
    expect(find.text('Score: 8.5'), findsOneWidget);
  });
}
