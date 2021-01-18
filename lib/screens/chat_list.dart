import 'package:flutter/material.dart';
import 'package:siuu_tchat/database/chat_dao.dart';
import 'package:siuu_tchat/model/chat.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<Chat> chats = new List<Chat>();
  ChatDao chatDao = new ChatDao();


  @override
  void initState() {
    getAllChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllChats();
    });*/
    return Scaffold(
        body: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  leading: Image.asset('assets/images/person1.png'),
                  title: Text(
                    chats[index].receiverName,
                    style: TextStyle(
                      fontFamily: "Segoe UI",
                      fontSize: 18,
                      color: Color(0xff5e5e5e),
                    ),
                  ),
                  subtitle: Text(
                    "Dernier message du chat",
                    style: TextStyle(
                      fontFamily: "Segoe UI",
                      fontWeight: FontWeight.w300,
                      fontSize: 17,
                      color: Color(0xffaaa5a5),
                    ),
                  ),
                  trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Now",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: "Segoe UI",
                            fontSize: 13,
                            color: Color(0xff5e5e5e),
                          ),
                        ),
                      ]));
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
            itemCount: chats.length));
  }

  getAllChats() async {
    List<Chat> data = new List<Chat>();
    chatDao.getAll().then((value) {
      print(value[0].receiverName);
      setState(() {
        chats = value;
      });
    });
    return data;
  }
}
