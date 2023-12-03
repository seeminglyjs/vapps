import 'package:flutter/material.dart';

class BlogListScreen extends StatelessWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog List'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Blog Post 1'),
            subtitle: const Text('This is the content of Blog Post 1.'),
            onTap: () {
              // Handle tap on Blog Post 1
            },
          ),
          ListTile(
            title: const Text('Blog Post 2'),
            subtitle: const Text('This is the content of Blog Post 2.'),
            onTap: () {
              // Handle tap on Blog Post 2
            },
          ),
          // Add more ListTiles for additional blog posts
        ],
      ),
    );
  }
}
