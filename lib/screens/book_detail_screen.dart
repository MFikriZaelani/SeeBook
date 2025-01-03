import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'dart:ui'; // Untuk BackdropFilter
import 'dart:async'; // Untuk Timer
import 'package:intl/intl.dart'; // Untuk DateFormat
import '../screens/edit_book_screen.dart';
// Untuk DateFormat

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final BookService bookService;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.bookService,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book currentBook;
  final ScrollController _scrollController = ScrollController();
  Timer? _readingTimer;
  int _elapsedMinutes = 0;
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    currentBook = widget.book;
    _elapsedMinutes = currentBook.readTimeInMinutes;
  }

  @override
  void dispose() {
    if (_isReading) {
      _stopReading();
    }
    super.dispose();
  }

  void _toggleReading() {
    setState(() {
      _isReading = !_isReading;
      if (_isReading) {
        _startReading();
      } else {
        _stopReading();
      }
    });
  }

  void _startReading() {
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedMinutes++;
      });
    });
  }

  void _stopReading() {
    if (_readingTimer != null) {
      _readingTimer!.cancel();
      setState(() {
        _isReading = false;
        currentBook.readTimeInMinutes = _elapsedMinutes;
        currentBook.lastReadAt = DateTime.now();
      });
      widget.bookService.updateBook(currentBook);
    }
  }

  String _formatReadTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(remainingSeconds)}';
  }

  void _toggleReadStatus() async {
    if (_isReading) {
      _stopReading();
    }
    setState(() {
      currentBook.isRead = !currentBook.isRead;
      if (currentBook.isRead) {
        _stopReading();
      }
    });
    await widget.bookService.updateBook(currentBook);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _resetTimer() {
    setState(() {
      _elapsedMinutes = 0;
      currentBook.readTimeInMinutes = 0;
      currentBook.lastReadAt = null;
    });
    widget.bookService.updateBook(currentBook);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, 
                color: Colors.red[400],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('Hapus Buku'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apakah Anda yakin ingin menghapus buku "${currentBook.title}"?'),
              const SizedBox(height: 8),
              Text(
                'Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                try {
                  await widget.bookService.deleteBook(currentBook.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Buku berhasil dihapus'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context, true); // Kembali ke halaman sebelumnya
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus buku: ${e.toString()}'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar dengan gambar cover
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image dengan blur background
                  Hero(
                    tag: 'book-${currentBook.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Blurred background
                        Image.network(
                          currentBook.coverImage,
                          fit: BoxFit.cover,
                        ),
                        // Blur overlay
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        // Centered cover image
            Center(
              child: Container(
                            height: 200,
                            width: 140,
                decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                currentBook.coverImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.6, 1.0],
                ),
              ),
            ),
                  // Title and Author overlay at bottom
                  Positioned(
                    bottom: 20,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
            Text(
              currentBook.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
            Text(
                          'oleh ${currentBook.author}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Add back button
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBookScreen(
                        book: currentBook,
                        bookService: widget.bookService,
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    final updatedBook = await widget.bookService.getBookById(currentBook.id);
                    if (updatedBook != null) {
                      setState(() {
                        currentBook = updatedBook;
                      });
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => _showDeleteConfirmation(context),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Kategori dan Status Baca
                      Row(
                        children: [
                          // Kategori (sebelah kiri)
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.category, color: Colors.blue.shade700, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Kategori',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: currentBook.genre.map((genre) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.shade100.withOpacity(0.2),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        genre,
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Baca (sebelah kanan)
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: currentBook.isRead 
                                      ? [Colors.green.shade50, Colors.green.shade100]
                                      : [Colors.orange.shade50, Colors.orange.shade100],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (currentBook.isRead ? Colors.green : Colors.orange).withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    currentBook.isRead ? Icons.check_circle : Icons.schedule,
                                    color: currentBook.isRead ? Colors.green : Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentBook.isRead ? 'Sudah Dibaca' : 'Belum Dibaca',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: currentBook.isRead ? Colors.green.shade700 : Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Timer Card
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _isReading ? Colors.purple.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isReading ? Colors.purple.shade200 : Colors.grey.shade200,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Ikon Timer
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _isReading 
                                    ? Colors.purple.withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.timer,
                                color: _isReading ? Colors.purple : Colors.grey.shade700,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Waktu dan Status
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Baris pertama: Label dan Status
                                  Row(
                                    children: [
                                      Text(
                                        'Waktu Baca',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _isReading ? Colors.purple : Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isReading 
                                              ? Colors.purple.withOpacity(0.1)
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _isReading ? 'Sedang Membaca' : 'Tidak Aktif',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: _isReading ? Colors.purple : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Baris kedua: Timer dan Tombol Reset
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatReadTime(_elapsedMinutes),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'monospace',
                                          color: _isReading ? Colors.purple : Colors.grey.shade700,
                                        ),
                                      ),
                                      if (!_isReading && _elapsedMinutes > 0)
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Reset Waktu Baca'),
                                                content: const Text('Apakah Anda yakin ingin mereset waktu baca?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _resetTimer();
                                                    },
                                                    child: const Text('Reset'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Icon(
                                              Icons.refresh,
                                              size: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (currentBook.lastReadAt != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Terakhir: ${DateFormat('dd MMM, HH:mm').format(currentBook.lastReadAt!)}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey.shade500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

            const SizedBox(height: 16),

                      // Deskripsi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description, color: Colors.grey.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(
              'Deskripsi',
              style: TextStyle(
                                    fontSize: 16,
                fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentBook.description,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // Kurangi space untuk FAB
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol Mulai/Berhenti Baca
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: 'readButton',
                onPressed: _toggleReading,
                backgroundColor: _isReading 
                    ? const Color(0xFFFF5252)  // Merah yang lebih soft
                    : const Color(0xFF9C27B0),  // Ungu yang lebih soft
                elevation: 4,
                label: Row(
                  children: [
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isReading ? 0.25 : 0,
                      child: Icon(
                        _isReading ? Icons.stop : Icons.play_arrow_rounded,
                        size: 20,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isReading ? 'Berhenti' : 'Mulai Baca',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Tombol Tandai Sudah/Belum Dibaca
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: 'statusButton',
                onPressed: _toggleReadStatus,
                backgroundColor: currentBook.isRead 
                    ? const Color(0xFFFF9800)  // Orange yang lebih soft
                    : const Color(0xFF2196F3),  // Biru yang lebih soft
                elevation: 4,
                label: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                  currentBook.isRead
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        key: ValueKey(currentBook.isRead),
                        size: 20,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentBook.isRead ? 'Belum Selesai' : 'Sudah Dibaca',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
} 