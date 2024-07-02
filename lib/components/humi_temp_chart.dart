import 'dart:ffi';

import "package:flutter/material.dart";
import 'package:argoscareseniorsafeguard/utils/color_extensions.dart';

class HumiTempChart extends StatefulWidget {
  HumiTempChart({super.key});

  final Color leftBarColor = const Color(0xFFFFC300);
  final Color rightBarColor = const Color(0xFFE80054);
  final Color avgColor = const Color(0xFFE80054).avg(const Color(0xFFE80054));

  @override
  State<HumiTempChart> createState() => _HumiTempChartState();
}

class _HumiTempChartState extends State<HumiTempChart> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

}