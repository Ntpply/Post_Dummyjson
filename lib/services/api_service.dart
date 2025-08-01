import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';


class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  Future<List<Post>> fetchPosts() async {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List postsList = jsonData['posts'];
        return postsList.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load posts (Status: ${response.statusCode})',
        );
      }
    
  }

  Future<Post> fetchPostById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<List<Comment>> fetchCommentsByPostId(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments/post/$postId'),
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List commentList =
          jsonData['comments']; // DummyJSON returns {'comments': [...], ...}
      return commentList.map((item) => Comment.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Post> createPost(Map<String, dynamic> postData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/add'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(postData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<Post> updatePost(int id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(updatedData),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update post');
    }
  }

  Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}
