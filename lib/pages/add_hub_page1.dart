import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page2.dart';

class AddHubPage1 extends StatelessWidget {
  const AddHubPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('허브 추가'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pairing 버튼을 길게 눌러 파란색 LED가 빠르게 점등할 수 있도록 해 주세요'),
              const SizedBox(height: 20,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white60,
                  backgroundColor: Colors.lightBlue, // text color
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
    );
  }
}
