import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    _loadMarkers();
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

  Future<void> _loadMarkers() async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final snapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .where('date', isEqualTo: today)
        .where('finish', isEqualTo: 0) // 일정 완료되지 않은 항목만 가져옴
        .get();

    Set<Marker> newMarkers = snapshot.docs.map((doc) {
      final data = doc.data();
      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(data['latitude'], data['longitude']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: () {
          _onMarkerTapped(data['locationName'], data['content'], data['startTime'], data['endTime']);
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
          title: Text(locationName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('내용: $content'),
              SizedBox(height: 8),
              Text('시작 시간: ${_formatTime(startTime)}'),
              SizedBox(height: 4),
              Text('종료 시간: ${_formatTime(endTime)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedMarker = null; // Reset the selected marker
                });
              },
              child: Text('닫기'),
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
          '오늘의 일정 장소',
          style: TextStyle(
            color: Colors.blue,
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
