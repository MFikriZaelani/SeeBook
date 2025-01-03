import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/book_detail_screen.dart';
import '../services/book_service.dart';

class BookSearchDelegate extends SearchDelegate<void> {
  final List<Book> books;
  final BookService bookService;
  final Function() onBookUpdated;

  BookSearchDelegate({
    required this.books,
    required this.bookService,
    required this.onBookUpdated,
  });

  @override
  String get searchFieldLabel => 'Cari judul atau penulis...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Masukkan kata kunci pencarian'),
      );
    }

    final lowercaseQuery = query.toLowerCase();
    final searchResults = books.where((book) {
      final lowercaseTitle = book.title.toLowerCase();
      final lowercaseAuthor = book.author.toLowerCase();
      return lowercaseTitle.contains(lowercaseQuery) ||
          lowercaseAuthor.contains(lowercaseQuery);
    }).toList();

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil untuk "$query"',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final book = searchResults[index];
        return ListTile(
          leading: SizedBox(
            width: 40,
            child: Image.network(
              book.coverImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.book),
            ),
          ),
          title: Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () async {
            close(context, null);
            final bool? wasUpdated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailScreen(
                  book: book,
                  bookService: bookService,
                ),
              ),
            );
            if (wasUpdated == true) {
              onBookUpdated();
            }
          },
        );
      },
    );
  }
} 