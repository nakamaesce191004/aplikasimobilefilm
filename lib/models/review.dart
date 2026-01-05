class Review {
  final String author;
  final String content;
  final double rating;

  Review({
    required this.author,
    required this.content,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] ?? {};
    return Review(
      author: json['author'] ?? 'Anonymous',
      content: json['content'] ?? 'No review text.',
      rating: (authorDetails['rating'] ?? 0.0).toDouble(),
    );
  }
  
  // Jikan API structure is different, so we might need a specific constructor or handle it here
  factory Review.fromJikanJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final scores = json['scores'] ?? {};
    return Review(
      author: user['username'] ?? 'Anonymous',
      content: json['review'] ?? 'No review text.',
      rating: (scores['overall'] ?? 0).toDouble(), 
    );
  }
}
