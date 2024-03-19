import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

Future<Dio> authDio() async {
  var uri = "http://14.42.209.174:6008/api";
  BaseOptions options = BaseOptions(
      baseUrl: uri,
  );
  var dio = Dio(options);

  const storage = FlutterSecureStorage();

  // const storage = FlutterSecureStorage(
  //   iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  //   aOptions: AndroidOptions(encryptedSharedPreferences: true),
  // );

  dio.interceptors.clear();
  dio.interceptors.add(CookieManager(CookieJar()));
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
    // 기기에 저장된 AccessToken 로드
    final accessToken = await storage.read(key: 'ACCESS_TOKEN');

    options.headers['Authorization'] = 'Bearer $accessToken';
    return handler.next(options);
  }, onError: (error, handler) async {
    if (error.response?.statusCode == 401) {  // 인증 오류가 발생했을 경우: AccessToken의 만료
      /*

      // 기기에 저장된 AccessToken과 RefreshToken 로드
      final accessToken = await storage.read(key: 'ACCESS_TOKEN');
      final refreshToken = await storage.read(key: 'REFRESH_TOKEN');

      // 토큰 갱신 요청을 담당할 dio 객체 구현 후 그에 따른 interceptor 정의
      var refreshDio = Dio();

      refreshDio.interceptors.clear();

      refreshDio.interceptors.add(InterceptorsWrapper(onError: (error, handler) async {
        // 다시 인증 오류가 발생했을 경우: RefreshToken의 만료
        if (error.response?.statusCode == 401) {
          // 기기의 자동 로그인 정보 삭제
          await storage.deleteAll();

          // . . .
          // 로그인 만료 dialog 발생 후 로그인 페이지로 이동
          // . . .
        }
        return handler.next(error);
      }));

      // 토큰 갱신 API 요청 시 AccessToken(만료), RefreshToken 포함
      refreshDio.options.headers['Authorization'] = 'Bearer $accessToken';
      refreshDio.options.headers['Refresh'] = 'Bearer $refreshToken';

      // 토큰 갱신 API 요청
      final refreshResponse = await refreshDio.get('/token/refresh');

      // response로부터 새로 갱신된 AccessToken과 RefreshToken 파싱
      final newAccessToken = refreshResponse.headers['Authorization']![0];
      final newRefreshToken = refreshResponse.headers['Refresh']![0];

      // 기기에 저장된 AccessToken과 RefreshToken 갱신
      await storage.write(key: 'ACCESS_TOKEN', value: newAccessToken);
      await storage.write(key: 'REFRESH_TOKEN', value: newRefreshToken);

      // AccessToken의 만료로 수행하지 못했던 API 요청에 담겼던 AccessToken 갱신
      error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      // 수행하지 못했던 API 요청 복사본 생성
      final clonedRequest = await dio.request(error.requestOptions.path,
          options: Options(method: error.requestOptions.method, headers: error.requestOptions.headers), data: error.requestOptions.data, queryParameters: error.requestOptions.queryParameters);

      // API 복사본으로 재요청
      return handler.resolve(clonedRequest);

      */
    }

    return handler.next(error);
  }));

  return dio;
}
