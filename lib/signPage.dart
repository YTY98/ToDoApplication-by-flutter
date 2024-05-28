import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user.dart';

class SignPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignPage();
}

class _SignPage extends State<SignPage> {
  late FirebaseFirestore _firestore;
  late CollectionReference _usersCollection;

  late TextEditingController _idTextController;
  late TextEditingController _pwTextController;
  late TextEditingController _pwCheckTextController;

  @override
  void initState() {
    super.initState();
    _idTextController = TextEditingController();
    _pwTextController = TextEditingController();
    _pwCheckTextController = TextEditingController();

    _firestore = FirebaseFirestore.instance;
    _usersCollection = _firestore.collection('users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 가입'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Add padding above the TextField
                Container(
                  padding: EdgeInsets.only(top: 40.0),
                  width: 300,
                  child: TextField(
                    controller: _idTextController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16.0),
                      hintText: '4자 이상 입력해주세요',
                      labelText: '아이디',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _pwTextController,
                    obscureText: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16.0),
                      hintText: '6자 이상 입력해주세요',
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _pwCheckTextController,
                    obscureText: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16.0),
                      labelText: '비밀번호 확인',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_idTextController.value.text.length >= 4 &&
                          _pwTextController.value.text.length >= 6) {
                        if (_pwTextController.value.text ==
                            _pwCheckTextController.value.text) {
                          var bytes = utf8.encode(_pwTextController.value.text);
                          var digest = sha1.convert(bytes);
                          User newUser = User(
                              _idTextController.value.text,
                              digest.toString(),
                              DateTime.now().toIso8601String());

                          await _usersCollection
                              .doc(newUser.user_id)
                              .set(newUser.toJson())
                              .then((_) async {
                            final SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                            sharedPreferences.setString(
                                "user_id", newUser.user_id);
                            sharedPreferences.setString("user_pw", digest.toString());

                            // Show success dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Text('${newUser.user_id}님\n회원가입을 축하드립니다!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                        Navigator.of(context).pop(); // Go back to the previous screen
                                      },
                                      child: Text('확인'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }).catchError((error) {
                            makeDialog('사용자 생성 중 오류 발생: $error');
                          });
                        } else {
                          makeDialog('비밀번호가 틀립니다');
                        }
                      } else {
                        makeDialog('길이가 짧습니다');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      '회원가입',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
