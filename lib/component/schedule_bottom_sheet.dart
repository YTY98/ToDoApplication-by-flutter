import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/colors.dart';
import '../model/schedule_model.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Page/LocationPage.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const ScheduleBottomSheet({
    required this.selectedDate,
    Key? key,
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  String user_id = '';
  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('user_id') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  int separator = 0;
  String? content;
  int priority = 0;
  int finish = 0;
  bool isTimeSelected = false;

  double? latitude;
  double? longitude;
  String locationName = '';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: formKey,
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height / 2 + bottomInset,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: bottomInset),
            child: Column(
              children: [
                if (!isTimeSelected)
                  ...[
                    SizedBox(height: 20), // 위치를 아래로 내리기 위한 추가된 여백
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud, color: PURPLE_COLOR,size: 30),
                        SizedBox(width: 10),
                        Text(
                          '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.cloud, color: PURPLE_COLOR,size:30,),
                      ],
                    ),
                    SizedBox(height: 40), // 날짜 텍스트와 버튼 사이의 간격
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _selectTime(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PURPLE_COLOR,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('시작 시간'),
                          ),
                        ),
                        const SizedBox(width: 17.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _selectTime(context, false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PURPLE_COLOR,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('종료 시간'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 90), // 시작 시간 버튼과 종료 시간 버튼 사이의 세로 여백
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (startTime == null || endTime == null) {
                            showErrorDialog(context, '시작 시간과 종료 시간을 선택하세요.');
                          } else if (startTime == endTime) {
                            showErrorDialog(context, '시작 시간과 종료 시간이 같을 수 없습니다.');
                          } else if (startTime! > endTime!) {
                            showErrorDialog(context, '시작 시간이 종료 시간보다 늦을 수 없습니다.');
                          } else {
                            setState(() {
                              isTimeSelected = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PURPLE_COLOR,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('다음'),
                      ),
                    ),
                  ]
                else
                  ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.location_on, color: PURPLE_COLOR),
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LocationPage(),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                latitude = result['latitude'];
                                longitude = result['longitude'];
                                locationName = result['locationName'];
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: LIGHT_GREY_COLOR,
                        ),
                        child: TextFormField(
                          maxLines: null,
                          expands: true,
                          onSaved: (String? val) {
                            content = val;
                          },
                          validator: contentValidator,
                          style: GoogleFonts.bungee(
                            fontSize: 15.0,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(8.0),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return IconButton(
                          icon: Icon(
                            index < priority ? Icons.star : Icons.star_border,
                            color: index < priority ? Colors.deepOrange : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              priority = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onSavePressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PURPLE_COLOR,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('저장'),
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final timeInMinutes = picked.hour * 60 + picked.minute;
        if (isStartTime) {
          startTime = timeInMinutes;
        } else {
          endTime = timeInMinutes;
        }
      });
    }
  }

  void onSavePressed(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (startTime! >= endTime!) {
        showErrorDialog(context, '시작 시간이 종료 시간보다 앞서야 합니다.');
        return;
      }

      final schedule = ScheduleModel(
        id: Uuid().v4(),
        content: content!,
        date: widget.selectedDate,
        startTime: startTime!,
        endTime: endTime!,
        separator: separator,
        priority: priority,
        finish: finish,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('schedule')
          .doc(schedule.id)
          .set(schedule.toJson());

      Navigator.of(context).pop();
    }
  }

  String? contentValidator(String? val) {
    if (val == null || val.isEmpty) {
      return '값을 입력하세요';
    }
    return null;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
