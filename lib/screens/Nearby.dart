import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siuu_tchat/database/chat_dao.dart';
import 'file:///D:/dev/Programmes/AndroidStudioProjects/siuu/siuu_tchat/lib/model/Device.dart';
import '../events.dart';
import 'Messages/chat_custom.dart';
import 'package:siuu_tchat/model/chat.dart' as chatModel;

class Nearby extends StatefulWidget {
  @override
  _NearbyState createState() => _NearbyState();
}

class _NearbyState extends State<Nearby> {
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  List<Device> devices = new List<Device>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initstate");
    activateDiscovery();
    runPlayground();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                print(devices.length);
                return ListTile(
                  title: Text(devices[index].deviceName),
                  onTap: () async {
                    await platform.invokeMethod("connectToPeer",
                        {"address": devices[index].deviceAddres});
                    ChatDao chatDao = new ChatDao();
                   chatDao.findChat(devices[index].deviceAddres).then((value){
                     if(value.isEmpty){
                       print("enregistrement de la discussion");
                       chatDao.insert(chatModel.Chat(devices[index].deviceAddres,devices[index].deviceName)).then((onValue) {
                         return;
                       });
                     }
                   });

                   String address = await platform.invokeMethod('bluetooth');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Chat(name: devices[index].deviceName,chatId: devices[index].deviceAddres,bleAddress: devices[index].bleAddres,)),
                    );
                  },
                );
              })),
    );
  }

  Future<void> activateDiscovery() async {
    await platform.invokeMethod('discover');
  }

  bool running = false;
  void runPlayground() async {
    if (running) return;

    var cancel = startListening((msg) async {
      if (msg != null) {
        Map<dynamic, dynamic> result =
            await platform.invokeMethod('getDevices');
        setState(() {
          devices = result.entries
              .map((element) => Device(element.key['name'], element.value["address"].split(" ")[0],element.value["address"].split(" ")[1])).toList();
        });
      }
    });
    //cancel();
  }
}
