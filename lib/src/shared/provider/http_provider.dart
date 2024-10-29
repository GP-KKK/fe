part of '../provider.dart';

final httpProvider = Provider<Dio>((ref) {
  // Dio의 기본 옵션 설정
  final baseOptions = BaseOptions(
    headers: {
      'content-type': 'application/json',
      'accept': 'application/json',
      'x-timezone': 'Asia/Seoul',
    },
  );

  final dio = Dio(baseOptions);

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(
      storage: storage,
      ref: ref,
    ),
  );

  // TODO : Network Logger (Release Build에서는 주석 처리해야 함)
  // dio.interceptors.add(PrettyDioLogger(
  //   requestHeader: true,
  //   requestBody: true,
  //   responseBody: true,
  //   responseHeader: false,
  //   error: true,
  //   compact: true,
  //   maxWidth: 90,
  // ));

  dio.httpClientAdapter = NativeAdapter();

  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({
    required this.storage,
    required this.ref,
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ] [${options.method}] ${options.uri}');


    // 타임존 설정
    String localTimezone = await FlutterTimezone.getLocalTimezone();
    options.headers['x-timezone'] = localTimezone;

    // // 토큰 설정
    // if (options.headers['accessToken'] == 'true') {
    //   options.headers.remove('accessToken');
    //   final token = await storage.read(key: Constants.tokenKey);
    //   options.headers.addAll({
    //     'authorization': 'Bearer $token',
    //   });
    // }

    // user-agent 설정
    final info = await PackageInfo.fromPlatform();
    options.headers['user-agent'] =
    '${Platform.isIOS ? 'ios' : 'android'}/${info.version}';

    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    // print('response : ${response.data}');

    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');
    print('error : ${err.response?.data}');
    return handler.reject(err);
  }
}
