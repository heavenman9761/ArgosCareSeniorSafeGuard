import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

class JaeSilWidget extends ConsumerWidget {
  const JaeSilWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
            width: ref.watch(jaeSilStateProvider) == JaeSilStateEnum.jsNone ? 132.w : 96.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: ref.watch(jaeSilStateProvider) != JaeSilStateEnum.jsOut ? const Color(0xFF404040).withOpacity(0.3) : const Color(0xFFEF5B54),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                SizedBox(width: 16.w,),
                Text(ref.watch(jaeSilStateProvider) == JaeSilStateEnum.jsNone ? "재실 확인불가"
                    : (ref.watch(jaeSilStateProvider) == JaeSilStateEnum.jsIn ? "재실중": "외출중"), style: TextStyle(fontSize: 12.sp, color: Colors.white), ),
                SizedBox(width: 4.w,),
                ref.watch(jaeSilStateProvider) == JaeSilStateEnum.jsNone
                    ? SvgPicture.asset('assets/images/jaesil_unknown.svg', width: 20.w, height: 20.h,)
                    : (ref.watch(jaeSilStateProvider) == JaeSilStateEnum.jsIn ? SvgPicture.asset('assets/images/jaesil.svg', width: 20.w, height: 20.h,) : SvgPicture.asset('assets/images/jaesil_not.svg', width: 20.w, height: 20.h,))
              ],
            )
        )
      ],
    );
  }
}
