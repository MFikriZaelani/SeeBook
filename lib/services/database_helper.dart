import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'book_library.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        description TEXT,
        coverImage TEXT,
        genre TEXT,
        isRead INTEGER NOT NULL DEFAULT 0,
        readTimeInMinutes INTEGER NOT NULL DEFAULT 0,
        lastReadAt TEXT
      )
    ''');
  }

  // CRUD Operations
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert(
      'books',
      {
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'description': book.description,
        'coverImage': book.coverImage,
        'genre': book.genre.join(','),
        'isRead': book.isRead ? 1 : 0,
        'readTimeInMinutes': book.readTimeInMinutes,
        'lastReadAt': book.lastReadAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    
    return List.generate(maps.length, (i) {
      return Book(
        id: maps[i]['id'],
        title: maps[i]['title'],
        author: maps[i]['author'],
        description: maps[i]['description'] ?? '',
        coverImage: maps[i]['coverImage'] ?? '',
        genre: (maps[i]['genre'] as String?)
            ?.split(',')
            .where((s) => s.isNotEmpty)
            .toList() ?? [],
        isRead: maps[i]['isRead'] == 1,
        readTimeInMinutes: maps[i]['readTimeInMinutes'] ?? 0,
        lastReadAt: maps[i]['lastReadAt'] != null 
            ? DateTime.parse(maps[i]['lastReadAt']) 
            : null,
      );
    });
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      {
        'title': book.title,
        'author': book.author,
        'description': book.description,
        'coverImage': book.coverImage,
        'genre': book.genre.join(','),
        'isRead': book.isRead ? 1 : 0,
        'readTimeInMinutes': book.readTimeInMinutes,
        'lastReadAt': book.lastReadAt?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(String id) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Book?> getBookById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return Book(
      id: maps[0]['id'],
      title: maps[0]['title'],
      author: maps[0]['author'],
      description: maps[0]['description'] ?? '',
      coverImage: maps[0]['coverImage'] ?? '',
      genre: (maps[0]['genre'] as String?)
          ?.split(',')
          .where((s) => s.isNotEmpty)
          .toList() ?? [],
      isRead: maps[0]['isRead'] == 1,
      readTimeInMinutes: maps[0]['readTimeInMinutes'] ?? 0,
      lastReadAt: maps[0]['lastReadAt'] != null 
          ? DateTime.parse(maps[0]['lastReadAt']) 
          : null,
    );
  }

  Future<bool> isBookLocallyModified(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'books',
      columns: ['isLocallyModified'],
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isEmpty) return false;
    return result.first['isLocallyModified'] == 1;
  }
} 