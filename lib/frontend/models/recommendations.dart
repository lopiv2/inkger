class ItemRecommendation {
  final String title;
  final String description;
  final String? cover;
  final String? link;
  final String author;

  ItemRecommendation({
    required this.title,
    required this.description,
    this.cover,
    this.link,
    required this.author,
  });

  factory ItemRecommendation.fromJson(Map<String, dynamic> json, String author) {
    return ItemRecommendation(
      title: json['title'],
      description: json['description'],
      cover: json['cover'],
      author: author,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'cover': cover,
        'link': link,
        'author': author,
      };
}

class AuthorRecommendation {
  final String authorName;
  final String authorId;
  final List<ItemRecommendation> books;

  AuthorRecommendation({
    required this.authorName,
    required this.authorId,
    required this.books,
  });

  factory AuthorRecommendation.fromJson(Map<String, dynamic> json) {
  final authorName = json['authorName'];
  final books = (json['books'] as List)
      .map((bookJson) =>
          ItemRecommendation.fromJson(bookJson, authorName)) // ← pasa autor
      .toList();

  return AuthorRecommendation(
    authorName: authorName,
    authorId: json['authorId'],
    books: books,
  );
}

  Map<String, dynamic> toJson() => {
        'authorName': authorName,
        'authorId': authorId,
        'books': books.map((b) => b.toJson()).toList(),
      };
}
