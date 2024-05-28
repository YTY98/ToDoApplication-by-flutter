// // schedule_model.dart
// class ScheduleModel {
//   final String id;
//   final String content;
//   final DateTime date;
//   final int startTime;
//   final int endTime;
//   final int separator;
//   final int priority;  // 중요도 필드 추가
//   final int finish;
//   final double? latitude;
//   final double? longitude;
//   final String locationName;
//
//   ScheduleModel({
//     required this.id,
//     required this.content,
//     required this.date,
//     required this.startTime,
//     required this.endTime,
//     required this.separator,
//     required this.priority,  // 중요도 필드 초기화
//     required this.finish,
//     this.latitude,
//     this.longitude,
//     required this.locationName,
//   });
//
//   ScheduleModel.fromJson({
//     required Map<String, dynamic> json,
//   })  : id = json['id'],
//         content = json['content'],
//         date = DateTime.parse(json['date']),
//         startTime = json['startTime'],
//         endTime = json['endTime'],
//         separator = json['separator'],
//         priority = json['priority'],
//         finish = json['finish'],
//         latitude = json['latitude'],
//         longitude = json['longitude'],
//         locationName = json['locationName'];
//
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'content': content,
//       'date': '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
//       'startTime': startTime,
//       'endTime': endTime,
//       'separator': separator,
//       'priority': priority,
//       'finish' : finish,
//       'latitude': latitude,
//       'longitude': longitude,
//       'locationName' : locationName,
//     };
//   }
//
//
//   ScheduleModel copyWith({
//     String? id,
//     String? content,
//     DateTime? date,
//     int? startTime,
//     int? endTime,
//     int? separator,
//     int? priority,
//     int? finish,
//     double? latitude, // 위도 필드 복사
//     double? longitude, // 경도 필드 복사
//     String? locationName,
//   }) {
//     return ScheduleModel(
//       id: id ?? this.id,
//       content: content ?? this.content,
//       date: date ?? this.date,
//       startTime: startTime ?? this.startTime,
//       endTime: endTime ?? this.endTime,
//       separator: separator?? this.separator,
//       priority: priority ?? this.priority,  // 중요도 필드 복사
//       finish: finish ?? this.finish,
//       latitude: latitude ?? this.latitude, // 위도 필드 복사
//       longitude: longitude ?? this.longitude, // 경도 필드 복사
//       locationName: locationName ?? this.locationName,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String content;
  final DateTime date;
  final int startTime;
  final int endTime;
  final int separator;
  final int priority;
  final int finish;
  final double? latitude;
  final double? longitude;
  final String locationName;


  ScheduleModel({
    required this.id,
    required this.content,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.separator,
    required this.priority,
    required this.finish,
    this.latitude,
    this.longitude,
    required this.locationName,
  });

  ScheduleModel.fromJson({
    required Map<String, dynamic> json,
  })  : id = json['id'],
        content = json['content'],
        date = DateTime.parse(json['date']),
        startTime = json['startTime'],
        endTime = json['endTime'],
        separator = json['separator'],
        priority = json['priority'],
        finish = json['finish'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        locationName = json['locationName'];


  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ScheduleModel(
      id: doc.id,
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? 0,
      endTime: data['endTime'] ?? 0,
      separator: data['separator'] ?? 0,
      priority: data['priority'] ?? 0,
      finish: data['finish'] ?? 0,
      latitude: data['latitude'],
      longitude: data['longitude'],
      locationName: data['locationName'] ?? '',

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date': '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      'startTime': startTime,
      'endTime': endTime,
      'separator': separator,
      'priority': priority,
      'finish': finish,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,

    };
  }

  ScheduleModel copyWith({
    String? id,
    String? content,
    DateTime? date,
    int? startTime,
    int? endTime,
    int? separator,
    int? priority,
    int? finish,
    double? latitude,
    double? longitude,
    String? locationName,

  }) {
    return ScheduleModel(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      separator: separator ?? this.separator,
      priority: priority ?? this.priority,
      finish: finish ?? this.finish,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,

    );
  }
}
