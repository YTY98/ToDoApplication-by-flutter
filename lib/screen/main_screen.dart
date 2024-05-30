import 'package:flutter/material.dart';
import '../const/colors.dart';
import 'home_screen.dart';
import 'location_screen.dart';
import 'setting_screen.dart';
import 'diary_screen.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    LocationScreen(), // 게시판 화면
    SettingScreen(), // 설정 화면

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: '캘린더',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: '위치',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
          backgroundColor: Colors.white, // 네비게이션 바 배경 색상 설정
          selectedItemColor: DARK_GREY_COLOR, // 선택된 아이템 색상 설정
          unselectedItemColor: Colors.black, // 선택되지 않은 아이템 색상 설정
        ),
      ),
    );
  }
}
