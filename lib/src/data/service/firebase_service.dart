import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

String simplifyEmail(String email) {
  return email.split('@')[0];  // '@' 앞 부분만 사용
}

Future<void> saveUserLocation(String email, String name) async {
  print('saveUserLocation called');
  try {
    final Position position = await getCurrentPositionWithPermission();
    final simplifiedEmail = simplifyEmail(email);  // 간소화된 이메일 사용
    fetchUsers();
    final DatabaseReference ref = FirebaseDatabase.instance.ref('users/$simplifiedEmail');
    await ref.set({
      'name': name,
      'latitude': position.latitude,
      'longitude': position.longitude,
    });

    print('유저 위치 저장 완료: $name ($email)');
  } catch (e) {
    print('유저 위치 저장 실패: $e');
  }
}
Future<void> fetchUsers() async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('users');
  final DataSnapshot snapshot = await ref.get();
}

Future<Position> getCurrentPositionWithPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다.');
    }
  }

  if (permission == LocationPermission.denied) {
    throw Exception('위치 권한이 거부되었습니다.');
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}
