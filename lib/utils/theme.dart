import 'package:flutter/material.dart';

// const kBlackHalf = const Color(0xFF212121);
// const kBlackLight = const Color(0xFF484848);
// const kBlack = const Color(0xFF000000);
// const kYellow = const Color(0xFFffd600);
// const kYellowLight = const Color(0xFFffff52);
// const kYellowDark = const Color(0xFFc7a500);
// const kWhite = Colors.white;
// 하나의 코드 베이스에 light 모드와 다크 모드 적용 시키기
ThemeData initThemeData() {
  /*final ThemeData base = ThemeData();
  return base.copyWith(
    primaryColor: const Color(0xFF47B752), // 주요 색상,
    secondary: const Color(0xFFEBF7EC), // 보조 색상
    surface: const Color(0xFFF9F9F9),//보조 색상
    scaffoldBackgroundColor: const Color(0xFFEBF7EC),
    // primaryTextTheme: buildTextTheme(base.primaryTextTheme, kWhite),
    // primaryIconTheme: base.iconTheme.copyWith(color: kWhite),
    buttonColor: const Color(0xFF47B752),
    // textTheme: buildTextTheme(base.textTheme, kWhite),
    // inputDecorationTheme: InputDecorationTheme(
    //   border: OutlineInputBorder(
    //       borderSide: BorderSide(color: kYellow)
    //   ),
    //   labelStyle: TextStyle(
    //       color: kYellow,
    //       fontSize: 24.0
    //   ),
    // ),
  );*/
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF47B752), // 주요 색상
        secondary: Color(0xFFEBF7EC), // 보조 색상
        surface: Color(0xFFF9F9F9),

      ),
    );

}

// TextTheme textTheme(Color textColor) {
//   return TextTheme(
//     displayLarge: GoogleFonts.archivo(fontSize: 24.0, color: textColor),
//     displayMedium: GoogleFonts.archivo(
//         fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
//     displaySmall: GoogleFonts.archivo(
//         fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
//     bodyLarge: GoogleFonts.archivo(fontSize: 20.0, color: textColor),
//     bodyMedium: GoogleFonts.archivo(fontSize: 18.0, color: textColor),
//     bodySmall: GoogleFonts.archivo(fontSize: 16.0, color: textColor),
//     titleLarge: GoogleFonts.archivo(fontSize: 16.0, color: textColor),
//     titleMedium: GoogleFonts.archivo(fontSize: 14.0, color: textColor),
//     titleSmall: GoogleFonts.archivo(fontSize: 12.0, color: textColor),
//   );
// }

// AppBarTheme appBarTheme() {
//   return AppBarTheme(
//     centerTitle: false,
//     color: Colors.white,
//     elevation: 0.0,
//     iconTheme: iconTheme(),
//     titleTextStyle: GoogleFonts.nanumGothic(
//       fontSize: 16,
//       fontWeight: FontWeight.bold,
//       color: Colors.black,
//     ),
//   );
// }
//
// IconThemeData iconTheme() {
//   return const IconThemeData(
//     color: Colors.orange,
//   );
// }