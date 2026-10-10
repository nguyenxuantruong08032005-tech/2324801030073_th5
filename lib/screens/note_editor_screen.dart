
import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_storage_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() =>
      _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final NoteStorageService _storage = NoteStorageService();

  late DateTime _selectedNoteDate;
  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedNoteDate = widget.note!.noteDate;
    } else {
      _selectedNoteDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  // Mở lịch chọn ngày/tháng/năm
  Future<void> _pickNoteDate() async {
    if (_isSaving) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedNoteDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),

      // Chỉ sử dụng lịch, không yêu cầu nhập tay
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.day,

      helpText: 'CHỌN NGÀY GHI CHÚ',
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedNoteDate = picked;
      });
    }
  }

  // Lưu hoặc cập nhật ghi chú
  Future<void> _saveNote() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();

      final note = Note(
        id: widget.note?.id ??
            now.microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        noteDate: DateTime(
          _selectedNoteDate.year,
          _selectedNoteDate.month,
          _selectedNoteDate.day,
        ),
        createdAt: widget.note?.createdAt ?? now,
        updatedAt: now,
      );

      await _storage.saveNote(note);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      debugPrint('Lỗi lưu ghi chú: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể lưu ghi chú. Vui lòng thử lại.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF312947),
        ),
      ),
    );
  }

  // Ô chọn ngày có biểu tượng lịch
  Widget _buildDatePickerField() {
    return InkWell(
      onTap: _isSaving ? null : _pickNoteDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5DFF0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF7056B1),
                size: 23,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ngày đã chọn',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF827B91),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_selectedNoteDate),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF312947),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF7056B1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú',
        ),
      ),

      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18, 16, 18, 30,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề hướng dẫn
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECE4FB),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            size: 38,
                            color: Color(0xFF7056B1),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEditing
                                      ? 'Cập nhật ý tưởng'
                                      : 'Ghi lại ý tưởng mới',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF312947),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Lưu giữ những điều quan trọng với bạn.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6F6585),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Tiêu đề ghi chú
                    _buildSectionLabel('Tiêu đề ghi chú'),

                    TextFormField(
                      controller: _titleController,
                      maxLength: 100,
                      textCapitalization:
                          TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tiêu đề ghi chú...',
                        prefixIcon: Icon(
                          Icons.title_rounded,
                          color: Color(0xFF7056B1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tiêu đề ghi chú';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Chọn ngày ghi chú
                    _buildSectionLabel('Ngày thực hiện ghi chú'),

                    _buildDatePickerField(),

                    const SizedBox(height: 8),

                    const Text(
                      'Nhấn vào ô trên để mở lịch chọn ngày, tháng, năm.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF827B91),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Nội dung ghi chú
                    _buildSectionLabel('Nội dung ghi chú'),

                    TextFormField(
                      controller: _contentController,
                      minLines: 7,
                      maxLines: 12,
                      keyboardType: TextInputType.multiline,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText:
                            'Hôm nay bạn muốn ghi lại điều gì?',
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveNote,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save_outlined,
                              ),
                        label: Text(
                          _isSaving
                              ? 'Đang lưu...'
                              : _isEditing
                                  ? 'Cập nhật ghi chú'
                                  : 'Lưu ghi chú',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
