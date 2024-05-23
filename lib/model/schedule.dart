// schedule.dart
import 'package:drift/drift.dart';

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()(); // PRIMARY KEY, 정수 열
  TextColumn get content => text()();       // 내용, 글자 열
  DateTimeColumn get date => dateTime()();  // 일정 날짜, 날짜 열
  IntColumn get startTime => integer()();   // 시작 시간
  IntColumn get endTime => integer()();     // 종료 시간
  IntColumn get separator => integer()();   // 구분자
  IntColumn get priority => integer()();    // 중요도
  IntColumn get finish => integer()();
  RealColumn get latitude => real().nullable()();  // 위도
  RealColumn get longitude => real().nullable()(); // 경도
  TextColumn get locationName => text()(); // 일정 장소 이름
}
