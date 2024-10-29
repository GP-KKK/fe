part of '../model.dart';


enum FeelState {
  @JsonValue('DRIVING')
  DRIVING,
  @JsonValue('PARKING')
  PARKING,
  @JsonValue('COMMING_SOON')
  COMMING_SOON,
  @JsonValue('BUSY')
  BUSY,
  @JsonValue('UNKNOWN') // 여기서 UNKNOWN과 매핑
  UNKNOWN,
}
extension FeelStateExtension on FeelState {
  static FeelState fromJson(String? json) {
    if (json == null) return FeelState.UNKNOWN; // null 처리 추가
    final state = json.replaceFirst('FeelState.', '');

    switch (state) {
      case 'DRIVING':
        return FeelState.DRIVING;
      case 'PARKING':
        return FeelState.PARKING;
      case 'COMMING_SOON':
        return FeelState.COMMING_SOON;
      case 'BUSY':
        return FeelState.BUSY;
      default:
        return FeelState.UNKNOWN;
    }
  }

  String toJson() => toString().split('.').last;
}



@freezed
abstract class UserBase with _$UserBase {
  factory UserBase.user(UserModel user) = _UserBaseUser;
  const factory UserBase.error(String message) = UserError;
  const factory UserBase.loading() = UserLoading;
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String email,
    required String name,
    String? source,
    String? profileImage, // 정확한 매핑
    @Default(FeelState.UNKNOWN)
    @JsonKey(fromJson: FeelStateExtension.fromJson)
    FeelState feelState,
    @Default('') String feel,
    @Default(36.5) double emotionDegree,
    String? qrcode,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
