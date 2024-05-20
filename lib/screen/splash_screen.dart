import 'package:flutter/material.dart';
import 'main_screen.dart'; // MainScreen을 import
import '../const/colors.dart';

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
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen())); // MainScreen으로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: PRIMARY_COLOR,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 위젯들을 세로 중앙으로 정렬
          children: [
            Image.asset(
              'assets/logo.png',
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GOLD_COLOR),
            ),
          ],
        ),
      ),
    );
  }
}
