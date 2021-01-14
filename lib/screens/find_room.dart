import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_ip/get_ip.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:siuu_tchat/core/model/tcpData.dart';
import 'package:siuu_tchat/core/viewmodel/server_vm.dart';
import 'package:siuu_tchat/screens/roomtalk.dart';
import 'package:siuu_tchat/utils/margin.dart';
import 'package:provider/provider.dart';

class FindRoom extends StatefulWidget {
  @override
  _FindRoomState createState() => _FindRoomState();
}

class _FindRoomState extends State<FindRoom> {
  bool serverFound = false;
  String ipAddress = "";

  @override
  void initState() {
    context.read<ServerViewModel>().initState();
    super.initState();
  }

  getIp(String ipAddr) async {
    const port = 4000;
    final stream = NetworkAnalyzer.discover2(
      '192.168.100',
      port,
      timeout: Duration(milliseconds: 400),
    );

    int found = 0;
    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        found++;
        print('Found device: ${addr.ip}:$port');
      }
    }).onDone(() => print('Finish. Found $found device(s)'));
  }

  Future<void> fetchServer(provider, BuildContext context) async {
    String ipAddress = "";
    if (!Platform.isMacOS) {
      ipAddress = await GetIp.ipAddress;
    }
    //getIp(ipAddress);
    List<String> ipBreak = ipAddress.split(".");
    String network = ipAddress.substring(0, ipAddress.lastIndexOf("."));
    String networkPart = ipBreak[ipBreak.length - 1];

    int networkPartInt = int.parse(networkPart);
    provider.port.text = "4000";
    provider.name.text = "test";
    Socket socket;
    print(ipAddress);
    for (int i = 1; i <= 255; i++) {
      if (i != networkPartInt) {
        String ipTest = network + "." + i.toString();

        socket = await Socket.connect(ipTest, int.parse("4000")).then((value) {
          provider.ip.text = ipTest;
          provider.port.text = "4000";
          provider.name.text = "test";
          serverFound = true;
        }).timeout(Duration(milliseconds: 80), onTimeout: () {
          return;
          throw "TimeOut";
        }).catchError((onError) {
          print(onError);
          return;
          throw "Error";
        });
      }
      print("i = " + i.toString());
      if (serverFound) break;
      if(!serverFound && i == 255) {
        provider.ip.text = ipAddress;
        provider.port.text = "4000";
        provider.name.text = "test";
        break;
      }

    }
    if(serverFound) socket.close();
    print("recherche termninée");
    return serverFound ? provider.ip.text : ipAddress;
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ServerViewModel>();
    return Scaffold(
        body: FutureBuilder(
            future: fetchServer(provider, context),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print("future finished");
                if (!serverFound) {
                  print(snapshot.data);
                  print("creating server...");
                  provider.ip.text = snapshot.data;
                  provider.port.text = "4000";
                  provider.name.text = "test";
                  print(provider.ip);
                  provider.startServer(context,snapshot.data,"4000","test");
                } else {
                  provider.connectToServer(context, isHost: false);
                }
                return Container();
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Chargement..."),
                      CircularProgressIndicator()
                    ],
                  ),
                );
              }
            }));
  }
}
