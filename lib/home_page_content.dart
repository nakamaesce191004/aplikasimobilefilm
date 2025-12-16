import 'package:flutter/material.dart';
import 'movie_section.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const <Widget>[
        MovieSection(
          title: 'Rekomendasi Untukmu',
          movieTitles: [
            'Kisah Cinta Cukurukuk',
            'sedihnya ditinggalin rakagit',
            'Fast & Furious',
            'Fast & Furious 9',
            'Fast & Furious 10',
            'Fast & Furious 11',
            'Fast & Furious 12',
          ],
        ),
        SizedBox(height: 20),

        MovieSection(
          title: 'Horor',
          movieTitles: ['Jujutsu Kaisen', 'Kamen Rider', 'My Hero Academia'],
        ),
        SizedBox(height: 20),

        MovieSection(
          title: 'Vidio Originals',
          movieTitles: ['Pertaruhan 3', 'Sugar Daddy'],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
