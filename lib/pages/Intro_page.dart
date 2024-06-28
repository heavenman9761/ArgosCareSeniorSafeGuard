import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Constants.primaryColor),
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF47B752),
                  Color(0xFF247D2C),
                ],
              )
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.all(46.h),
            child: Column(
              children: [
                SizedBox(height: 64.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ARGOS CARE", style: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'Pretendard')),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("돌봐효", style: TextStyle(fontSize: 32.sp, color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'SCDream')),
                  ]
                ),
                const Spacer(),
                //const Image(image: AssetImage('assets/images/intro_image.png'),),
                SvgPicture.asset("assets/images/intro_image.svg", width: 274.w, height: 248.h),
                SizedBox(height: 27.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("주식회사 에스씨티", style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w300, fontFamily: 'Pretendard')),
                  ]
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}