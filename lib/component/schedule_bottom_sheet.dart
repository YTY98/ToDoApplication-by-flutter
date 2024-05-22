import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart'; // time_picker_spinner 패키지 임포트
import '../component/custom_text_field.dart';
import '../const/colors.dart';
import '../model/schedule_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  int separator = 0;
  String? content;
  int priority = 0; // 중요도 저장 변수
  int finish = 0;
  bool isTimeSelected = false;

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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '시작 시간',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TimePickerSpinner(
                                is24HourMode: true,
                                normalTextStyle: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                                highlightedTextStyle: TextStyle(
                                  fontSize: 24,
                                  color: Colors.blue,
                                ),
                                spacing: 50,
                                itemHeight: 70, // 높이를 줄여서 다음 버튼이 보이도록 조정
                                isForce2Digits: true,
                                onTimeChange: (time) {
                                  setState(() {
                                    startTime = time.hour * 60 + time.minute;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '종료 시간',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TimePickerSpinner(
                                is24HourMode: true,
                                normalTextStyle: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                                highlightedTextStyle: TextStyle(
                                  fontSize: 24,
                                  color: Colors.blue,
                                ),
                                spacing: 50,
                                itemHeight: 70, // 높이를 줄여서 다음 버튼이 보이도록 조정
                                isForce2Digits: true,
                                onTimeChange: (time) {
                                  setState(() {
                                    endTime = time.hour * 60 + time.minute;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('다음'),
                      ),
                    ),
                  ]
                else
                  ...[
                    Expanded(
                      child: CustomTextField(
                        label: '내용',
                        isTime: false,
                        onSaved: (String? val) {
                          content = val;
                        },
                        validator: contentValidator,
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
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.black,
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
      );

      await FirebaseFirestore.instance
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
