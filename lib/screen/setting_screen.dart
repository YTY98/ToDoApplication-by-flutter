import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_pw');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      await _logout(context);
    } else {
      _showErrorDialog(context, '계정 삭제 실패: 사용자 ID를 찾을 수 없습니다.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원 탈퇴'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('정말로 탈퇴하시겠습니까?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                await _deleteAccount(context);
                Navigator.of(context).pushReplacementNamed('/login'); // 로그인 페이지로 이동
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    TextEditingController _newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('비밀번호 변경'),
          content: TextField(
            controller: _newPasswordController,
            decoration: InputDecoration(hintText: "새 비밀번호"),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString('user_id');
                if (userId != null) {
                  var bytes = utf8.encode(_newPasswordController.value.text);
                  var digest = sha1.convert(bytes);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'user_pw': digest.toString()});
                  await prefs.setString('user_pw', digest.toString());
                  Navigator.of(context).pop();
                  await _logout(context); // 로그아웃 후 로그인 페이지로 이동
                } else {
                  _showErrorDialog(context, '비밀번호 변경 실패: 사용자 ID를 찾을 수 없습니다.');
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: FutureBuilder<String?>(
        future: _getUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('사용자 ID를 찾을 수 없습니다.'));
          } else {
            return ListView(
              padding: const EdgeInsets.only(top: 13.0, left: 18, right: 18),
              children: [
                Text(
                  '환영합니다. ${snapshot.data}님',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Divider(height: 25, thickness: 1),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  title: Text('로그아웃'),
                  onTap: () => _logout(context),
                ),
                Divider(height: 1, thickness: 1),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  title: Text('회원 탈퇴'),
                  onTap: () => _showDeleteConfirmationDialog(context),
                ),
                Divider(height: 1, thickness: 1),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  title: Text('비밀번호 변경'),
                  onTap: () => _changePassword(context),
                ),
                Divider(height: 1, thickness: 1),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  title: Text('앱 버전'),
                  subtitle: Text(
                    ' v1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Divider(height: 1, thickness: 1),
              ],
            );
          }
        },
      ),
    );
  }
}
