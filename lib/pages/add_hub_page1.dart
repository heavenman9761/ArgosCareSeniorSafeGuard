import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page2.dart';

class AddHubPage1 extends StatelessWidget {
  const AddHubPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Theme.of(context).colorScheme.primary),
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white10,
                  Colors.white10,
                  Colors.black12,
                  Colors.black12,
                  Colors.black12,
                  Colors.black12,
                ],
              )
          ),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,//Colors.grey[300],
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('허브 추가'),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Pairing 버튼을 길게 눌러 파란색 LED가 빠르게 점등할 수 있도록 해 주세요',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              elevation: 5, //
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                          onPressed: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return const AddHubPage2();
                                }));
                          },//findHub,
                          child: const Text('다음 단계로')
                      )
                    ],
                  )
              ),
            )
        )
      ],
    );
  }
}
