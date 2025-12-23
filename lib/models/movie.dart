class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? 'No description available.',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? 'Unknown',
    );
  }

  String get fullPosterUrl {
    if (posterPath.isEmpty) return 'https://via.placeholder.com/500x750.png?text=No+Image';
    if (posterPath.startsWith('http')) return posterPath;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropUrl {
    if (backdropPath.isEmpty) return 'https://via.placeholder.com/1280x720.png?text=No+Backdrop';
    if (backdropPath.startsWith('http')) return backdropPath;
    return 'https://image.tmdb.org/t/p/original$backdropPath';
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
    };
  }
}
