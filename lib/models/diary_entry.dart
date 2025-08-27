class DiaryEntry {
  final int id;
  final DateTime date;
  final String title;
  final String content;
  final List<String> tags;
  final List<String> attachedImages;
  final List<String> attachedAudios;
  final bool isFavorite;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.tags,
    required this.attachedImages,
    required this.attachedAudios,
    required this.isFavorite,
  });

  String get contentPreview {
    if (content.length <= 100) {
      return content;
    }
    return '${content.substring(0, 100)}...';
  }
}
