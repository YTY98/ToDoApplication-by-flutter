// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import '../const/colors.dart';
// import 'package:intl/intl.dart';
// import 'main_screen.dart';
//
// class SecondCalendar extends StatelessWidget {
//   final OnDaySelected onDaySelected; // 날짜 선택 시 실행할 함수
//   final DateTime selectedDate; // 선택된 날짜
//   final VoidCallback onDropdownSelected; // 드롭다운 선택 시 실행할 함수
//
//   SecondCalendar({
//     required this.onDaySelected,
//     required this.selectedDate,
//     required this.onDropdownSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0), // 상하좌우 여백을 16dp로 설정
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(0),
//           child: TableCalendar(
//             locale: 'ko_kr',
//             firstDay: DateTime(2023, 1, 1),
//             lastDay: DateTime(2100, 1, 1),
//             focusedDay: selectedDate,
//             onDaySelected: onDaySelected,
//             selectedDayPredicate: (date) =>
//             date.year == selectedDate.year &&
//                 date.month == selectedDate.month &&
//                 date.day == selectedDate.day,
//             headerStyle: HeaderStyle(
//               titleCentered: true,
//               formatButtonVisible: false,
//               titleTextFormatter: (date, locale) =>
//                   DateFormat.yMMMM(locale).format(date),
//               titleTextStyle: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 fontSize: 16.0,
//                 color: Colors.white,
//               ),
//               leftChevronVisible: false,
//               rightChevronVisible: false,
//               decoration: BoxDecoration(
//                 color: Colors.teal,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//               ),
//               headerMargin: EdgeInsets.zero,
//               headerPadding: EdgeInsets.zero, // 헤더 세로 늘리기
//             ),
//             daysOfWeekHeight: 30.0,
//             daysOfWeekStyle: DaysOfWeekStyle(
//               weekdayStyle: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: DARK_GREY_COLOR,
//               ),
//               weekendStyle: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: DARK_GREY_COLOR,
//               ),
//             ),
//             calendarStyle: CalendarStyle(
//               isTodayHighlighted: true,
//               todayDecoration: BoxDecoration(
//                 color: Colors.teal,
//                 shape: BoxShape.circle,
//               ),
//               todayTextStyle: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               defaultDecoration: BoxDecoration(
//                 shape: BoxShape.circle,
//               ),
//               weekendDecoration: BoxDecoration(
//                 shape: BoxShape.circle,
//               ),
//               selectedDecoration: BoxDecoration(
//                 color: Colors.teal,
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.circular(5.0),
//               ),
//               defaultTextStyle: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//               weekendTextStyle: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue,
//               ),
//               selectedTextStyle: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//               outsideTextStyle: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.transparent,
//               ),
//             ),
//             calendarBuilders: CalendarBuilders(
//               headerTitleBuilder: (context, date) {
//                 return GestureDetector(
//                   onTap: () => onDropdownSelected(),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(width: 48),
//                       Text(
//                         DateFormat.yMMMM('ko_kr').format(date),
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16.0,
//                           color: Colors.white,
//                         ),
//                       ),
//                       PopupMenuButton<String>(
//                         icon: Icon(Icons.expand_more, color: Colors.white),
//                         offset: Offset(0, 50),
//                         onSelected: (value) {
//                           if (value == '할 일 전환') {
//                             onDropdownSelected();
//                           }
//                         },
//                         itemBuilder: (context) => [
//                           PopupMenuItem(
//                             value: '할 일 전환',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.calendar_month, color: Colors.black),
//                                 SizedBox(width: 8),
//                                 Text('할 일 전환'),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               todayBuilder: (context, date, _) {
//                 return Container(
//                   margin: const EdgeInsets.all(8.0),
//                   decoration: BoxDecoration(
//                     color: Colors.transparent,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.teal, width: 1.5),
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(
//                     '${date.day}',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 );
//               },
//               defaultBuilder: (context, date, _) {
//                 if (date.weekday == DateTime.saturday) {
//                   return Container(
//                     margin: const EdgeInsets.all(6.0),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.rectangle,
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                     child: Text(
//                       '${date.day}',
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   );
//                 } else if (date.weekday == DateTime.sunday) {
//                   return Container(
//                     margin: const EdgeInsets.all(6.0),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.rectangle,
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                     child: Text(
//                       '${date.day}',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   );
//                 } else {
//                   return Container(
//                     margin: const EdgeInsets.all(6.0),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.rectangle,
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                     child: Text(
//                       '${date.day}',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class DairyScreen extends StatefulWidget {
//   const DairyScreen({Key? key}) : super(key: key);
//
//   @override
//   State<DairyScreen> createState() => _DairyScreenState();
// }
//
// class _DairyScreenState extends State<DairyScreen> {
//   DateTime selectedDate = DateTime.utc(
//     DateTime.now().year,
//     DateTime.now().month,
//     DateTime.now().day,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showWelcomeMessage();
//     });
//   }
//
//   void _showWelcomeMessage() {
//     final overlay = Overlay.of(context);
//     final overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: 50.0,
//         left: MediaQuery.of(context).size.width * 0.1,
//         width: MediaQuery.of(context).size.width * 0.8,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             child: Text(
//               "일기를 확인하는 공간입니다.\n날짜를 눌러 일기를 확인하세요.",
//               style: TextStyle(color: Colors.white, fontSize: 16.0),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     );
//
//     overlay.insert(overlayEntry);
//
//     Future.delayed(Duration(seconds: 4), () {
//       overlayEntry.remove();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             SecondCalendar(
//               selectedDate: selectedDate,
//               onDaySelected: onDaySelected,
//               onDropdownSelected: _onDropdownSelected,
//             ),
//             Expanded(
//               child: Container(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
//     setState(() {
//       this.selectedDate = selectedDate;
//     });
//
//     // 날짜 클릭 시 팝업 창 띄우기
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('선택한 날짜'),
//         content: Text(
//           '선택된 날짜는 ${DateFormat.yMMMMd('ko_kr').format(selectedDate)} 입니다.',
//         ),
//         actions: [
//           TextButton(
//             child: Text('확인'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _onDropdownSelected() {
//     // 드롭다운 메뉴 선택 시 실행할 로직을 여기에 작성합니다.
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("할 일 전환"),
//           content: Text("기본 화면으로 전환하시겠습니까?"),
//           actions: [
//             TextButton(
//               child: Text("취소"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text("확인"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(builder: (context) => MainScreen()),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

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
import 'main_screen.dart';

class SecondCalendar extends StatelessWidget {
  final OnDaySelected onDaySelected; // 날짜 선택 시 실행할 함수
  final DateTime selectedDate; // 선택된 날짜
  final VoidCallback onDropdownSelected; // 드롭다운 선택 시 실행할 함수

  SecondCalendar({
    required this.onDaySelected,
    required this.selectedDate,
    required this.onDropdownSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 상하좌우 여백을 16dp로 설정
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: TableCalendar(
            locale: 'ko_kr',
            firstDay: DateTime(2023, 1, 1),
            lastDay: DateTime(2100, 1, 1),
            focusedDay: selectedDate,
            onDaySelected: onDaySelected,
            selectedDayPredicate: (date) =>
            date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day,
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
                color: Colors.teal,
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
                color: Colors.teal,
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
              headerTitleBuilder: (context, date) {
                return GestureDetector(
                  onTap: () => onDropdownSelected(),
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
                            onDropdownSelected();
                          } else if (value == '일기 생성') {
                            generateDairy(context, date);
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
                    border: Border.all(color: Colors.teal, width: 1.5),
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
        ),
      ),
    );
  }

  Future<void> generateDairy(BuildContext context, DateTime date) async {
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
        Uri.parse('http://165.229.89.157:8080/generate-dairy'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'date': selectedDateStr,
          'schedule_names': completedSchedules.join(', '),
          'uncompleted_schedule_names': uncompletedSchedules.join(', '),
        }),
      ).timeout(Duration(seconds: 30)); // 타임아웃 설정

      if (response.statusCode == 200) {
        final content = jsonDecode(response.body)['content'];

        // Firestore에 생성된 일기 저장
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('dairy')
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
        throw Exception('Failed to generate dairy');
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

  Future<String?> getCurrentUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}

class DairyScreen extends StatefulWidget {
  const DairyScreen({Key? key}) : super(key: key);

  @override
  State<DairyScreen> createState() => _DairyScreenState();
}

class _DairyScreenState extends State<DairyScreen> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeMessage();
    });
  }

  void _showWelcomeMessage() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              "일기를 확인하는 공간입니다.\n날짜를 눌러 일기를 확인하세요.",
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SecondCalendar(
              selectedDate: selectedDate,
              onDaySelected: onDaySelected,
              onDropdownSelected: _onDropdownSelected,
            ),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) async {
    setState(() {
      this.selectedDate = selectedDate;
    });

    final selectedDateStr = DateFormat('yyyyMMdd').format(selectedDate);
    final userId = await getCurrentUserId(); // Firestore에서 현재 로그인한 사용자 ID를 가져옴

    if (userId == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('일기 조회 실패'),
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

    // Firestore에서 해당 날짜의 일기를 가져오기
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dairy')
        .doc(selectedDateStr)
        .get();

    if (docSnapshot.exists) {
      final content = docSnapshot.data()?['content'] ?? '일기가 없습니다.';
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('작성된 일기'),
            content: Text(content),
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
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('작성된 일기 없음'),
            content: Text('선택한 날짜에 작성된 일기가 없습니다.'),
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

  Future<String?> getCurrentUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  void _onDropdownSelected() {
    // 드롭다운 메뉴 선택 시 실행할 로직을 여기에 작성합니다.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("할 일 전환"),
          content: Text("기본 화면으로 전환하시겠습니까?"),
          actions: [
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
