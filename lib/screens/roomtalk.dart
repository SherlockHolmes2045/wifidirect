import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siuu_tchat/core/model/tcpData.dart';
import 'package:siuu_tchat/core/viewmodel/server_vm.dart';
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme:
        IconThemeData(color: widget.isHost ? Colors.white : Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "TCP ",
              style: TextStyle(
                  color: widget.isHost ? Colors.white : Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w800
              ),
            ),
            Text(
              "| Chat",
              style: TextStyle(
                  color: widget.isHost ? Colors.white : Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
        backgroundColor: widget.isHost ? Colors.redAccent : Colors.white,
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
                  Container(
                    width: screenWidth(context, percent: 0.43),
                    child: TextField(
                        decoration: InputDecoration.collapsed(
                          hintText: 'Enter your message',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[300],
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        controller: serverProvider.msg,
                        autofocus: false),
                  ),
                  Spacer(),
                  Container(
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        if (serverProvider.msg.text != null &&
                            serverProvider.msg.text.isNotEmpty &&
                            widget.tcpData != null)
                          serverProvider.sendMessage(
                            context,
                            widget?.tcpData,
                            isHost: widget.isHost,
                          );
                      },
                      color: Colors.grey[100],
                      textColor: Colors.black,
                      child: Text('Send'),
                    ),
                  ),
                  /* Spacer(),
                  Container(
                    height: 20,
                    child: IconButton(
                      onPressed: () {},
                      iconSize:19,
                      color: Colors.grey[500],
                      icon: Icon(Icons.attach_file),
                    ),
                  ),
                  const XMargin(10), */
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
