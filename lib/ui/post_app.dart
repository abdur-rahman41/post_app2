import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(PostApp());
}

class PostApp extends StatefulWidget {
  @override
  _PostAppState createState() => _PostAppState();
}

class _PostAppState extends State<PostApp> {
  List<dynamic> posts = [];
  bool isLoading = false;
  int page = 1;
  int limit = 10;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      fetchPosts();
    }
  }

  Future<void> fetchPosts() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_start=${(page - 1) * limit}&_limit=$limit'));

    if (response.statusCode == 200) {
      final List<dynamic> fetchedPosts = json.decode(response.body);
      setState(() {
        posts.addAll(fetchedPosts);
        isLoading = false;
        page++;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to fetch posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: posts.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == posts.length) {
              if (isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SizedBox();
              }
            } else {
              final post = posts[index];
              return ListTile(
                title: Text(post['title']),
                subtitle: Text(post['body']),
              );
            }
          },
        ),
      ),
    );
  }
}
