import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../const/colors.dart'; // PURPLE_COLOR를 사용하기 위해 import 합니다.

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String locationName = '';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(position.latitude, position.longitude),
      15, // 줌 레벨을 15로 설정하여 줌 인된 상태로 표시합니다.
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위치 선택'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
                _determinePosition();
              },
              onTap: (location) {
                setState(() {
                  selectedLocation = location;
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 10,
              ),
              markers: selectedLocation == null
                  ? {}
                  : {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: selectedLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: '장소 이름',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  locationName = value;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedLocation != null && locationName.isNotEmpty) {
                Navigator.of(context).pop({
                  'latitude': selectedLocation!.latitude,
                  'longitude': selectedLocation!.longitude,
                  'locationName': locationName,
                });
              } else {
                // Show error message if location or name is not provided
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PURPLE_COLOR,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
