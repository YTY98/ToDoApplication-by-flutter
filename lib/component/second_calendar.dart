import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/colors.dart';

class SecondCalendar extends StatefulWidget {
  final OnDaySelected onDaySelected; // 날짜 선택 시 실행할 함수
  final DateTime selectedDate; // 선택된 날짜
  final VoidCallback onDropdownSelected; // 드롭다운 선택 시 실행할 함수
  final Function(DateTime) onHeaderTapped; // 헤더 클릭 시 실행할 함수

  SecondCalendar({
    required this.onDaySelected,
    required this.selectedDate,
    required this.onDropdownSelected,
    required this.onHeaderTapped,
  });

  @override
  _SecondCalendarState createState() => _SecondCalendarState();
}

class _SecondCalendarState extends State<SecondCalendar> {
  late Future<Map<String, List>> _diaryEvents;

  @override
  void initState() {
    super.initState();
    _diaryEvents = _fetchDiaryEvents();
  }

  Future<Map<String, List>> _fetchDiaryEvents() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      return {};
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('diary')
        .get();

    Map<String, List> events = {};
    for (var doc in snapshot.docs) {
      events[doc.id] = ['diary'];
    }

    return events;
  }

  Future<String?> getCurrentUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 상하좌우 여백을 16dp로 설정
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: FutureBuilder<Map<String, List>>(
          future: _diaryEvents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching events'));
            }

            final diaryEvents = snapshot.data ?? {};

            return Padding(
              padding: const EdgeInsets.all(0),
              child: TableCalendar(
                locale: 'ko_kr',
                firstDay: DateTime(2023, 1, 1),
                lastDay: DateTime(2100, 1, 1),
                focusedDay: widget.selectedDate,
                onDaySelected: widget.onDaySelected,
                selectedDayPredicate: (date) =>
                date.year == widget.selectedDate.year &&
                    date.month == widget.selectedDate.month &&
                    date.day == widget.selectedDate.day,
                eventLoader: (date) {
                  String formattedDate = DateFormat('yyyyMMdd').format(date);
                  return diaryEvents[formattedDate] ?? [];
                },
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMM(locale).format(date),
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                  decoration: BoxDecoration(
                    color: PURPLE_COLOR,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  headerMargin: EdgeInsets.zero,
                  headerPadding: EdgeInsets.zero, // 헤더 세로 늘리기
                ),
                daysOfWeekHeight: 30.0,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: DARK_GREY_COLOR,
                  ),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: DARK_GREY_COLOR,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  todayDecoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  weekendDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: PURPLE_COLOR,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  defaultTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  weekendTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                  selectedTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  outsideTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.transparent,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        top: -1,
                        right: -2,
                        child: Icon(
                          Icons.star,
                          color: paleGreen,
                          size: 20.0,
                        ),

                      );
                    }
                    return SizedBox.shrink();
                  },
                  headerTitleBuilder: (context, date) {
                    return GestureDetector(
                      onTap: () => widget.onHeaderTapped(date),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 48),
                          Text(
                            DateFormat.yMMMM('ko_kr').format(date),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.expand_more, color: Colors.white),
                            offset: Offset(0, 50),
                            onSelected: (value) {
                              if (value == '할 일 전환') {
                                widget.onDropdownSelected();
                              } else if (value == '일기 생성') {
                                generateDiary(context, date);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: '할 일 전환',
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text('할 일 전환'),
                                  ],
                                ),
                              ),
                              PopupMenuDivider(height: 1.0),
                              PopupMenuItem(
                                value: '일기 생성',
                                child: Row(
                                  children: [
                                    Icon(Icons.create, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text('일기 생성'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  todayBuilder: (context, date, _) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: PURPLE_COLOR, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, date, _) {
                    if (date.weekday == DateTime.saturday) {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    } else if (date.weekday == DateTime.sunday) {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> generateDiary(BuildContext context, DateTime date) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('일기 생성 중'),
          content: Text('일기가 생성되고 있습니다. 잠시만 기다려주세요.'),
        );
      },
    );

    try {
      final selectedDateStr = DateFormat('yyyyMMdd').format(date);
      final userId = await getCurrentUserId(); // Firestore에서 현재 로그인한 사용자 ID를 가져옴

      if (userId == null) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('일기 생성 실패'),
              content: Text('사용자 정보를 가져올 수 없습니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Firestore에서 일정 데이터를 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('schedule')
          .where('date', isEqualTo: selectedDateStr)
          .get();

      final completedSchedules = snapshot.docs
          .where((doc) => doc['finish'] == 1)
          .map((doc) => doc['content'])
          .toList();
      final uncompletedSchedules = snapshot.docs
          .where((doc) => doc['finish'] == 0)
          .map((doc) => doc['content'])
          .toList();

      if (completedSchedules.isEmpty) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('일기 생성 실패'),
              content: Text('완료된 일정이 없습니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('확인'),
                ),
              ],
            );
          },

        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://165.229.89.157:8080/generate-diary'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'date': selectedDateStr,
          'schedule_names': completedSchedules.join(', '),
          'uncompleted_schedule_names': uncompletedSchedules.join(', '),
        }),
      ).timeout(Duration(seconds: 40)); // 타임아웃 설정

      if (response.statusCode == 200) {
        final content = jsonDecode(response.body)['content'];

        // Firestore에 생성된 일기 저장
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('diary')
            .doc(selectedDateStr)
            .set({
          'date': selectedDateStr,
          'content': content,
          'schedule_id': snapshot.docs.first.id,
        });

        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('일기 생성 완료'),
              content: Text('일기가 성공적으로 생성되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to generate diary');
      }
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('일기 생성 실패'),
            content: Text('서버 응답 시간 초과: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('일기 생성 실패'),
            content: Text('네트워크 오류: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('일기 생성 실패'),
            content: Text('일기 생성 중 오류가 발생했습니다: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}
