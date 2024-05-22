import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final int startTime;
  final int endTime;
  final String content;
  final int priority;

  const ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.content,
    required this.priority,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
                    startTime: startTime,
                    endTime: endTime,
                  ),
                  SizedBox(width: 13.0),
                  _Content(
                    content: content,
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
                index < priority ? Icons.star : Icons.star_border,
                color: index < priority ? Colors.deepOrange : Colors.grey,
                size: 15.0,
              );
            }),
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
      color: Colors.teal,
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

  const _Content({
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        content,
      ),
    );
  }
}

class ScheduleList extends StatefulWidget {
  final List<ScheduleCard> schedules;

  const ScheduleList({
    required this.schedules,
    Key? key,
  }) : super(key: key);

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  late List<ScheduleCard> sortedSchedules;

  @override
  void initState() {
    super.initState();
    sortedSchedules = List.from(widget.schedules);
    _sortSchedules();
  }

  void _sortSchedules() {
    sortedSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void _addSchedule(ScheduleCard schedule) {
    setState(() {
      sortedSchedules.add(schedule);
      _sortSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sortedSchedules.length,
      itemBuilder: (context, index) {
        return sortedSchedules[index];
      },
    );
  }
}
