class EpubChapter {
  final String id;
  final String title;
  final String content;

  EpubChapter({
    required this.id,
    required this.title,
    required this.content,
  });
}

class EpubBook {
  final String title;
  final List<EpubChapter> chapters;
  final String coverImagePath;

  EpubBook({
    required this.title,
    required this.chapters,
    required this.coverImagePath,
  });
}