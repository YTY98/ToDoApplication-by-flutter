import 'package:flutter/material.dart';
import 'package:schedulemate1/screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart'; // MainScreen을 import
import '../const/colors.dart';
import '../Login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }


  _navigateToHome() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('user_id')) {
      await Future.delayed(Duration(seconds: 1), () {});
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen())); // MainScreen으로 이동
    } else {
      await Future.delayed(Duration(seconds: 3), () {});
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage())); // MainScreen으로 이동
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 위젯들을 세로 중앙으로 정렬
          children: [
            Image.asset(
              'assets/logo2.png',
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}


