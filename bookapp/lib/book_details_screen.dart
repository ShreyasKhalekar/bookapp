import 'package:flutter/material.dart';


class BookDetailsScreen extends StatelessWidget {
  final dynamic book;

  BookDetailsScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    final title = book['volumeInfo']['title'];
    final authors = book['volumeInfo']['authors'] ?? ['Unknown'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Title: $title'),
            Text('Authors: ${authors.join(', ')}'),
            // Add more book details as needed
          ],
        ),
      ),
    );
  }
}
