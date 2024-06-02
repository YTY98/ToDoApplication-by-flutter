import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/colors.dart';
import 'main_screen.dart';
import '../component/second_calendar.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
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
              onHeaderTapped: _onHeaderTapped,
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
        .collection('diary')
        .doc(selectedDateStr)
        .get();

    if (docSnapshot.exists) {
      final content = docSnapshot.data()?['content'] ?? '일기가 없습니다.';
      showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: AlertDialog(
              title: Center(
                child: Text(
                  DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                  style: TextStyle(
                    color: PURPLE_COLOR,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Text(content),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: AlertDialog(
              title: Center(
                child: Text(
                  DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                  style: TextStyle(
                    color: PURPLE_COLOR,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Text('선택한 날짜에 작성된 일기가 없습니다.'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
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

  void _onHeaderTapped(DateTime date) {
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
}

class YearMonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  YearMonthPicker({
    required this.initialDate,
    required this.onDateChanged,
  });

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
    return Container(
      height: 160,
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, // 버튼의 가로 길이를 늘림
                padding: EdgeInsets.symmetric(horizontal: 10), // 내부 패딩 설정
                decoration: BoxDecoration(
                  border: Border.all(color: PURPLE_COLOR, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButton<int>(
                  isExpanded: true, // 텍스트 중앙 정렬
                  value: selectedYear,
                  iconEnabledColor: PURPLE_COLOR,
                  style: TextStyle(color: PURPLE_COLOR), // 텍스트 색상 설정
                  items: List.generate(78, (index) => 2023 + index)
                      .map((year) => DropdownMenuItem(
                    child: Center(child: Text('$year년', style: TextStyle(color: PURPLE_COLOR))),
                    value: year,
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                  underline: SizedBox(), // DropdownButton 기본 밑줄 제거
                ),
              ),
              SizedBox(width: 30), // 2024 버튼과 6 버튼 사이의 가로 간격 늘림
              Container(
                width: 100, // 버튼의 가로 길이를 늘림
                padding: EdgeInsets.symmetric(horizontal: 10), // 내부 패딩 설정
                decoration: BoxDecoration(
                  border: Border.all(color: PURPLE_COLOR, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButton<int>(
                  isExpanded: true, // 텍스트 중앙 정렬
                  iconEnabledColor: PURPLE_COLOR,
                  style: TextStyle(color: PURPLE_COLOR), // 텍스트 색상 설정
                  value: selectedMonth,
                  items: List.generate(12, (index) => index + 1)
                      .map((month) => DropdownMenuItem(
                    child: Center(child: Text('$month월', style: TextStyle(color: PURPLE_COLOR))),
                    value: month,
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                  underline: SizedBox(), // DropdownButton 기본 밑줄 제거
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: 270,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: PURPLE_COLOR, // Button text color
              ),
              onPressed: () {
                widget.onDateChanged(DateTime(selectedYear, selectedMonth));
              },
              child: Text('확인'),
            ),
          ),
        ],
      ),
    );
  }
}