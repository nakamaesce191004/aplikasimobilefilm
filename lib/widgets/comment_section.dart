import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/comment_provider.dart';
import '../models/review.dart'; // Import Review model

class CommentSection extends ConsumerStatefulWidget {
  final String contentId;
  final List<Review>? apiReviews; // Optional API reviews

  const CommentSection({super.key, required this.contentId, this.apiReviews});

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    ref.read(commentProvider).addComment(
      widget.contentId,
      'You', 
      _commentController.text.trim(),
    );

    _commentController.clear();
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  void _deleteComment(Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Delete Comment?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this comment?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(commentProvider).deleteComment(widget.contentId, comment);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF005D))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Reviews & Comments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Add Comment Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add a review/comment...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _submitComment,
              icon: const Icon(Icons.send, color: Color(0xFFFF005D)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Combined List
        Consumer(
          builder: (context, ref, child) {
            final commentProviderState = ref.watch(commentProvider);
            final localComments = commentProviderState.getComments(widget.contentId);
            final apiReviews = widget.apiReviews ?? [];
            
            // Combine: Local comments first (typically user wants to see their own), then API reviews
            final totalCount = localComments.length + apiReviews.length;

            if (totalCount == 0) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No reviews yet. Be the first!',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true, // Important for nesting in scroll view
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalCount,
              separatorBuilder: (context, index) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                // If index < localComments.length, it's a local comment
                if (index < localComments.length) {
                   final comment = localComments[index];
                   return _buildLocalCommentItem(comment);
                } else {
                   // It's an API review
                   final review = apiReviews[index - localComments.length];
                   return _buildApiReviewItem(review);
                }
              },
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildLocalCommentItem(Comment comment) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor:  Color(0xFFFF005D), // Highlight user
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            comment.userName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white30, size: 20),
            onPressed: () => _deleteComment(comment),
          )
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.text,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(comment.timestamp),
            style: const TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildApiReviewItem(Review review) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            child: Text(review.author.isNotEmpty ? review.author[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        review.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (review.rating > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(review.rating.toString(), style: const TextStyle(color: Colors.amber)),
                        ],
                      )
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  review.content,
                   // Show more lines for reviews
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
