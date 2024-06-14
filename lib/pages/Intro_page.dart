import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.all(46.h),
        child: Column(
          children: [
            SizedBox(height: 64.h),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("ARGOS CARE", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("돌봄 공백", style: TextStyle(fontSize: 12.sp, color: Colors.black,)),
                ]
            ),
            const Spacer(),
            const Image(image: AssetImage('assets/images/intro_image.png'),),
            SizedBox(height: 27.h),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("주식회사 에스씨티", style: TextStyle(fontSize: 12.sp, color: Colors.black,)),
                ]
            ),
          ],
        ),
      ),
    );
  }
}


/*
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.all(46.h),
        child: Column(
          children: [
            SizedBox(height: 64.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("ARGOS CARE", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold)),
              ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("돌봄 공백", style: TextStyle(fontSize: 12.sp, color: Colors.black,)),
                ]
            ),
            const Spacer(),
            const Image(image: AssetImage('assets/images/intro_image.png'),),
            SizedBox(height: 27.h),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("주식회사 에스씨티", style: TextStyle(fontSize: 12.sp, color: Colors.black,)),
                ]
            ),
          ],
        ),
      ),
    );
  }
}
*/
