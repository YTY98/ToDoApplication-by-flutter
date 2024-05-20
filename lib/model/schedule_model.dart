// schedule_model.dart
class ScheduleModel {
  final String id;
  final String content;
  final DateTime date;
  final int startTime;
  final int endTime;
  final int separator;
  final int priority;  // 중요도 필드 추가

  ScheduleModel({
    required this.id,
    required this.content,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.separator,
    required this.priority,  // 중요도 필드 초기화
  });

  ScheduleModel.fromJson({
    required Map<String, dynamic> json,
  })  : id = json['id'],
        content = json['content'],
        date = DateTime.parse(json['date']),
        startTime = json['startTime'],
        endTime = json['endTime'],
        separator = json['separator'],
        priority = json['priority'];  // JSON에서 중요도 필드 파싱

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date': '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      'startTime': startTime,
      'endTime': endTime,
      'separator': separator,
      'priority': priority,  // JSON에 중요도 필드 추가
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? content,
    DateTime? date,
    int? startTime,
    int? endTime,
    int? separator,
    int? priority,  // copyWith에서 중요도 필드 처리
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      separator: separator?? this.separator,
      priority: priority ?? this.priority,  // 중요도 필드 복사
    );
  }
}
