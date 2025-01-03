class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImage;
  final List<String> genre;
  bool isRead;
  int readTimeInMinutes;
  DateTime? lastReadAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    required this.genre,
    this.isRead = false,
    this.readTimeInMinutes = 0,
    this.lastReadAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverImage': coverImage,
      'genre': genre,
      'isRead': isRead,
      'readTimeInMinutes': readTimeInMinutes,
      'lastReadAt': lastReadAt?.toIso8601String(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['primary_isbn13'] ?? json['primary_isbn10'] ?? DateTime.now().toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['book_image'] ?? '',
      genre: [json['publisher'] ?? ''],
      isRead: false,
      readTimeInMinutes: 0,
    );
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      description: map['description'],
      coverImage: map['coverImage'],
      genre: List<String>.from(map['genre']),
      isRead: map['isRead'] ?? false,
      readTimeInMinutes: map['readTimeInMinutes'] ?? 0,
      lastReadAt: map['lastReadAt'] != null ? DateTime.parse(map['lastReadAt']) : null,
    );
  }
} 