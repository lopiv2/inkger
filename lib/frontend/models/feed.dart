class Feed {
  int? id;
  String name;
  String logo;
  String url;
  String category;
  bool active;
  int? userId;

  Feed({
    this.id,
    required this.name,
    required this.logo,
    required this.url,
    required this.category,
    required this.active,
    this.userId,
  });

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'],
      name: map['name'] ?? '',
      logo: map['logo'] ?? '',
      url: map['url'] ?? '',
      category: map['category'] ?? '',
      active: map['active'] ?? true,
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'url': url,
      'category': category,
      'active': active,
      'userId': userId,
    };
  }
}
