class FeedItem {
  final String title;
  final String description;
  final String link;
  final String? pubDate;
  final String? sourceUrl;
  final String? sourceName;

  FeedItem({
    required this.title,
    required this.description,
    required this.link,
    this.pubDate,
    this.sourceUrl,
    this.sourceName,
  });

  factory FeedItem.fromMap(Map<String, dynamic> map) {
    return FeedItem(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      link: map['link'] ?? '',
      pubDate: map['pubDate'],
    );
  }

  FeedItem copyWith({String? sourceUrl, String? sourceName}) {
    return FeedItem(
      title: title,
      description: description,
      link: link,
      pubDate: pubDate,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceName: sourceName ?? this.sourceName,
    );
  }
}
