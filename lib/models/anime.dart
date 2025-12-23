class Anime {
  final int malId;
  final String title;
  final String image;
  final String description;
  final String type;
  final String releaseDate;
  final double score;

  Anime({
    required this.malId,
    required this.title,
    required this.image,
    required this.description,
    required this.type,
    required this.releaseDate,
    required this.score,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      image: json['images']['jpg']['image_url'] ?? '',
      description: json['synopsis'] ?? 'No description available.',
      type: json['type'] ?? 'Anime',
      releaseDate: json['aired'] != null ? json['aired']['string'] ?? 'Unknown' : 'Unknown',
      score: (json['score'] ?? 0.0).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'title': title,
      'images': {
        'jpg': {
          'image_url': image,
        },
      },
      'synopsis': description,
      'type': type,
      'aired': {
        'string': releaseDate,
      },
      'score': score,
    };
  }
}

class AnimeEpisode {
  final String id;
  final int number;
  final String url;

  AnimeEpisode({
     required this.id,
     required this.number,
     required this.url,
  });
}
