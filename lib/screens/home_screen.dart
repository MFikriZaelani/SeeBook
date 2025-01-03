import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../widgets/book_list_item.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';
import '../widgets/book_search_delegate.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'Semua';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final fetchedBooks = await _bookService.fetchBooks();
      setState(() {
        _books = fetchedBooks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBooks() async {
    try {
      final fetchedBooks = await _bookService.refreshFromApi();
      if (mounted) {
        setState(() {
          _books = fetchedBooks;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<String> get _categories {
    final Set<String> categories = {'Semua'};
    for (var book in _books) {
      categories.addAll(book.genre);
    }
    return categories.toList()..sort();
  }

  List<Book> get _filteredBooks {
    if (_selectedCategory == 'Semua') return _books;
    return _books.where((book) => book.genre.contains(_selectedCategory)).toList();
  }

  Future<void> _openBookDetail(Book book) async {
    final bool? wasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(
          book: book,
          bookService: _bookService,
        ),
      ),
    );

    if (wasUpdated == true && mounted) {
      final updatedBooks = await _bookService.getAllBooks();
      setState(() {
        _books = updatedBooks;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perpustakaan Digital',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
            Text(
              '${_books.length} buku tersedia',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _selectedIndex == 0 
          ? (_isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
                  ? _buildErrorWidget()
                  : RefreshIndicator(
                      onRefresh: _refreshBooks,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Stats Cards
                          SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Row(
                                children: [
                                  // Total Buku Card
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Color(0xFF6B8AF2), Color(0xFF4267B2)],
                                          stops: [0.0, 1.0],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4267B2).withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.menu_book, color: Colors.white, size: 18),
                                          ),
                                          const SizedBox(width: 6),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Total Buku',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              Text(
                                                _books.length.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Status Baca Card dengan Pie Chart
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.08),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.grey.shade100,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Pie Chart dengan container
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: SizedBox(
                                              height: 42,
                                              width: 42,
                                              child: PieChart(
                                                PieChartData(
                                                  sectionsSpace: 2,
                                                  centerSpaceRadius: 8,
                                                  sections: [
                                                    PieChartSectionData(
                                                      value: _books.where((b) => b.isRead).length.toDouble(),
                                                      color: const Color(0xFF4CAF50),
                                                      radius: 15,
                                                      showTitle: false,
                                                    ),
                                                    PieChartSectionData(
                                                      value: _books.where((b) => !b.isRead).length.toDouble(),
                                                      color: const Color(0xFFFF9800),
                                                      radius: 15,
                                                      showTitle: false,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Legend dengan styling baru
                                          Expanded(
                  child: Column(
                                              mainAxisSize: MainAxisSize.min,
                    children: [
                                                _buildPrettyLegendItem(
                                                  'Sudah Dibaca',
                                                  const Color(0xFF4CAF50),
                                                  _books.where((b) => b.isRead).length.toString(),
                                                ),
                                                const SizedBox(height: 4),
                                                _buildPrettyLegendItem(
                                                  'Belum Dibaca',
                                                  const Color(0xFFFF9800),
                                                  _books.where((b) => !b.isRead).length.toString(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                      ),
                    ],
                  ),
                            ),
                          ),
                    // Category Filter
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _CategoryFilterDelegate(
                              categories: _categories,
                              selectedCategory: _selectedCategory,
                              onCategorySelected: (category) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                      ),
                    ),
                    // Book List
                          SliverPadding(
                        padding: const EdgeInsets.only(bottom: 80),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                          final book = _filteredBooks[index];
                          return BookListItem(
                                    book: book,
                                    onTap: () => _openBookDetail(book),
                                  );
                                },
                                childCount: _filteredBooks.length,
                              ),
                      ),
                    ),
                  ],
                ),
                    ))
          : const AddBookScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            height: 70,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Colors.purple.withOpacity(0.1),
            indicatorShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            destinations: [
              NavigationDestination(
                icon: const SizedBox(
                  width: 30,
                  child: Icon(Icons.home_outlined, size: 24),
                ),
                selectedIcon: const SizedBox(
                  width: 30,
                  child: Icon(Icons.home, size: 24, color: Colors.purple),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: const SizedBox(
                  width: 30,
                  child: Icon(Icons.search, size: 24),
                ),
                selectedIcon: const SizedBox(
                  width: 30,
                  child: Icon(Icons.search, size: 24, color: Colors.purple),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: const SizedBox(
                  width: 30,
                  child: Icon(Icons.add_outlined, size: 24),
                ),
                selectedIcon: const SizedBox(
                  width: 30,
                  child: Icon(Icons.add, size: 24, color: Colors.purple),
                ),
                label: '',
              ),
            ],
            onDestinationSelected: (index) async {
              if (index == 1) {
                showSearch(
                  context: context,
                  delegate: BookSearchDelegate(
                    books: _books,
                    bookService: _bookService,
                    onBookUpdated: () async {
                      final updatedBooks = await _bookService.getAllBooks();
                      setState(() {
                        _books = updatedBooks;
                      });
                    },
                  ),
                );
                setState(() {
                  _selectedIndex = _selectedIndex;
                });
              } else {
                setState(() {
                  _selectedIndex = index == 2 ? 2 : 0;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Colors.red[300])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadBooks,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrettyLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                label,
                  style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.8),
                  ),
                ),
            ),
          ],
        ),
      ),
      ],
    );
  }
}

class _CategoryFilterDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  _CategoryFilterDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (0.02 * value),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [
                                Theme.of(context).primaryColor.withOpacity(0.8),
                                Theme.of(context).primaryColor,
                              ]
                            : [Colors.white, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          blurRadius: 6 * value,
                          offset: Offset(0, 3 * value),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isSelected) {
                            onCategorySelected('Semua');
                          } else {
                            onCategorySelected(category);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontSize: 13 + (0.5 * value),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
} 