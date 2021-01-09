import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:siuu_tchat/custom/customAppBars/appBar3.dart';
import 'package:siuu_tchat/res/colors.dart';
import 'package:siuu_tchat/utils/message_type.dart';
import 'dart:io' as Io;

class Chat extends StatefulWidget {
  final String name;

  Chat({this.name});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, dynamic>> chats = new List<Map<String, dynamic>>();

  static const platform = const MethodChannel('samples.flutter.dev/battery');
  static const _channel_message =
      const EventChannel('com.sherlock2045.eventchannel/messages');

  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages(BuildContext context) {
    return chats.isNotEmpty
        ? Container(
            height: MediaQuery.of(context).size.height / 1.42,
            child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                chats[index]["time"])),
                        style: TextStyle(
                          fontFamily: "Segoe UI",
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          color: Color(0xff5b055e),
                        ),
                      ),
                      chats[index]["type"] == Status.TEXT
                          ? MessageTile(
                              message: chats[index]["message"],
                              sendByMe: chats[index]["sendBy"],
                            )
                          : chats[index]["type"] == Status.IMAGE
                              ? ImageTile(
                                  path: chats[index]["path"],
                                  sendByMe: chats[index]["sendBy"],
                                  byte: chats[index]["byte"],
                                )
                              : Container(child: Text("audio")),
                    ],
                  );
                }),
          )
        : Container();
  }

  Widget appBarMain(BuildContext context) {
    return AppBar(
      title: Text(widget.name),
      elevation: 0.0,
      centerTitle: true,
      backgroundColor: Color(0xff5b055e),
    );
  }

  addMessage(Status status, {String path = ""}) async {
    if (Status.TEXT == status) {
      if (messageEditingController.text.isNotEmpty) {
        Map<String, dynamic> chatMessageMap = {
          "sendBy": true,
          "message": messageEditingController.text,
          'time': DateTime.now().millisecondsSinceEpoch,
          'type': status,
          'path': path,
          'byte': false
        };
        await platform.invokeMethod("sendMessage",
            {"message": messageEditingController.text, "type": "text"});
        setState(() {
          chats.add(chatMessageMap);
          messageEditingController.text = "";
        });
      }
    } else if (Status.IMAGE == status) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": true,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
        'type': status,
        'path': path,
        'byte': false
      };
      final image = Io.File(path).readAsBytesSync();
      String imageStr = base64Encode(image);
      await platform
          .invokeMethod("sendMessage", {"message": imageStr, "type": "image"});
      setState(() {
        chats.add(chatMessageMap);
        messageEditingController.text = "";
      });
    }
  }

  pushReceivedMessage(String message, String type) {
    switch (type) {
      case "image": {
        Map<String, dynamic> chatMessageMap = {
          "sendBy": false,
          "message": message,
          "time": DateTime.now().millisecondsSinceEpoch,
          "type": Status.IMAGE,
          "path": message,
          "byte": true
        };
        setState(() {
          chats.add(chatMessageMap);
        });
      }
      break;
      case "text":{
        Map<String, dynamic> chatMessageMap = {
          "sendBy": true,
          "message": message,
          'time': DateTime.now().millisecondsSinceEpoch,
          'type': Status.TEXT,
          'path': null,
          'byte': false
        };
        setState(() {
          chats.add(chatMessageMap);
        });
      }
      break;
    }
  }

  TextStyle simpleTextStyle() {
    return TextStyle(color: Colors.white, fontSize: 16);
  }

  @override
  void initState() {
    super.initState();
    _enableTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _disableTimer();
  }

  @override
  Widget build(BuildContext context) {
    print(chats);
    /*chats.add({
      "sendBy": true,
      "message": "Lorem ipsum",
      "time": DateTime.now().millisecondsSinceEpoch,
    });
    chats.add({
      "sendBy": true,
      "message": "Lorem ipsum",
      "time": DateTime.now().millisecondsSinceEpoch,
    });
    chats.add({
      "sendBy": false,
      "message": "Lorem ipsum",
      "time": DateTime.now().millisecondsSinceEpoch,
    });*/
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    print(chats);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.1755),
        child: AppBar3(
          title: widget.name,
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(context),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                height: height * 0.075,
                width: width * 0.902,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: width * 0.002,
                    color: Color(0xff5b055e),
                  ),
                  borderRadius: BorderRadius.circular(26.00),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                          style: TextStyle(
                            fontFamily: "Segoe UI",
                            fontSize: 15,
                            color: Color(0xff4d0cbb),
                          ),
                          controller: messageEditingController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 20),
                            border: InputBorder.none,
                            hintText: "Say something…",
                            hintStyle: TextStyle(
                              fontFamily: "Segoe UI",
                              fontSize: 15,
                              color: Color(0xff4d0cbb),
                            ),
                          )),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage(Status.TEXT);
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
                          child:
                              SvgPicture.asset('assets/svg/icon - send.svg')),
                    ),
                    GestureDetector(
                      onTap: () async {
                        File result =
                            await FilePicker.getFile(type: FileType.image);
                        print("file " + result.toString());
                        addMessage(Status.IMAGE, path: result.path);
                        print(chats);
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
                        child: SvgPicture.asset('assets/svg/File.svg'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StreamSubscription _timerSubscription;

  void _enableTimer() {
    if (_timerSubscription == null) {
      _timerSubscription =
          _channel_message.receiveBroadcastStream().listen(_updateTimer);
    }
  }

  Text buildTimeText(String time) {
    return Text(
      time,
      style: TextStyle(
        fontFamily: "Segoe UI",
        fontWeight: FontWeight.w300,
        fontSize: 14,
        color: Color(0xff5b055e),
      ),
    );
  }

  void _disableTimer() {
    if (_timerSubscription != null) {
      _timerSubscription.cancel();
      _timerSubscription = null;
    }
  }

  void _updateTimer(timer) {
    debugPrint("Timer $timer");
    var dispatch = timer.split(" ");
    String message = "";
    for (int i = 0; i <= dispatch.size; i++) message += dispatch[i];
    pushReceivedMessage(timer, dispatch[dispatch.size - 1]);
  }
}

class ImageTile extends StatefulWidget {
  final String path;
  final bool sendByMe;
  final bool byte;
  ImageTile(
      {@required this.path, @required this.sendByMe, @required this.byte});
  @override
  _ImageTileState createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 250,
        width: 250,
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: widget.sendByMe ? 0 : 24,
            right: widget.sendByMe ? 24 : 0),
        alignment:
            widget.sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            margin: widget.sendByMe
                ? EdgeInsets.only(left: 30)
                : EdgeInsets.only(right: 30),
            padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.00),
              gradient: widget.sendByMe ? greyGradient : linearGradient,
              image: DecorationImage(
                  image: widget.byte
                      ? MemoryImage(base64Decode(widget.path))
                      : FileImage(File(widget.path)),
                  fit: BoxFit.cover),
            )));
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.00),
            gradient: sendByMe ? greyGradient : linearGradient),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: "Segoe UI",
            )),
      ),
    );
  }
}
