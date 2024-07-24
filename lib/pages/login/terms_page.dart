import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/pages/login/register_page.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _allCheck = false;
  bool _essentialCheck1 = false;
  bool _essentialCheck2 = false;
  bool _essentialCheck3 = false;
  bool _optionalCheck1 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox( //이전 페이지 버튼
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
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("서비스 이용 약관", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  // color: Colors.blueAccent,
                  height: 60.h,

                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            width: 320.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Constants.borderColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 20.w),
                                Checkbox(
                                  value: _allCheck,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  side: MaterialStateBorderSide.resolveWith(
                                        (states) => BorderSide(width: 1.0, color: Colors.grey.shade400),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _allCheck = value!;
                                      _essentialCheck1 = value;
                                      _essentialCheck2 = value;
                                      _essentialCheck3 = value;
                                      _optionalCheck1 = value;
                                    });
                                  },
                                ),
                                Text("약관 전체 동의", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                SizedBox(
                  // color: Colors.blueAccent,
                  height: 52.h,

                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            width: 320.w,
                            height: 52.h,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _essentialCheck1,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  side: MaterialStateBorderSide.resolveWith(
                                        (states) => BorderSide(width: 1.0, color: Colors.grey.shade400),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _essentialCheck1 = value!;
                                    });
                                  },
                                ),
                                Text("서비스 이용약관(필수)", style: TextStyle(fontSize: 14.sp, color: Colors.black),),
                                const Spacer(),
                                SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  // color: Colors.redAccent,
                                  child: IconButton(
                                    constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                                    padding: EdgeInsets.zero,
                                    color: Constants.dividerColor,
                                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                                    onPressed: () {
                                      debugPrint('icon press');
                                    },
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  // color: Colors.blueAccent,
                  height: 52.h,

                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            width: 320.w,
                            height: 52.h,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _essentialCheck2,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  side: MaterialStateBorderSide.resolveWith(
                                        (states) => BorderSide(width: 1.0, color: Colors.grey.shade400),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _essentialCheck2 = value!;
                                    });
                                  },
                                ),
                                Text("개인정보 수집/이용 동의(필수)", style: TextStyle(fontSize: 14.sp, color: Colors.black),),
                                const Spacer(),
                                SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  // color: Colors.redAccent,
                                  child: IconButton(
                                    constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                                    padding: EdgeInsets.zero,
                                    color: Constants.dividerColor,
                                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                                    onPressed: () {
                                      debugPrint('icon press');
                                    },
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  // color: Colors.blueAccent,
                  height: 52.h,

                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            width: 320.w,
                            height: 52.h,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _essentialCheck3,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  side: MaterialStateBorderSide.resolveWith(
                                        (states) => BorderSide(width: 1.0, color: Colors.grey.shade400),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _essentialCheck3 = value!;
                                    });
                                  },
                                ),
                                Text("위치정보 서비스 이용 동의(필수)", style: TextStyle(fontSize: 14.sp, color: Colors.black),),
                                const Spacer(),
                                SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  // color: Colors.redAccent,
                                  child: IconButton(
                                    constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                                    padding: EdgeInsets.zero,
                                    color: Constants.dividerColor,
                                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                                    onPressed: () {
                                      debugPrint('icon press');
                                    },
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  // color: Colors.blueAccent,
                  height: 52.h,

                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            width: 320.w,
                            height: 52.h,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _optionalCheck1,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  side: MaterialStateBorderSide.resolveWith(
                                        (states) => BorderSide(width: 1.0, color: Colors.grey.shade400),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _optionalCheck1 = value!;
                                    });
                                  },
                                ),
                                Text("마케팅 및 이용정보 수신 동의(선택)", style: TextStyle(fontSize: 14.sp, color: Colors.black),),
                                const Spacer(),
                                SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  // color: Colors.redAccent,
                                  child: IconButton(
                                    constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                                    padding: EdgeInsets.zero,
                                    color: Constants.dividerColor,
                                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                                    onPressed: () {
                                      debugPrint('icon press');
                                    },
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                    child: _getButton()
                ),
              ],
            )
        )
    );
  }

  Widget _getButton() {
    if (_essentialCheck1 && _essentialCheck2 && _essentialCheck3) {
      return MyButton(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return RegisterPage(optionalCheck: _optionalCheck1,);
                })
            );
          },
          text: "확인"
      );
    } else {
      return Container(
          height: 44.h,
          width: 320.w,
          decoration: BoxDecoration(
            color: Constants.borderColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("확인", style: TextStyle(fontSize: 12.sp, color: Colors.grey),)
            ],
          )
      );
    }
  }
}
