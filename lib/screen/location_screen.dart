import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:schedulemate1/const/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? mapController;
  LatLng currentLatLng = LatLng(37.7749, -122.4194); // 초기 위치
  Set<Marker> markers = {};
  Marker? selectedMarker;

  @override
  void initState() {
    super.initState();
    _determinePosition();

    _loadData();



  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog('위치 서비스를 활성화해주세요.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog('위치 권한을 허가해주세요.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog('앱의 위치 권한을 설정에서 허가해주세요.');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
    mapController?.moveCamera(CameraUpdate.newLatLng(currentLatLng));
  }

  String user_id = '';
  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('user_id') ?? '';
      _loadMarkers();
    });
  }
  Future<void> _loadMarkers() async {

    final today = DateFormat('yyyyMMdd').format(DateTime.now());
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .collection('schedule')
      .where('date', isEqualTo:today)
      .where('finish', isEqualTo: 0) // 일정 완료되지 않은 항목만 가져옴
          .get();


      Set<Marker> newMarkers = snapshot.docs.map((doc) {
        final data = doc.data();
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['latitude'], data['longitude']),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
          onTap: () {
            _onMarkerTapped(
                data['locationName'], data['content'], data['startTime'],
                data['endTime']);
          },
        );
      }).toSet();

      setState(() {
        markers = newMarkers;
      });

    }

  void _onMarkerTapped(String locationName, String content, int startTime, int endTime) {
    if (selectedMarker != null) {
      Navigator.of(context).pop(); // Close the dialog if it's already open
      setState(() {
        selectedMarker = null; // Reset the selected marker
      });
      return;
    }

    setState(() {
      selectedMarker = Marker(
        markerId: MarkerId('selectedMarker'),
        position: currentLatLng,
      );
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 배경 색상 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0)), // 모서리를 둥글게
          ),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Color(0xff358FEA)), // 아이콘 추가
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationName,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), // 글자 스타일 변경
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Icon(Icons.access_time, color: DARK_GREY_COLOR), // 아이콘 추가
                  SizedBox(width: 8),
                  Text(
                    '시작 시간: ${_formatTime(startTime)}',
                    style: TextStyle(color: DARK_GREY_COLOR, fontSize: 14), // 글자 스타일 변경
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_filled, color: DARK_GREY_COLOR), // 아이콘 추가
                  SizedBox(width: 8),
                  Text(
                    '종료 시간: ${_formatTime(endTime)}',
                    style: TextStyle(color: DARK_GREY_COLOR, fontSize: 14), // 글자 스타일 변경
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.text_snippet, color: DARK_GREY_COLOR), // 아이콘 추가
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '내용: $content',
                      style: TextStyle(color: DARK_GREY_COLOR, fontSize: 14), // 글자 스타일 변경
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedMarker = null; // 선택된 마커 초기화
                });
              },
              child: Text(
                '닫기',
                style: TextStyle(color: Colors.black), // 버튼 글자 색상 설정
              ),
            ),
          ],
        );
      },
    );


  }

  String _formatTime(int time) {
    final hours = (time ~/ 60).toString().padLeft(2, '0');
    final minutes = (time % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "오늘의 일정 장소",
          style: TextStyle(
            color: Color(0xff358FEA),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          _determinePosition();
        },
        initialCameraPosition: CameraPosition(
          target: currentLatLng,
          zoom: 16,
        ),
        myLocationEnabled: true,
        markers: markers,
      ),
    );
  }
}
