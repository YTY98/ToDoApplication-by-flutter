// event.dart
class Event {
  final String title;
  final String date;
  final int startTime;
  final int endTime;

  Event({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Event.fromFirestore(Map<String, dynamic> data) {
    return Event(
      title: data['content'] ?? '',
      date: data['date'] ?? '',
      startTime: data['startTime'] ?? 0,
      endTime: data['endTime'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  @override
  String toString() => title;
}
