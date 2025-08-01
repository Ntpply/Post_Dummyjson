class Comment {
  final int id;
  final String name;
  final String body;
  final int postId;

  Comment({
    required this.id,
    required this.name,
    required this.body,
    required this.postId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      name: json['name'] ?? '',
      body: json['body'] ?? '',
      postId: json['postId'] as int,
    );
  }
}
