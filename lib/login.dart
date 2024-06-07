// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:crypto/crypto.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../data/user.dart';
//
// class LoginPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _LoginPage();
// }
//
// class _LoginPage extends State<LoginPage> with SingleTickerProviderStateMixin {
//   late FirebaseFirestore _firestore;
//   late CollectionReference _usersCollection;
//
//   double opacity = 0;
//   late AnimationController _animationController;
//   late Animation _animation;
//   late TextEditingController _idTextController;
//   late TextEditingController _pwTextController;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _idTextController = TextEditingController();
//     _pwTextController = TextEditingController();
//
//     _animationController =
//         AnimationController(duration: Duration(seconds: 3), vsync: this);
//     _animation =
//         Tween<double>(begin: 0, end: pi * 2).animate(_animationController);
//     _animationController.repeat();
//     Timer(Duration(seconds: 2), () {
//       setState(() {
//         opacity = 1;
//       });
//     });
//
//     _firestore = FirebaseFirestore.instance;
//     _usersCollection = _firestore.collection('users');
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _idTextController.dispose();
//     _pwTextController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(16.0),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//                 AnimatedBuilder(
//                   animation: _animationController,
//                   builder: (context, widget) {
//                     return Transform.rotate(
//                       angle: _animation.value,
//                       child: widget,
//                     );
//                   },
//                   child: Icon(
//                     Icons.alarm,
//                     color: Colors.deepOrangeAccent,
//                     size: 80,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 50,
//                   child: Center(
//                     child: Text(
//                       'Schedule Mate',
//                       style: TextStyle(fontSize: 35),
//                     ),
//                   ),
//                 ),
//                 AnimatedOpacity(
//                   opacity: opacity,
//                   duration: Duration(seconds: 1),
//                   child: Column(
//                     children: <Widget>[
//                       Container(
//                         padding: EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Column(
//                           children: [
//                             TextField(
//                               controller: _idTextController,
//                               maxLines: 1,
//                               decoration: InputDecoration(
//                                 labelText: '아이디',
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                             Divider(color: Colors.grey),
//                             TextField(
//                               controller: _pwTextController,
//                               obscureText: true,
//                               maxLines: 1,
//                               decoration: InputDecoration(
//                                 labelText: '비밀번호',
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             if (_idTextController.value.text.isEmpty ||
//                                 _pwTextController.value.text.isEmpty) {
//                               makeDialog('빈칸이 있습니다');
//                             } else {
//                               DocumentSnapshot snapshot = await _usersCollection
//                                   .doc(_idTextController.value.text)
//                                   .get();
//
//                               if (!snapshot.exists) {
//                                 makeDialog('아이디가 없습니다');
//                               } else {
//                                 User user = User.fromSnapshot(snapshot);
//                                 var bytes = utf8.encode(_pwTextController.value.text);
//                                 var digest = sha1.convert(bytes);
//                                 if (user.user_pw == digest.toString()) {
//                                   final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//                                   sharedPreferences.setString("user_id", user.user_id);
//                                   sharedPreferences.setString("user_pw", digest.toString());
//                                   Navigator.of(context)
//                                       .pushReplacementNamed('/main');
//                                 } else {
//                                   makeDialog('비밀번호가 틀립니다');
//                                 }
//                               }
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             padding: EdgeInsets.symmetric(vertical: 16.0),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                           ),
//                           child: Text(
//                             '로그인',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton(
//                           onPressed: () {
//                             Navigator.of(context).pushNamed('/sign');
//                           },
//                           style: OutlinedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 16.0),
//                             side: BorderSide(color: Colors.black),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                           ),
//                           child: Text('회원가입'),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void makeDialog(String text) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             content: Text(text),
//           );
//         });
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schedulemate1/const/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  late FirebaseFirestore _firestore;
  late CollectionReference _usersCollection;

  double opacity = 0;
  late TextEditingController _idTextController;
  late TextEditingController _pwTextController;

  @override
  void initState() {
    super.initState();

    _idTextController = TextEditingController();
    _pwTextController = TextEditingController();

    Timer(Duration(seconds: 2), () {
      setState(() {
        opacity = 1;
      });
    });

    _firestore = FirebaseFirestore.instance;
    _usersCollection = _firestore.collection('users');
  }

  @override
  void dispose() {
    _idTextController.dispose();
    _pwTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      Icon(
                        Icons.check_box_rounded, // 변경된 아이콘
                        color: PURPLE_COLOR,
                        size: 80,
                      ),
                      SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            'Schedule Mate',
                            style: TextStyle(fontSize: 35),
                          ),
                        ),
                      ),
                      SizedBox(height: 30), // "Schedule Mate"와 입력창 사이 거리 증가
                      AnimatedOpacity(
                        opacity: opacity,
                        duration: Duration(seconds: 1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _idTextController,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        labelText: '아이디',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                    Divider(color: LIGHT_GREY_COLOR),
                                    TextField(
                                      controller: _pwTextController,
                                      obscureText: true,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        labelText: '비밀번호',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_idTextController.value.text.isEmpty ||
                                        _pwTextController.value.text.isEmpty) {
                                      makeDialog('빈칸이 있습니다');
                                    } else {
                                      DocumentSnapshot snapshot = await _usersCollection
                                          .doc(_idTextController.value.text)
                                          .get();

                                      if (!snapshot.exists) {
                                        makeDialog('아이디가 없습니다');
                                      } else {
                                        User user = User.fromSnapshot(snapshot);
                                        var bytes = utf8.encode(_pwTextController.value.text);
                                        var digest = sha1.convert(bytes);
                                        if (user.user_pw == digest.toString()) {
                                          final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                          sharedPreferences.setString("user_id", user.user_id);
                                          sharedPreferences.setString("user_pw", digest.toString());
                                          Navigator.of(context)
                                              .pushReplacementNamed('/main');
                                        } else {
                                          makeDialog('비밀번호가 틀립니다');
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PURPLE_COLOR2,
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    '로그인',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/sign');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    backgroundColor: PURPLE_COLOR2, // 배경색 검은색으로 변경
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    '회원가입',
                                    style: TextStyle(color: Colors.white), // 텍스트 색 흰색으로 변경
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void makeDialog(String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(text),
        );
      },
    );
  }
}
