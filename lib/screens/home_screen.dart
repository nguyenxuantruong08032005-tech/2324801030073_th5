
import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_storage_service.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteStorageService _storage = NoteStorageService();

  List<Note> _notes = [];
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Tải danh sách ghi chú
  Future<void> _loadNotes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final notes = await _storage.getNotes();

      if (!mounted) return;

      setState(() {
        _notes = notes;
      });
    } catch (error) {
      debugPrint('Lỗi tải ghi chú: $error');

      if (!mounted) return;

      setState(() {
        _loadError = 'Không thể tải danh sách ghi chú.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Thêm hoặc chỉnh sửa ghi chú
  Future<void> _openEditor([Note? note]) async {
    final bool? changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
        ),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await _loadNotes();

      if (mounted && _loadError == null) {
        _showMessage(
          note == null
              ? 'Thêm ghi chú thành công!'
              : 'Cập nhật ghi chú thành công!',
        );
      }
    }
  }

  // Hiển thị tùy chọn xóa
  Future<void> _showDeleteOptions(Note note) async {
    if (_isDeleting) return;

    final bool? selected = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              title: const Text(
                'Xóa ghi chú',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(note.title),
              onTap: () {
                Navigator.pop(sheetContext, true);
              },
            ),
          ),
        );
      },
    );

    if (selected == true && mounted) {
      await _confirmDelete(note);
    }
  }

  // Xác nhận trước khi xóa
  Future<void> _confirmDelete(Note note) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa ghi chú '
            '"${note.title}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted || _isDeleting) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _storage.deleteNote(note.id);

      if (!mounted) return;

      await _loadNotes();

      if (mounted && _loadError == null) {
        _showMessage('Đã xóa ghi chú thành công!');
      }
    } catch (error) {
      debugPrint('Lỗi xóa ghi chú: $error');

      _showMessage(
        'Không thể xóa ghi chú. Vui lòng thử lại.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // Banner trang chủ
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE3D7FC),
            Color(0xFFF3ECFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Không gian ghi chú của bạn',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF30234F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đang lưu giữ ${_notes.length} ghi chú. '
                  'Hãy ghi lại những điều quan trọng!',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF675580),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF9372CA),
            size: 39,
          ),
        ],
      ),
    );
  }

  // Giao diện khi chưa có ghi chú
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEEE6FC),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 65,
                color: Color(0xFF9A80CA),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Chưa có ghi chú nào',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF30264A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bắt đầu bằng ghi chú đầu tiên của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF898094),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Danh sách responsive
  Widget _buildNotesList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return RefreshIndicator(
            onRefresh: _loadNotes,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _notes.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 260,
              ),
              itemBuilder: (context, index) {
                final note = _notes[index];

                return NoteCard(
                  note: note,
                  onTap: () => _openEditor(note),
                  onLongPress: () => _showDeleteOptions(note),
                  onMorePressed: () => _showDeleteOptions(note),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadNotes,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: _notes.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 14);
            },
            itemBuilder: (context, index) {
              final note = _notes[index];

              return NoteCard(
                note: note,
                onTap: () => _openEditor(note),
                onLongPress: () => _showDeleteOptions(note),
                onMorePressed: () => _showDeleteOptions(note),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 12),
            Text(_loadError!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadNotes,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_notes.isEmpty) {
      return _buildEmptyState();
    }

    return _buildNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú cá nhân'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadNotes,
            tooltip: 'Làm mới danh sách',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 12, 16, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Danh sách ghi chú',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF30264A),
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE5FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_notes.length} ghi chú',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7056B1),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isDeleting ? null : () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm ghi chú',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
