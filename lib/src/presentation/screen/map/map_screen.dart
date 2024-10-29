import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late Future<LatLng> _futurePosition;
  List<LatLng> parkingMarkLocations = [
    // parkingMark 위치 리스트
    LatLng(36.36730205978522, 127.34540481088318),
    LatLng(36.36733661659984, 127.3533870649115),
    // 더 많은 parkingMark 위치를 여기에 추가
  ];

  List<LatLng> accidentMarkLocations = [
    // accidentMark 위치 리스트
    LatLng(36.370157035956645, 127.3460054397583),
    LatLng(36.366058004236514, 127.34974784410072),
    // 더 많은 accidentMark 위치를 여기에 추가
  ];

  Set<Marker> _currentMarkers = {};
  double _currentZoom = 16.0;
  final double _averageTemperature = 36.5; // 평균 온도 변수

  @override
  void initState() {
    super.initState();
    _futurePosition = _getCurrentLocation();
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 서비스가 꺼져 있으면 메시지 표시
      return Future.error('위치 서비스가 꺼져 있습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('위치 정보를 가져오지 못했습니다: $e');
      return LatLng(0.0, 0.0); // 기본 위치 설정
    }
  }

  // 마커 생성 함수
  Future<void> _updateMarkers(LatLng center) async {
    final parkingIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(1, 1)), 'assets/images/parking_mark.png');
    final accidentIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(1, 1)), 'assets/images/accident_mark.png');

    if (_currentZoom < 12.0) {
      // 줌 레벨이 12.0 미만이면 마커를 표시하지 않음
      setState(() {
        _currentMarkers.clear();
      });
      return;
    }

    Set<Marker> markers = {};

    for (LatLng position in parkingMarkLocations) {
      markers.add(Marker(
        markerId: MarkerId('parkingMark_${position.latitude}_${position.longitude}'),
        position: position,
        icon: parkingIcon,
      ));
    }

    for (LatLng position in accidentMarkLocations) {
      markers.add(Marker(
        markerId: MarkerId('accidentMark_${position.latitude}_${position.longitude}'),
        position: position,
        icon: accidentIcon,
      ));
    }

    setState(() {
      _currentMarkers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('init build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('현재 위치 지도'),
      ),
      body: FutureBuilder<LatLng>(
        future: _futurePosition,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: snapshot.data!,
                    zoom: _currentZoom,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _updateMarkers(snapshot.data!);
                  },
                  onCameraMove: (CameraPosition position) {
                    _currentZoom = position.zoom;
                    _updateMarkers(position.target);
                  },
                  markers: _currentMarkers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  // 평균 온도를 왼쪽 하단에 표시
                  top: 20,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '평균 온도: $_averageTemperature°C',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('Unable to get location'));
          }
        },
      ),
    );

  }
}
