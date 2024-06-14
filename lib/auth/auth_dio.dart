import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:path_provider/path_provider.dart';

Future<Dio> authDio() async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  var cookieJar = PersistCookieJar(ignoreExpires: true, storage: FileStorage("${appDocumentsDirectory.path}/.cookies/"));

  var uri = Constants.BASE_URL;
  BaseOptions options = BaseOptions(
    baseUrl: uri,
  );
  var dio = Dio(options);

  dio.interceptors.clear();
  // dio.interceptors.add(CookieManager(CookieJar()));
  dio.interceptors.add(CookieManager(cookieJar));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // 기기에 저장된 AccessToken 로드
      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      final accessToken = await storage.read(key: 'ACCESS_TOKEN');
      options.headers['Authorization'] = 'Bearer $accessToken';

      return handler.next(options);
    },
    onResponse: (response, handler) async {
      /*String? cookie = "";
      cookie = (response.headers['set-cookie'] ?? '') as String?;
      if (cookie != null && gCookie == '') {
        gCookie = cookie;
        print('Received cookie: $gCookie');
      }*/
      return handler.next(response);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 302) { //이미 로그인 한 상태
        print('http error code: 302');
      } else if (error.response?.statusCode == 401) { //유효 하지 않은 토큰
        print('http error code: 401');
      } else if (error.response?.statusCode == 419) { //토큰 만료
        print('http error code: 419');
      } else if (error.response?.statusCode == 420) { //세션(쿠키) 만료
        print('http error code: 420');
      } else if (error.response?.statusCode == 403) { //로그인이 필요한 서비스
        print('http error code: 403');
        /*const storage = FlutterSecureStorage(
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );
        final email = await storage.read(key: "EMAIL");
        final password = await storage.read(key: 'PASSWORD');

        var refreshDio = Dio(options);
        String? newCookie = "";

        refreshDio.interceptors.clear();
        refreshDio.interceptors.add(CookieManager(CookieJar()));
        refreshDio.interceptors.add(InterceptorsWrapper(
          onRequest: (options, handler) async {
            final accessToken = await storage.read(key: 'ACCESS_TOKEN');

            options.headers['Authorization'] = 'Bearer $accessToken';
            newCookie = options.headers['cookie'] ?? '';

            return handler.next(options);
          }
        ));

        final response = await refreshDio.post(
            "/auth/signin",
            data: jsonEncode({
              "email": email,
              "password": password
            })
        );

        final token = response.data['token'];
        await storage.write(key: 'ACCESS_TOKEN', value: token);

        var loginResponse = await refreshDio.get(
            "/auth/me"
        );

        final String userName = loginResponse.data['user']['name'];

        await storage.write(key: 'ID', value: loginResponse.data['user']['id']);
        await storage.write(key: 'EMAIL', value: loginResponse.data['user']['email']);
        await storage.write(key: 'PASSWORD', value: password);
        await storage.write(key: 'NAME', value: loginResponse.data['user']['name']);
        await storage.write(key: 'ADDR_ZIP', value: loginResponse.data['user']['addr_zip']);
        await storage.write(key: 'ADDR', value: loginResponse.data['user']['addr']);
        await storage.write(key: 'MOBILE_PHONE', value: loginResponse.data['user']['mobilephone']);
        await storage.write(key: 'TEL', value: loginResponse.data['user']['tel']);
        await storage.write(key: 'SNS_ID', value: loginResponse.data['user']['snsId']);
        await storage.write(key: 'PROVIDER', value: loginResponse.data['user']['provider']);
        await storage.write(key: 'ADMiN', value: loginResponse.data['user']['admin'].toString());

        // 수행하지 못했던 API 요청 복사본 생성
        error.requestOptions.headers['Authorization'] = 'Bearer $token';
        error.requestOptions.headers['cookie'] = newCookie;

        final clonedRequest = await dio.request(error.requestOptions.path,
            options: Options(method: error.requestOptions.method, headers: error.requestOptions.headers), data: error.requestOptions.data, queryParameters: error.requestOptions.queryParameters);

        // API 복사본으로 재요청
        return handler.resolve(clonedRequest);*/

        /*
        //아랫 부분 지우지 말 것.



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
    }
  ));

  return dio;
}
