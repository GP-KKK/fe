// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsListImpl _$$NewsListImplFromJson(Map<String, dynamic> json) =>
    _$NewsListImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$NewsListImplToJson(_$NewsListImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

_$NewsModelImpl _$$NewsModelImplFromJson(Map<String, dynamic> json) =>
    _$NewsModelImpl(
      title: json['title'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$$NewsModelImplToJson(_$NewsModelImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
    };

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      email: json['email'] as String,
      name: json['name'] as String,
      source: json['source'] as String?,
      profileImage: json['profileImage'] as String?,
      feelState: json['feelState'] == null
          ? FeelState.UNKNOWN
          : FeelStateExtension.fromJson(json['feelState'] as String?),
      feel: json['feel'] as String? ?? '',
      emotionDegree: (json['emotionDegree'] as num?)?.toDouble() ?? 36.5,
      qrcode: json['qrcode'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'source': instance.source,
      'profileImage': instance.profileImage,
      'feelState': _$FeelStateEnumMap[instance.feelState]!,
      'feel': instance.feel,
      'emotionDegree': instance.emotionDegree,
      'qrcode': instance.qrcode,
    };

const _$FeelStateEnumMap = {
  FeelState.DRIVING: 'DRIVING',
  FeelState.PARKING: 'PARKING',
  FeelState.COMMING_SOON: 'COMMING_SOON',
  FeelState.BUSY: 'BUSY',
  FeelState.UNKNOWN: 'UNKNOWN',
};
