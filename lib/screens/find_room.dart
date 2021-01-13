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
  getIp(String ipAddr) async{
    const port = 4000;
    final stream = NetworkAnalyzer.discover2(
      '192.168.100', port,
      timeout: Duration(milliseconds: 100),
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
    /*getIp(ipAddress);*/
    List<String> ipBreak = ipAddress.split(".");
    String network = ipAddress.substring(0,ipAddress.lastIndexOf("."));
    String networkPart = ipBreak[ipBreak.length -1];

    int networkPartInt = int.parse(networkPart);
    provider.port.text = "4000";
    provider.name.text = "test";
    Socket socket;
    for(int i = 2; i<= 25;i++){
      if(i != networkPartInt){
        String ipTest = network +"."+i.toString();
        print(ipTest);

        socket = await Socket.connect(ipTest, int.parse("4000")).then((value){
          print("hey");
          provider.ip.text = ipTest;
          provider.port.text = "4000";
          provider.name.text = "test";
          serverFound = true;
        }).timeout(Duration(milliseconds: 80), onTimeout: () {
          throw "TimeOut";
          return;
        }).catchError((onError){
          print(onError);
          return;
          throw "Error";
        });
      }
      if(serverFound)
        break;
    }
    return serverFound ? provider.ip.text : null;
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<ServerViewModel>();
    return Scaffold(
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              child: Icon(Icons.add),
              heroTag: null,
              onPressed: () {
                showServerDialog(context, provider: provider);
              },
            ),
            FloatingActionButton(
              child: Icon(Icons.arrow_forward),
              heroTag: null,
              onPressed: () {
                showClientDialog(context, provider: provider);
              },
            )
          ],
        ),
        body: FutureBuilder(
            future: fetchServer(provider, context),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if(snapshot.data == null){
                  provider.ip.text = ipAddress;
                  provider.port.text = "4000";
                  provider.name.text = "test";
                  provider.startServer(context);
                }else{
                  provider.connectToServer(context,
                      isHost: false);
                }
                return Container();
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chargement..."
                      ),
                      CircularProgressIndicator()
                    ],
                  ),
                );
              }
            }));
  }

  showClientDialog(BuildContext context, {provider}) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight(context) / 10,
          child: Dialog(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Center(
              child: ListView(
                children: <Widget>[
                  Container(
                    height: screenHeight(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "TCP ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800),
                            ),
                            Text(
                              "| Chat",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w300),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                " Client",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ],
                        ),
                        //const YMargin(50),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[900].withOpacity(0.1),
                                  offset: Offset(0, 13),
                                  blurRadius: 30)
                            ],
                          ),
                          child: Container(
                            width: screenWidth(context, percent: 0.8),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Enter IP Address',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white60,
                                  ),
                                ),
                                controller: provider.ip,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                                keyboardAppearance: Brightness.light,
                                autofocus: false),
                          ),
                        ),
                        const YMargin(30),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[900].withOpacity(0.1),
                                  offset: Offset(0, 13),
                                  blurRadius: 30)
                            ],
                          ),
                          child: Container(
                            width: screenWidth(context, percent: 0.8),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Enter Port',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white60,
                                  ),
                                ),
                                controller: provider.port,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                                keyboardAppearance: Brightness.light,
                                autofocus: false),
                          ),
                        ),
                        const YMargin(30),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[900].withOpacity(0.1),
                                  offset: Offset(0, 13),
                                  blurRadius: 30)
                            ],
                          ),
                          child: Container(
                            width: screenWidth(context, percent: 0.8),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Enter Name',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white60,
                                  ),
                                ),
                                controller: provider.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                                keyboardAppearance: Brightness.light,
                                autofocus: false),
                          ),
                        ),
                        const YMargin(30),
                        Container(
                          width: screenWidth(context, percent: 0.8),
                          child: Row(
                            children: <Widget>[
                              Text(
                                provider?.errorMessage ?? '',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        //Spacer(),
                        provider.isLoading
                            ? Container(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Container(
                                height: 50,
                                width: screenWidth(context, percent: 0.5),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.grey[900].withOpacity(0.1),
                                        offset: Offset(0, 13),
                                        blurRadius: 30)
                                  ],
                                ),
                                child: FlatButton(
                                  onPressed: () {
                                    provider.connectToServer(context,
                                        isHost: false);
                                  },
                                  child: Text(
                                    "Connect to Server",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                        const YMargin(40),
                        // const YMargin(100)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
  showServerDialog(BuildContext context, {provider}) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight(context) / 10,
          child: Dialog(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Center(
              child: ListView(
                children: <Widget>[
                  Container(
                    height: screenHeight(context) / 1.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "TCP ",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800),
                            ),
                            Text(
                              "| Chat",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w300),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                " Server",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ],
                        ),
                        const YMargin(50),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[400].withOpacity(0.1),
                                  offset: Offset(0, 13),
                                  blurRadius: 30)
                            ],
                          ),
                          child: Container(
                            width: screenWidth(context, percent: 0.8),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Enter IP Address',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                controller: provider.ip,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                keyboardAppearance: Brightness.light,
                                autofocus: false),
                          ),
                        ),
                        const YMargin(30),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[400].withOpacity(0.1),
                                  offset: Offset(0, 13),
                                  blurRadius: 30)
                            ],
                          ),
                          child: Container(
                            width: screenWidth(context, percent: 0.8),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Enter Port',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                controller: provider.port,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                keyboardAppearance: Brightness.light,
                                autofocus: false),
                          ),
                        ),
                        const YMargin(30),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[400].withOpacity(0.1),
                                  offset: Offset(0, 13),
                                  blurRadius: 30)
                            ],
                          ),
                          child: Container(
                            width: screenWidth(context, percent: 0.8),
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Enter Name',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                controller: provider.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                keyboardAppearance: Brightness.light,
                                autofocus: false),
                          ),
                        ),
                        const YMargin(30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: screenWidth(context) / 2,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[400].withOpacity(0.5),
                                      offset: Offset(0, 13),
                                      blurRadius: 30)
                                ],
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  provider.startServer(context);
                                },
                                child: Text(
                                  "Energize",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                        //const YMargin(10)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
