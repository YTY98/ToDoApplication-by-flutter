import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../const/colors.dart';
import '../model/event.dart';
import '../screen/home_screen.dart';
import '../screen/selected_priority.dart' as globals;
import '../screen/diary_screen.dart';

class MainCalendar extends StatefulWidget {
  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final Map<String, List<Event>> events;
  final Function(DateTime) onHeaderTapped;
  final Function() onListButtonTapped;

  MainCalendar({
    required this.onDaySelected,
    required this.selectedDate,
    required this.events,
    required this.onHeaderTapped,
    required this.onListButtonTapped,
  });

  @override
  _MainCalendarState createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  void _onCalendarSizeChanged(String value) {
    setState(() {
      if (value == '1주') {
        _calendarFormat = CalendarFormat.week;
      } else if (value == '2주') {
        _calendarFormat = CalendarFormat.twoWeeks;
      } else {
        _calendarFormat = CalendarFormat.month;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    HomeScreenState? parent = context.findAncestorStateOfType<HomeScreenState>();

    return Card(
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
              color: PURPLE_COLOR,
            ),
            leftChevronVisible: false,
            rightChevronVisible: false,
            decoration: BoxDecoration(
              color: PURPLE_COLOR,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            headerMargin: EdgeInsets.zero,
            headerPadding: EdgeInsets.zero,
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
                        if (value == '사이즈 변경') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('사이즈 변경'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.filter_1),
                                      title: Text('1주'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _onCalendarSizeChanged('1주');
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.filter_2),
                                      title: Text('2주'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _onCalendarSizeChanged('2주');
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.calendar_view_month),
                                      title: Text('전체'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _onCalendarSizeChanged('전체');
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (value == '중요도 필터') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              var priority = globals.selected_priority;
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(priority == 3 ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: DARK_GREY_COLOR),
                                      title: Row( // 텍스트 대신 Row로 별 아이콘 추가
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.star, color: Colors.deepOrange),
                                          Icon(Icons.star, color: Colors.deepOrange),
                                          Icon(Icons.star, color: Colors.deepOrange),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        globals.selected_priority = 3;
                                        parent?.setState(() {});
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(priority == 2 ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: DARK_GREY_COLOR),
                                      title: Row( // 텍스트 대신 Row로 별 아이콘 추가
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.star, color: Colors.deepOrange),
                                          Icon(Icons.star, color: Colors.deepOrange),
                                          Icon(Icons.star_border, color: Colors.grey),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        globals.selected_priority = 2;
                                        parent?.setState(() {});
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(priority == 1 ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: DARK_GREY_COLOR),
                                      title: Row( // 텍스트 대신 Row로 별 아이콘 추가
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.star, color: Colors.deepOrange),
                                          Icon(Icons.star_border, color: Colors.grey),
                                          Icon(Icons.star_border, color: Colors.grey),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        globals.selected_priority = 1;
                                        parent?.setState(() {});
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(priority == 0 ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: DARK_GREY_COLOR),
                                      title: Row( // 텍스트 대신 Row로 별 아이콘 추가
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.star_border, color: Colors.grey),
                                          Icon(Icons.star_border, color: Colors.grey),
                                          Icon(Icons.star_border, color: Colors.grey),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        globals.selected_priority = 0;
                                        parent?.setState(() {});
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(priority == -1 ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: DARK_GREY_COLOR),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("전체 보기"),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        globals.selected_priority = -1;
                                        parent?.setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (value == '일기 전환') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('일기 전환'),
                                content: Text('일기 전환 페이지로 이동하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('확인'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => DiaryScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: '일기 전환',
                            child: Row(
                              children: [
                                Icon(Icons.menu_book, color: Colors.black),
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
                          PopupMenuDivider(height: 1.0),
                          PopupMenuItem<String>(
                            value: '중요도 필터',
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.black),
                                SizedBox(width: 8),
                                Text('중요도 필터'),
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
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: PURPLE_COLOR, width:1.5)),
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
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
