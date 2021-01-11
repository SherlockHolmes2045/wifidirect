import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:siuu_tchat/core/model/tcpData.dart';
import 'package:siuu_tchat/core/viewmodel/server_vm.dart';
import 'package:siuu_tchat/custom/customAppBars/appBar3.dart';
import 'package:siuu_tchat/utils/margin.dart';

import '../messageWidget.dart';
//import 'package:tcp/widgets/qrDialog.dart';

class RoomTalk extends StatefulWidget {
  final TCPData tcpData;
  final bool isHost;

  const RoomTalk({Key key, @required this.tcpData, this.isHost = false})
      : super(key: key);
  @override
  _RoomTalkState createState() => _RoomTalkState();
}

class _RoomTalkState extends State<RoomTalk> {
  ServerViewModel serverProvider;

  @override
  void dispose() {
    if (widget.isHost) serverProvider.server.close();
    serverProvider.closeSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    serverProvider = context.watch<ServerViewModel>();
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.1755),
        child: AppBar3(
          title: "Room talk",
        ),
      ),
      body: Container(
        width: screenWidth(context),
        height: screenHeight(context),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                reverse: true,
                children: <Widget>[
                  for (var messageItem in serverProvider.messageList)
                    MessageWidget(message: messageItem),
                ],
              ),
            ),
            const YMargin(20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.grey[400].withOpacity(0.1),
                    offset: Offset(0, 13),
                    blurRadius: 30)
              ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const XMargin(20),
                  Expanded(
                    //width: screenWidth(context, percent: 0.43),
                    child: TextField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20),
                          border: InputBorder.none,
                          hintText: "Say something…",
                          hintStyle: TextStyle(
                            fontFamily: "Segoe UI",
                            fontSize: 15,
                            color: Color(0xff4d0cbb),
                          ),
                        ),
                        style: TextStyle(color: Color(0xff4d0cbb), fontSize: 15.0),
                        controller: serverProvider.msg,
                        autofocus: false),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: (){
                      if (serverProvider.msg.text != null &&
                          serverProvider.msg.text.isNotEmpty &&
                          widget.tcpData != null)
                        serverProvider.sendMessage(
                          context,
                          widget?.tcpData,
                          isHost: widget.isHost,
                        );
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                const Color(0x36FFFFFF),
                                const Color(0x0FFFFFFF)
                              ],
                              begin: FractionalOffset.topLeft,
                              end: FractionalOffset.bottomRight),
                          borderRadius: BorderRadius.circular(40)),
                      padding: EdgeInsets.all(12),
                      child:  SvgPicture.asset('assets/svg/icon - send.svg'),
                      ),
                    ),
                ],
              ),
            ),
            const YMargin(30)
          ],
        ),
      ),
    );
  }
}
