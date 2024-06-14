import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;

  const SquareTile({ super.key, required this.imagePath, required this.onTap });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.h),
        // decoration: BoxDecoration(
        //   border: Border.all(color: Colors.white),
        //   borderRadius: BorderRadius.circular(5),
        //   color: Colors.grey[200],
        // ),
        child: Image.asset(
          imagePath,
          // fit:BoxFit.fill,
          // height: 30,
          width: 30.h
        ),
      )
    );
  }
}
