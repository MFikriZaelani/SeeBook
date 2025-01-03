import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final List<String> _selectedGenres = [];
  final _bookService = BookService();

  // Daftar genre yang tersedia
  final List<String> _availableGenres = [
    'Novel', 'Fiksi', 'Non-Fiksi', 'Pendidikan',
    'Teknologi', 'Bisnis', 'Pengembangan Diri', 'Sains',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header dengan Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.library_books,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Buku Baru',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lengkapi informasi buku di bawah ini',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form Fields
          _buildFormField(
            controller: _titleController,
            label: 'Judul Buku',
            hint: 'Masukkan judul buku',
            icon: Icons.book,
            validator: (value) => value?.isEmpty ?? true ? 'Judul tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),

          _buildFormField(
            controller: _authorController,
            label: 'Penulis',
            hint: 'Masukkan nama penulis',
            icon: Icons.person,
            validator: (value) => value?.isEmpty ?? true ? 'Penulis tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),

          // Genre Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.category, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kategori',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[50],
                ),
                child: MultiSelectDialogField<String>(
                  items: _availableGenres
                      .map((genre) => MultiSelectItem<String>(genre, genre))
                      .toList(),
                  initialValue: _selectedGenres,
                  buttonText: const Text(
                    "Pilih Kategori",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  buttonIcon: const Icon(Icons.arrow_drop_down),
                  onConfirm: (values) {
                    setState(() {
                      _selectedGenres.clear();
                      _selectedGenres.addAll(values);
                    });
                  },
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  selectedItemsTextStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  selectedColor: Theme.of(context).primaryColor,
                  chipDisplay: MultiSelectChipDisplay(
                    onTap: (value) {
                      setState(() {
                        _selectedGenres.remove(value);
                      });
                    },
                    chipColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    textStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_selectedGenres.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Pilih minimal satu kategori',
                    style: TextStyle(
                      color: Colors.red[300],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          _buildFormField(
            controller: _imageUrlController,
            label: 'URL Cover',
            hint: 'Masukkan URL gambar cover buku',
            icon: Icons.image,
          ),
          const SizedBox(height: 16),

          _buildFormField(
            controller: _descriptionController,
            label: 'Deskripsi',
            hint: 'Masukkan deskripsi buku',
            icon: Icons.description,
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton.icon(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Buku'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: validator,
          maxLines: maxLines,
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final book = Book(
        id: DateTime.now().toString(),
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        coverImage: _imageUrlController.text.isEmpty 
            ? 'https://via.placeholder.com/150' 
            : _imageUrlController.text,
        genre: _selectedGenres,
        isRead: false,
      );
      _bookService.addBook(book);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buku berhasil ditambahkan')),
      );

      // Reset form
      _titleController.clear();
      _authorController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      setState(() {
        _selectedGenres.clear();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
} 