
class Note {
  final String id;
  final String title;
  final String content;

  // Ngày do người dùng lựa chọn trên lịch
  final DateTime noteDate;

  // Thời điểm tạo và cập nhật thực tế
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.noteDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'noteDate': noteDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(
      json['createdAt'] as String,
    );

    final rawNoteDate = json['noteDate'];
    final rawUpdatedAt = json['updatedAt'];

    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,

      // Tương thích với dữ liệu ghi chú cũ
      noteDate: rawNoteDate is String
          ? DateTime.tryParse(rawNoteDate) ?? createdAt
          : createdAt,

      createdAt: createdAt,

      updatedAt: rawUpdatedAt is String
          ? DateTime.tryParse(rawUpdatedAt) ?? createdAt
          : createdAt,
    );
  }
}
