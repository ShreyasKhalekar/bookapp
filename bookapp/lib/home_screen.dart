import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _indexController = TextEditingController();
  TextEditingController _bookNameController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _updatedBookNameController = TextEditingController();
  TextEditingController _updatedAuthorController = TextEditingController();
  String indexText = '';
  List<dynamic> books = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromApi();
  }

  // Function to open the BookDetailsScreen
  void openBookDetails(dynamic book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book: book),
      ),
    );
  }

  Future<void> addNewBook() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _bookNameController,
                decoration: const InputDecoration(labelText: 'Book Name'),
              ),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final bookName = _bookNameController.text;
                final authorName = _authorController.text;

                if (bookName.isNotEmpty && authorName.isNotEmpty) {
                  final newBook = {
                    'volumeInfo': {
                      'title': bookName,
                      'authors': [authorName],
                    }
                  };
                  addBook(newBook);
                  Navigator.of(context).pop();
                } else {
                  // Handle empty input or show an error message.
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateBookDialog(int index) async {
    int selectedBookIndex = index;
    String updatedBookName;
    String updatedAuthorName;

    // Show a dialog to prompt the user for the index, book name, and author name
    await showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Update Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the index of the book to update:'),
            TextField(
              controller: _indexController,
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _updatedBookNameController,
              decoration: const InputDecoration(labelText: 'Book Name'),
            ),
            TextField(
              controller: _updatedAuthorController,
              decoration: const InputDecoration(labelText: 'Author Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Update'),
            onPressed: () {
              updatedBookName = _updatedBookNameController.text;
              updatedAuthorName = _updatedAuthorController.text;

              if (selectedBookIndex >= 0 && selectedBookIndex < books.length &&
                  updatedBookName.isNotEmpty && updatedAuthorName.isNotEmpty) {
                // Close the current dialog and proceed to update the book
                Navigator.of(context).pop();
                final updatedBook = {
                  'volumeInfo': {
                    'title': updatedBookName,
                    'authors': [updatedAuthorName],
                  }
                };
                updateBook(selectedBookIndex, updatedBook);
              } else {
                // Display an error message for invalid input
                  const SnackBar(
                    content: Text('Invalid input. Please provide a valid index, book name, and author name.'),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }




  // Function to delete a book with a confirmation dialog
  Future<void> deleteBookConfirmation(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the index of the book to delete:'),
              TextField(
                controller: _indexController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                indexText = _indexController.text;
                int indexToDelete = int.tryParse(indexText) ?? -1;

                if (indexToDelete >= 0 && indexToDelete < books.length) {
                  Navigator.of(context).pop();
                  deleteBook(indexToDelete);
                } else {
                  // Handle invalid index input, such as displaying an error message.
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchDataFromApi() async {
    const apiKey = 'AIzaSyCSAOAG9uZTtW7D1vIaGnc6K1WgI9ey9Xw';

    try {
      final response = await http.get(
          Uri.parse('https://www.googleapis.com/books/v1/volumes?q=Fiction&maxResults=40'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          books = data['items'];
        });
      } else {
        throw Exception('Failed to load data from the API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to add a new book to the list
  void addBook(dynamic book) {
    setState(() {
      books.add(book);
    });
  }

  // Function to update an existing book
  void updateBook(int index, dynamic updatedBook) {
    setState(() {
      books[index] = updatedBook;
    });
  }

  // Function to delete a book
  void deleteBook(int index) {
    setState(() {
      books.removeAt(index);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final title = book['volumeInfo']['title'];
          final authors = book['volumeInfo']['authors'] ?? ['Unknown'];

          return Card(
              elevation: 4, // Shadow elevation
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Space between elements
            child: ListTile(
              title: Text('Index $index: $title'),
              subtitle: Text(authors.join(', ')),
              onTap: () {
                openBookDetails(book); // Open book details page
              },
              onLongPress: () {
                deleteBookConfirmation(index); // Show delete confirmation dialog
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              addNewBook();
            },
            tooltip: 'Add',
            heroTag: 'addButton',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
               indexText = _indexController.text;
               int indexToUpdate = int.tryParse(indexText) ?? -1;
              updateBookDialog(indexToUpdate);
            },
            tooltip: 'Update',
            heroTag: 'updateButton',
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 16), // Space between buttons
          FloatingActionButton(
            onPressed: () {
              indexText = _indexController.text;
              int indexToDelete = int.tryParse(indexText) ?? -1;
              deleteBookConfirmation(indexToDelete);
            },
            tooltip: 'Delete',
            heroTag: 'deleteButton',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}


