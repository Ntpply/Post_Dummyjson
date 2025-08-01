import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchPosts();
});

final postByIdProvider = FutureProvider.family<Post, int>((ref, id) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchPostById(id);
});

final commentsByPostIdProvider = FutureProvider.family<List<Comment>, int>((ref, postId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchCommentsByPostId(postId);
});
