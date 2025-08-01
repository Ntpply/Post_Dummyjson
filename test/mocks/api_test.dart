import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:post_test/screens/create_post.dart';
import 'package:post_test/screens/post_detail.dart';
import 'package:post_test/screens/post_list.dart';
import 'package:post_test/models/post.dart';
import 'package:post_test/models/comment.dart';
import 'package:post_test/providers/post_provider.dart'; // <-- import provider ตัวจริง
import 'api_test.mocks.dart';

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  testWidgets('PostListScreen shows mocked posts', (tester) async {
    when(mockApiService.fetchPosts()).thenAnswer(
      (_) async => [
        Post(id: 1, title: 'Mock Post 1', body: 'Mock body 1', userId: 1),
        Post(id: 2, title: 'Mock Post 2', body: 'Mock body 2', userId: 2),
      ],
    );

    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: PostListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Mock Post 1'), findsOneWidget);
    expect(find.text('Mock Post 2'), findsOneWidget);
  });
  testWidgets('CreatePostScreen shows validation errors when form is empty', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CreatePostScreen()),
      ),
    );

    await tester.tap(find.text('Create Post'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter title'), findsOneWidget);
    expect(find.text('Please enter body'), findsOneWidget);
    verifyNever(mockApiService.createPost(any));
  });
  testWidgets('PostDetailScreen shows post and comments', (tester) async {
    // mock post
    final post = Post(id: 1, title: 'Mock Post Title', body: 'Mock body text', userId: 1);

    // mock comments
    final comments = [
      Comment(id: 1, name: 'John Doe', body: 'Great post!', postId: 1),
      Comment(id: 2, name: 'Jane Doe', body: 'Interesting...', postId: 1),
    ];

    when(mockApiService.fetchPostById(1)).thenAnswer((_) async => post);
    when(mockApiService.fetchCommentsByPostId(1)).thenAnswer((_) async => comments);

    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == PostDetailScreen.routeName) {
              return MaterialPageRoute(
                builder: (_) => PostDetailScreen(),
                settings: RouteSettings(arguments: 1),
              );
            }
            return null;
          },
          initialRoute: PostDetailScreen.routeName,
        ),
      ),
    );

    await tester.pump(); // start first frame
    await tester.pump(const Duration(seconds: 1)); // wait for data

    // expect post title & body
    expect(find.text('Mock Post Title'), findsOneWidget);
    expect(find.text('Mock body text'), findsOneWidget);

    // expect comment
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Great post!'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Interesting...'), findsOneWidget);
  });

  testWidgets('Click Edit button switches to edit mode', (tester) async {
    final post = Post(id: 1, title: 'Edit Title', body: 'Edit Body', userId: 1);

    when(mockApiService.fetchPostById(1)).thenAnswer((_) async => post);
    when(mockApiService.fetchCommentsByPostId(1)).thenAnswer((_) async => []);

    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == PostDetailScreen.routeName) {
              return MaterialPageRoute(
                builder: (_) => PostDetailScreen(),
                settings: RouteSettings(arguments: 1),
              );
            }
            return null;
          },
          initialRoute: PostDetailScreen.routeName,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // load data

    await tester.tap(find.text('Edit'));
    await tester.pump();

    // now we should see editable text fields
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Click Delete shows confirmation dialog', (tester) async {
    final post = Post(id: 1, title: 'Delete Me', body: 'Body', userId: 1);
    when(mockApiService.fetchPostById(1)).thenAnswer((_) async => post);
    when(mockApiService.fetchCommentsByPostId(1)).thenAnswer((_) async => []);

    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == PostDetailScreen.routeName) {
              return MaterialPageRoute(
                builder: (_) => PostDetailScreen(),
                settings: RouteSettings(arguments: 1),
              );
            }
            return null;
          },
          initialRoute: PostDetailScreen.routeName,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // load data

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Delete'), findsOneWidget);
    expect(find.text('Are you sure to delete this post?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}


