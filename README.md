# argoscareseniorsafeguard

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 오류 모음
Could not create task ':path_provider_android:generateDebugUnitTestConfig'.
 - run flutter clean
 - do the Gradle sync without flutter pub get and make necessary changes to native android code.
 - do pub get and run the app.

## Splash Screen
수정한 splash screen을 적용하기 위해서 아래 명령을 터미널에 입력한다.
 - flutter clean
 - flutter pub get
 - flutter pub run flutter_native_splash:create

   새로 splash screen을 설정 할 때에는 android/app/main/res 디렉토리에서 drawable 관련 파일들을 모두 삭제하고 다시 screen을 설정 하거나
   flutter pub run flutter_native_splash:remove

## 다국어 리소스 generate
arb 의 내용을 추가할때마다 자동으로 연결되는 것이 아니라 regenerate 해주어야 한다.
 - flutter gen-l10n
 - flutter build