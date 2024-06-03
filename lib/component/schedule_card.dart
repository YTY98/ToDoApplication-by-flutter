import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../const/colors.dart';
import '../model/schedule_model.dart';
import '../services/notification_service.dart'; // NotificationService import 추가

class ScheduleCard extends StatefulWidget {
  final String id;
  final int startTime;
  final int endTime;
  final String content;
  final int priority;
  final int finish;
  final String locationName;

  const ScheduleCard({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.content,
    required this.priority,
    required this.finish,
    required this.locationName,
    Key? key,
  }) : super(key: key);

  @override
  _ScheduleCardState createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  late int finish;
  late String userId;
  final NotificationService _notificationService = NotificationService(); // NotificationService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    finish = widget.finish;
    _loadUserId();
    _notificationService.init(); // 알림 초기화
    _scheduleNotifications(); // 일정 알림 예약
  }

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
    });
  }

  Future<void> _scheduleNotifications() async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.startTime ~/ 60,
      widget.startTime % 60,
    );

    final scheduledTimeMinus30 = scheduledTime.subtract(Duration(minutes: 30));

    if (scheduledTimeMinus30.isAfter(now)) {
      await _notificationService.scheduleNotification(
        widget.id.hashCode,
        "⏰일정 알림⏰",
        "\"${widget.content}\" 일정까지 30분 남았습니다.",
        scheduledTimeMinus30,
      );
    }

    if (scheduledTime.isAfter(now)) {
      await _notificationService.scheduleNotification(
        widget.id.hashCode + 1,
        "⏰일정 알림⏰",
        "\"${widget.content}\" 일정을 할 시간입니다.",
        scheduledTime,
      );
    }
  }

  void _toggleFinish() async {
    setState(() {
      finish = finish == 1 ? 0 : 1;
    });

    if (userId.isNotEmpty) {
      // Firestore에서 finish 값을 토글
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('schedule')
          .doc(widget.id)
          .update({'finish': finish});
    }

    // finish가 1로 변경되면 알림 발송
    if (finish == 1) {
      await _notificationService.showNotification("참 잘했어요👍", "\"${widget.content}\" 일정을 완료했습니다.");
    }
    // finish가 0로 변경되면 알림 발송
    else if (finish == 0) {
      await _notificationService.showNotification("앗, 다시 확인해주세요😢", "\"${widget.content}\" 일정 완료를 해제했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: finish == 1 ? LAVENDER_COLOR : Colors.white,
            border: Border.all(
              width: 1.0,
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(9.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Time(
                    startTime: widget.startTime,
                    endTime: widget.endTime,
                  ),
                  SizedBox(width: 13.0),
                  _Content(
                    content: widget.content,
                    locationName: widget.locationName,
                  ),
                  SizedBox(width: 13.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Row(
            children: List.generate(3, (index) {
              return Icon(
                index < widget.priority ? Icons.star : Icons.star_border,
                color: index < widget.priority ? Colors.deepOrange : Colors.grey,
                size: 15.0,
              );
            }),
          ),
        ),
        Positioned(
          right: 6,
          top: 15,
          child: IconButton(
            icon: Icon(
              finish == 1 ? Icons.check_box : Icons.check_box_outline_blank,
              color: finish == 1 ? PURPLE_COLOR : Colors.grey.shade300,
            ),
            onPressed: _toggleFinish,
          ),
        ),
      ],
    );
  }
}

class _Time extends StatelessWidget {
  final int startTime;
  final int endTime;

  const _Time({
    required this.startTime,
    required this.endTime,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: PURPLE_COLOR,
      fontSize: 14.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${(startTime ~/ 60).toString().padLeft(2, '0')}:${(startTime % 60).toString().padLeft(2, '0')}',
          style: textStyle,
        ),
        Text(
          '${(endTime ~/ 60).toString().padLeft(2, '0')}:${(endTime % 60).toString().padLeft(2, '0')}',
          style: textStyle.copyWith(
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String content;
  final String locationName;

  const _Content({
    required this.content,
    required this.locationName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 4.0),
          Text(
            locationName,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleList extends StatefulWidget {
  final List<ScheduleModel> schedules;

  const ScheduleList({
    required this.schedules,
    Key? key,
  }) : super(key: key);

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  late List<ScheduleModel> sortedSchedules;

  @override
  void initState() {
    super.initState();
    sortedSchedules = List.from(widget.schedules);
    _sortSchedules();
  }

  void _sortSchedules() {
    sortedSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sortedSchedules.length,
      itemBuilder: (context, index) {
        final schedule = sortedSchedules[index];
        return ScheduleCard(
          key: ValueKey(schedule.id),
          id: schedule.id,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          content: schedule.content,
          priority: schedule.priority,
          finish: schedule.finish,
          locationName: schedule.locationName,
        );
      },
    );
  }
}
