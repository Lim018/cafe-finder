/// OPTIMISTIC UI UTILITY EXAMPLE
/// 
/// This file serves as an architectural pattern/example of how to handle
/// Optimistic Updates using standard state management (like Riverpod or Provider).
/// 
/// Scenario: A user taps "Like" on a post. We want to instantly update the UI 
/// to show the post as liked, and revert it back if the API call fails.

import 'package:flutter/material.dart';

// --- Domain Models ---
class Post {
  final String id;
  final String title;
  final bool isLiked;

  Post({required this.id, required this.title, this.isLiked = false});

  Post copyWith({String? id, String? title, bool? isLiked}) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

// --- Abstract API Service ---
class PostApiService {
  Future<void> toggleLike(String postId, bool likeStatus) async {
    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate a random network failure (uncomment to test failure)
    // throw Exception('Network error');
  }
}

// --- State Management Pattern (Simplified BLoC/Notifier approach) ---
class PostController extends ChangeNotifier {
  final PostApiService _apiService;
  
  List<Post> _posts = [
    Post(id: '1', title: 'Amazing Flutter Tips'),
    Post(id: '2', title: 'Building Great UX'),
  ];
  
  List<Post> get posts => _posts;

  PostController(this._apiService);

  Future<void> toggleLikeOptimistically(String postId) async {
    // 1. Find the target post
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final currentPost = _posts[index];
    final originalStatus = currentPost.isLiked;
    final newStatus = !originalStatus;

    // 2. OPTIMISTIC UPDATE: Update local state immediately
    _posts[index] = currentPost.copyWith(isLiked: newStatus);
    notifyListeners();

    try {
      // 3. Perform the actual API call
      await _apiService.toggleLike(postId, newStatus);
      // If successful, do nothing. The UI is already correct.
    } catch (e) {
      // 4. ROLLBACK ON FAILURE: Revert to original state
      _posts[index] = currentPost.copyWith(isLiked: originalStatus);
      notifyListeners();
      
      // Optional: Propagate error or trigger a snackbar
      // throw Exception('Failed to like post. Reverted changes.');
    }
  }
}
