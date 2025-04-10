class EpubChapter {
  final String id;
  final String title;
  final String content;

  EpubChapter({required this.id, required this.title, required this.content});
}

class NavPoint {
  final String id;
  final String label;
  final String contentSrc;
  final int playOrder;
  List<NavPoint> children;

  NavPoint({
    required this.id,
    required this.label,
    required this.contentSrc,
    required this.playOrder,
    this.children = const [],
  });

  @override
  String toString({int indent = 0}) {
    String prefix = '  ' * indent;
    String childrenStr =
        children.isNotEmpty
            ? '\n${children.map((c) => c.toString(indent: indent + 1)).join('\n')}'
            : '';
    return '${prefix}NavPoint(id: $id, label: "$label", playOrder: $playOrder, src: "$contentSrc")$childrenStr';
  }
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
