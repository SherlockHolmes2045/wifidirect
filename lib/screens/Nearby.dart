import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siuu_tchat/Device.dart';

import '../events.dart';
import 'Messages/chat_custom.dart';

class Nearby extends StatefulWidget {
  @override
  _NearbyState createState() => _NearbyState();
}

class _NearbyState extends State<Nearby> {
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  List<Device> devices = new List<Device>();
  
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    print("initstate");
    activateDiscovery();
    runPlayground();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () async{
          await platform.invokeMethod("sendMessage",{"message": "test"});
        },
      ),
      body: Container(
        child:ListView.separated(
          separatorBuilder: (BuildContext context,int index){
            return Divider();
          },
          itemCount: devices.length,
            itemBuilder: (BuildContext context,int index){
              return ListTile(
                title: Text(devices[index].deviceName),
                onTap: ()async{
                  await platform.invokeMethod("connectToPeer",{"address":devices[index].deviceAddres});
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chat(name: devices[index].deviceName)),
                  );
                },
              );
            }
        )
        ),
    );

  }

  Future<void> activateDiscovery() async{
    await platform.invokeMethod('discover');
  }

  bool running = false;
  void runPlayground() async {
    if (running) return;

    var cancel = startListening((msg) async{
      if(msg != null){
        Map<dynamic,dynamic> result = await  platform.invokeMethod('getDevices');
        setState(() {
          devices = result.entries.map((element) => Device(element.key['name'],element.value["address"])).toList();
        });
      }
    });
    //cancel();
  }
}
