import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileWidget extends ConsumerWidget{
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          child: Container(
            color: Colors.white,
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("  프로필 사진", style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("미등록", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: null,
                      )
                    ],
                  )
                ],
              )
          )
        ),
        // SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Container(
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("  대상자 이름", style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("이름을 입력해주세요", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: null,
                      )
                    ],
                  )

                ],
              ),
            )
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Container(
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("  보호자 이름", style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("이름을 입력해주세요", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: null,
                      )
                    ],
                  )

                ],
              ),
            )
        ),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Container(
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("  알림 관리", style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("알림 관리", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: null,
                      )
                    ],
                  )

                ],
              ),
            )
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Container(
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("  공유자 관리", style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("공유자 추가", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: null,
                      )
                    ],
                  )

                ],
              ),
            )
        ),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Container(
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("  현재 버전", style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("ver 0.1", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: null,
                      )
                    ],
                  )

                ],
              ),
            )
        ),
      ]
    );
  }
}