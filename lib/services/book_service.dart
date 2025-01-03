import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import 'database_helper.dart';

class BookService {
  static const String apiUrl = 'https://api.nytimes.com/svc/books/v3/lists/current/hardcover-fiction.json?api-key=dGblpgZMyJTvo7AUlmKVbDYSgZCmW2lC';
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Tambahkan flag untuk mengontrol refresh dari API
  bool _hasLoadedFromApi = false;

  Future<List<Book>> fetchBooks() async {
    try {
      // Pertama, coba ambil data dari database lokal
      List<Book> localBooks = await _dbHelper.getAllBooks();
      
      // Jika sudah ada data lokal dan belum perlu refresh dari API
      if (localBooks.isNotEmpty && _hasLoadedFromApi) {
        print('Menggunakan data dari database lokal: ${localBooks.length} buku');
        return localBooks;
      }

      // Jika tidak ada data lokal atau perlu refresh, ambil dari API
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results']['books'];
        print('Data baru dari API: ${results.length} buku');
        
        // Konversi data API ke objek Book
        final List<Book> apiBooks = results.map((json) => Book.fromJson(json)).toList();
        
        // Simpan atau update setiap buku ke database
        for (var book in apiBooks) {
          // Cek apakah buku sudah ada di database
          Book? existingBook = await _dbHelper.getBookById(book.id);
          if (existingBook != null) {
            // Jika buku sudah dimodifikasi secara lokal, pertahankan data lokalnya
            if (await _dbHelper.isBookLocallyModified(book.id)) {
              continue; // Skip update dari API untuk buku yang telah dimodifikasi lokal
            }
            // Jika tidak dimodifikasi lokal, update dengan data API tapi pertahankan status baca
            book.isRead = existingBook.isRead;
            book.readTimeInMinutes = existingBook.readTimeInMinutes;
            book.lastReadAt = existingBook.lastReadAt;
          }
          await _dbHelper.insertBook(book);
        }
        
        _hasLoadedFromApi = true;
        return await _dbHelper.getAllBooks();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching books: $e');
      return await _dbHelper.getAllBooks();
    }
  }

  // Method untuk memaksa refresh data dari API
  Future<List<Book>> refreshFromApi() async {
    _hasLoadedFromApi = false;
    return await fetchBooks();
  }

  // Local Storage Methods
  Future<List<Book>> getAllBooks() async {
    return await _dbHelper.getAllBooks();
  }

  Future<void> addBook(Book book) async {
    await _dbHelper.insertBook(book);
  }

  Future<void> updateBook(Book book) async {
    await _dbHelper.updateBook(book);
  }

  Future<void> deleteBook(String id) async {
    await _dbHelper.deleteBook(id);
  }

  Future<Book?> getBookById(String id) async {
    return await _dbHelper.getBookById(id);
  }
} 