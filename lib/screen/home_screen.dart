import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../component/main_calendar.dart';
import '../component/schedule_card.dart';
import '../component/schedule_bottom_sheet.dart';
import '../const/colors.dart';
import '../model/event.dart';
import '../model/schedule_model.dart';

import 'selected_priority.dart' as globals;

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  Map<String, List<Event>> events = {};
  List<ScheduleModel> schedules = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  void loadEvents() {
    FirebaseFirestore.instance.collection('schedule').snapshots().listen((snapshot) {
      Map<String, List<Event>> newEvents = {};
      List<ScheduleModel> newSchedules = [];
      for (var doc in snapshot.docs) {
        Event event = Event.fromFirestore(doc.data() as Map<String, dynamic>);
        ScheduleModel schedule = ScheduleModel.fromJson(json: doc.data() as Map<String, dynamic>);
        String formattedDate = event.date;
        newEvents.putIfAbsent(formattedDate, () => []).add(event);
        newSchedules.add(schedule);
      }
      setState(() {
        events = newEvents;
        schedules = newSchedules;
        sortSchedulesByStartTime();
      });
    });
  }

  void sortSchedulesByStartTime() {
    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void onHeaderTapped(DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return YearMonthPicker(
          initialDate: date,
          onDateChanged: (newDate) {
            setState(() {
              selectedDate = newDate;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void onListButtonTapped() {
    print('List button tapped');
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            builder: (_) => ScheduleBottomSheet(
              selectedDate: selectedDate,
            ),
          );
        },
        child: Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Column(
                children: [
                  MainCalendar(
                    selectedDate: selectedDate,
                    onDaySelected: (selectedDate, focusedDate) =>
                        onDaySelected(selectedDate, focusedDate, context),
                    events: events,
                    onHeaderTapped: onHeaderTapped,
                    onListButtonTapped: onListButtonTapped,

                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('schedule')
                      .where(
                    'date',
                    isEqualTo: '${selectedDate.year}${selectedDate.month.toString().padLeft(2, '0')}${selectedDate.day.toString().padLeft(2, '0')}',
                  )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('일정 정보를 가져오지 못했습니다.'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }

                    /*final*/ schedules = snapshot.data!.docs
                        .map(
                          (QueryDocumentSnapshot e) => ScheduleModel.fromJson(
                        json: (e.data() as Map<String, dynamic>),
                      ),
                    )
                        .toList();

                    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

                    if (globals.selected_priority != -1) {
                      schedules = schedules.where((schedule) =>
                      schedule.priority == globals.selected_priority).toList();
                    }


                    return ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Slidable(
                            key: Key(schedule.id),
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                Builder(
                                  builder: (cont) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('schedule')
                                              .doc(schedule.id)
                                              .delete();
                                          Slidable.of(cont)!.close();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          backgroundColor: Colors.pinkAccent,
                                          padding: EdgeInsets.all(10),
                                          minimumSize: Size(60, 60),
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            child: Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ScheduleCard(
                                      id: schedule.id,
                                      startTime: schedule.startTime,
                                      endTime: schedule.endTime,
                                      content: schedule.content,
                                      priority: schedule.priority,
                                      finish: schedule.finish,
                                      locationName: schedule.locationName,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(
      DateTime selectedDate,
      DateTime focusedDate,
      BuildContext context,
      ) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}

class YearMonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  YearMonthPicker({required this.initialDate, required this.onDateChanged});

  @override
  _YearMonthPickerState createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(
                  78,
                      (index) => 2023 + index,
                ).map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text('$year'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                  });
                },
              ),
              SizedBox(width: 16),
              DropdownButton<int>(
                value: selectedMonth,
                items: List.generate(
                  12,
                      (index) => index + 1,
                ).map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text('$month'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                  });
                },
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDateChanged(DateTime(selectedYear, selectedMonth));
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
