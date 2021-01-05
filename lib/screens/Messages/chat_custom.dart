import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:siuu_tchat/custom/customAppBars/appBar3.dart';

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
            height: MediaQuery.of(context).size.height/1.42,
            child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: chats[index]["message"],
                    sendByMe: chats[index]["sendBy"],
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

  addMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": true,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      await platform.invokeMethod(
          "sendMessage", {"message": messageEditingController.text});
      setState(() {
        chats.add(chatMessageMap);
        messageEditingController.text = "";
      });
    }
  }

  pushReceivedMessage(String message) {
    Map<String, dynamic> chatMessageMap = {
      "sendBy": false,
      "message": message,
      'time': DateTime.now().millisecondsSinceEpoch,
    };
    setState(() {
      chats.add(chatMessageMap);
    });
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
    chats.add({
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
    });
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
                          style: TextStyle(color: Colors.white, fontSize: 15.0),
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
                        addMessage();
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

  void _disableTimer() {
    if (_timerSubscription != null) {
      _timerSubscription.cancel();
      _timerSubscription = null;
    }
  }

  void _updateTimer(timer) {
    debugPrint("Timer $timer");
    pushReceivedMessage(timer);
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
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe
                  ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                  : [
                      const Color(0xFF3366FF),
                      const Color(0xFF00CCFF),
                    ],
            )),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
