import 'package:flutter/material.dart';
import 'package:iamport_flutter/iamport_certification.dart';
import 'package:iamport_flutter/model/certification_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';

class PhoneCertification extends ConsumerWidget {
  final String userCode;
  final CertificationData data;

  const PhoneCertification({super.key, required this.userCode, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IamportCertification(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('휴대폰 본인인증'),
        centerTitle: true,
        // titleTextStyle: const TextStyle(
        //   fontSize: 24,
        //   color: Colors.white,
        // ),

        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios),
        //   onPressed: () {
        //     // Get.back();
        //   },
        // ),
      ),
      initialChild: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
            ],
          ),
        ),
      ),
      userCode: userCode,
      data: data,
      callback: (Map<String, String> result) {
        if (result['success'] == 'true') {
          ref.read(phoneCertificationProvider.notifier).state = true;
          Navigator.pop(context, '인증에 성공하였습니다.');
        } else {
          ref.read(phoneCertificationProvider.notifier).state = false;
          Navigator.pop(context, '인증에 실패하였습니다.');
        }
      },
    );
  }
}
