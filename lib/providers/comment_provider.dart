import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentProvider = ChangeNotifierProvider<CommentProvider>((ref) {
  return CommentProvider();
});

class Comment {
  final String userName;
  final String text;
  final DateTime timestamp;
  final int rating;    // Added rating

  Comment({
    required this.userName,
    required this.text,
    required this.timestamp,
    this.rating = 0,   // Default 0
  });
}

class CommentProvider extends ChangeNotifier {
  // Map contentId -> List<Comment>
  final Map<String, List<Comment>> _comments = {};

  List<Comment> getComments(String contentId) {
    if (!_comments.containsKey(contentId)) {
      return [];
    }
    // Return copy to prevent direct modification
    return List.from(_comments[contentId]!); 
  }

  void addComment(String contentId, String userName, String text, int rating) {
    if (!_comments.containsKey(contentId)) {
      _comments[contentId] = [];
    }

    _comments[contentId]!.insert(0, Comment(
      userName: userName,
      text: text,
      timestamp: DateTime.now(),
      rating: rating,
    ));

    notifyListeners();
  }

  void deleteComment(String contentId, Comment comment) {
    if (_comments.containsKey(contentId)) {
      _comments[contentId]!.removeWhere((c) => 
        c.text == comment.text && 
        c.timestamp == comment.timestamp && 
        c.userName == comment.userName
      );
      notifyListeners();
    }
  }
}
