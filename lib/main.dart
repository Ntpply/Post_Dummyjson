import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/post_list.dart';
import 'screens/post_detail.dart';
import 'screens/create_post.dart'; 
void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JSONPlaceholder Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PostListScreen(),
      routes: {
        PostDetailScreen.routeName: (context) => PostDetailScreen(),
        CreatePostScreen.routeName: (context) => CreatePostScreen(),
      },
    );
  }
}
