class Event {
  final DateTime date;
  final String title;
  final String? description;
  final int? id;

  Event({this.id, required this.date, required this.title, this.description});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
    };
  }

  Event copyWith({String? title, DateTime? date, int? id, String? description}) {
    return Event(
      title: title ?? this.title,
      date: date ?? this.date,
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }
}
