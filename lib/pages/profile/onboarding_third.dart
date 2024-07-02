import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';

class OnThirdBoardingPage extends StatelessWidget {
  const OnThirdBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container( //이전 페이지 버튼
                  // color: Colors.greenAccent,
                  height: 52.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          // color: Colors.redAccent,
                          child: IconButton(
                            constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                            padding: EdgeInsets.zero,
                            color: Colors.black,
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  // color: Colors.blueAccent,
                  height: 76.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("이용권", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  // color: Colors.blueAccent,
                  height: 45.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.w, 0, 0.w, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        RichText(
                            text: TextSpan(
                                text: "월 1만원",
                                style: TextStyle(fontSize: 15.sp, color: Constants.primaryColor, fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "으로 혜택을",
                                    style: TextStyle(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ]
                            )
                        ),
                        Text("누려보세요!", style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),),

                      ],
                    ),
                  ),
                ),

                SizedBox(height: 35.h),

                SizedBox(
                  // color: Colors.blueAccent,
                  height: 12.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.w, 0, 00.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 12.w, height: 12.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Constants.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 12,),
                        Container(
                          width: 12.w, height: 12.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Constants.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 12,),
                        Container(
                          width: 12.w, height: 12.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Constants.primaryColor,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: Center(
                      child: Image.asset(
                        "assets/images/onboarding_3.png",
                        fit:BoxFit.fitHeight,
                        // height: 30,
                        // width: 30.h
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                  child: MyButton(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);

                      // Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //   return const OnThirdBoardingPage();
                      // }));
                    },
                    text: "확인",
                  ),
                ),
              ],
            )
        )
    );
  }


}