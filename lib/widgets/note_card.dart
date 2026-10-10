
import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMorePressed;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    required this.onMorePressed,
  });

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.hour)}:${two(date.minute)} '
        '${_formatDate(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFEAE5F2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAFE),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.sticky_note_2_outlined,
                      color: Color(0xFF7056B1),
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF28213C),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: onMorePressed,
                    tooltip: 'Tùy chọn ghi chú',
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF80788C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                note.content.trim().isEmpty
                    ? 'Ghi chú chưa có nội dung.'
                    : note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF6F697B),
                ),
              ),

              const SizedBox(height: 14),

              const Divider(
                color: Color(0xFFF0ECF5),
                height: 1,
              ),

              const SizedBox(height: 13),

              Wrap(
                spacing: 8,
                runSpacing: 9,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Color(0xFF7056B1),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          _formatDate(note.noteDate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7056B1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF938A9F),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Tạo: ${_formatDateTime(note.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF80788C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
