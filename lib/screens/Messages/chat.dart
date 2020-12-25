import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:siuu_tchat/custom/customAppBars/appBar3.dart';
import 'package:siuu_tchat/res/colors.dart';

class Chat extends StatefulWidget {
  final bool isRoomTalk;
  final String name;
  Chat({this.name, this.isRoomTalk});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool messageSeen = false;
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isRoomTalk
          ? PreferredSize(preferredSize: Size.fromHeight(0), child: Container())
          : PreferredSize(
              preferredSize: Size(width, height * 0.1755),
              child: AppBar3(
                title: 'Chat',
              ),
            ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                widget.isRoomTalk
                    ? Column(
                        children: [
                          SizedBox(height: height * 0.029),
                          Row(
                            children: [
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Color(0xffCCCCCC),
                                ),
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  buildSizedBoxImages('member1'),
                                  buildSizedBoxImages('member2'),
                                  buildSizedBoxImages('member3'),
                                  buildSizedBoxImages('member4'),
                                  buildSizedBoxImages('member5'),
                                  Container(
                                    height: height * 0.079,
                                    width: width * 0.131,
                                    child: Center(
                                      child: Text(
                                        "10",
                                        style: TextStyle(
                                          fontFamily: "Segoe UI",
                                          fontSize: 15,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Color(0xffFF566B),
                                        shape: BoxShape.circle),
                                  ),
                                ],
                              ),
                              Spacer()
                            ],
                          ),
                        ],
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 20, 30),
                  child: Column(
                    children: [
                      buildColumn(),
                      buildColumn(),
                      buildColumn(),
                      buildColumn(),
                      buildColumn(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.white,
              height: height * 0.175,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: height * 0.075,
                    width: width * 0.902,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: width * 0.002,
                        color: Color(0xff5b055e),
                      ),
                      borderRadius: BorderRadius.circular(26.00),
                    ),
                    child: TextFormField(
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
                  Row(
                    children: [
                      Spacer(
                        flex: 3,
                      ),
                      SvgPicture.asset('assets/svg/Camera2.svg'),
                      Spacer(),
                      SvgPicture.asset('assets/svg/mobile-phone-vibrating.svg'),
                      Spacer(),
                      SvgPicture.asset('assets/svg/wink.svg'),
                      Spacer(),
                      SvgPicture.asset('assets/svg/Voice.svg'),
                      Spacer(),
                      SvgPicture.asset('assets/svg/File.svg'),
                      Spacer(),
                      SvgPicture.asset('assets/svg/icon - send.svg'),
                      Spacer(),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox buildSizedBoxImages(String image) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height * 0.079,
      width: width * 0.131,
      child: Image.asset('assets/images/$image.png'),
    );
  }

  Column buildColumn() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildTimeText(),
        Row(
          children: [
            Image.asset('assets/images/person1.png'),
            SizedBox(width: width * 0.024),
            InkWell(
              onTap: () {
                setState(() {
                  if (messageSeen) {
                    // print('false');
                    messageSeen = false;
                  } else
                    // print('true');

                    messageSeen = true;
                });
              },
              child: messageSeen
                  ? Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildOpponentMessageContainer(),
                        SizedBox(height: height * 0.007),
                        Row(
                          children: [
                            SvgPicture.asset('assets/svg/eye.svg'),
                            SizedBox(width: width * 0.024),
                            Text(
                              widget.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Segoe UI",
                                fontSize: 11,
                                color: Color(0xff6a6a6a),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  : buildOpponentMessageContainer(),
            )
          ],
        ),
        buildTimeText(),
        SizedBox(height: height * 0.014),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: height * 0.042,
              width: width * 0.454,
              decoration: BoxDecoration(
                color: Color(0xffaaa5a5),
                borderRadius: BorderRadius.circular(15.00),
              ),
              child: Center(child: buildMessageText()),
            ),
          ],
        ),
        SizedBox(height: height * 0.014),
      ],
    );
  }

  Container buildOpponentMessageContainer() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.042,
      width: width * 0.274,
      decoration: BoxDecoration(
        gradient: linearGradient,
        borderRadius: BorderRadius.circular(15.00),
      ),
      child: Center(
        child: buildMessageText(),
      ),
    );
  }

  Text buildMessageText() {
    return Text(
      "Lorem ipsum",
      style: TextStyle(
        fontFamily: "Segoe UI",
        fontSize: 15,
        color: Color(0xffffffff),
      ),
    );
  }

  Text buildTimeText() {
    return Text(
      "LUN.,18:49",
      style: TextStyle(
        fontFamily: "Segoe UI",
        fontWeight: FontWeight.w300,
        fontSize: 14,
        color: Color(0xff5b055e),
      ),
    );
  }
}
