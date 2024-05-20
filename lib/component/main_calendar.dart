// main_calendar.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../const/colors.dart';
import '../model/event.dart';

class MainCalendar extends StatefulWidget {
  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final Map<String, List<Event>> events;
  final Function(DateTime) onHeaderTapped;
  final Function() onListButtonTapped; // List 버튼 클릭 시 호출될 함수

  MainCalendar({
    required this.onDaySelected,
    required this.selectedDate,
    required this.events,
    required this.onHeaderTapped,
    required this.onListButtonTapped, // 생성자에 추가
  });

  @override
  _MainCalendarState createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _calendarToggleCount = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0), // 패딩 제거
        child: TableCalendar(
          locale: 'ko_kr',
          firstDay: DateTime(2023, 1, 1),
          lastDay: DateTime(2100, 1, 1),
          focusedDay: widget.selectedDate,
          calendarFormat: _calendarFormat,
          onDaySelected: widget.onDaySelected,
          selectedDayPredicate: (date) =>
          date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day,
          eventLoader: (date) {
            String formattedDate = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
            return widget.events[formattedDate] ?? [];
          },
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date),
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              color: Colors.white,
            ),
            leftChevronVisible: false, // 왼쪽 화살표 숨기기
            rightChevronVisible: false, // 오른쪽 화살표 숨기기
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            headerMargin: EdgeInsets.zero, // 헤더 마진 제거
            headerPadding: EdgeInsets.zero, // 헤더 패딩 제거
          ),
          daysOfWeekHeight: 30.0, // 간격을 늘리기 위해 높이를 증가시킴
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
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            defaultDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5.0),
            ),
            weekendDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5.0),
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
              color: Colors.red,
            ),
            selectedTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            outsideTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: LIGHT_GREY_COLOR,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, date) {
              return GestureDetector(
                onTap: () => widget.onHeaderTapped(date),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 48), // 왼쪽 빈 공간
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
                      offset: Offset(0, 50), // 팝업 메뉴 위치 조정
                      onSelected: (value) {
                        if (value == '사이즈 변경') {
                          setState(() {
                            _calendarToggleCount = (_calendarToggleCount + 1) % 3;
                            if (_calendarToggleCount == 0) {
                              _calendarFormat = CalendarFormat.month;
                            } else if (_calendarToggleCount == 1) {
                              _calendarFormat = CalendarFormat.twoWeeks;
                            } else {
                              _calendarFormat = CalendarFormat.week;
                            }
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: '일기 전환',
                            child: Row(
                              children: [
                                Icon(Icons.event_note, color: Colors.black),
                                SizedBox(width: 8),
                                Text('일기 전환'),
                              ],
                            ),
                          ),
                          PopupMenuDivider(height: 1.0),
                          PopupMenuItem<String>(
                            value: '사이즈 변경',
                            child: Row(
                              children: [
                                Icon(Icons.zoom_in_map, color: Colors.black),
                                SizedBox(width: 8),
                                Text('사이즈 변경'),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              );
            },
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    width: 16.0,
                    height: 16.0,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${events.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
            todayBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}