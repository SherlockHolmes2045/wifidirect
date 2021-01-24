import 'package:flutter/material.dart';
import 'package:siuu_tchat/database/chat_dao.dart';
import 'package:siuu_tchat/database/discussion_dao.dart';
import 'package:siuu_tchat/model/chat.dart';
import 'package:siuu_tchat/model/discussion.dart';
import 'package:siuu_tchat/utils/message_type.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<Chat> chats = new List<Chat>();
  ChatDao chatDao = new ChatDao();
  List<Map<String, dynamic>> savedChats = new List<Map<String, dynamic>>();
  
    DiscussionDao discussionDao = new DiscussionDao();
    List<Discussion> messages = List<Discussion>();

    /*discussionDao.getAll(chatId).then((value){
      messages = value;
      messages.forEach((element) {
        print(element.type);
        switch (element.type) {
          case "image":
            {
              Map<String, dynamic> chatMessageMap = {
                "sendBy": element.sendBy,
                "message": element.message,
                "time": element.time,
                "type": Status.IMAGE,
                "path": element.path,
                "byte": element.byte
              };
              savedChats.add(chatMessageMap);
            }
            break;
          case "text":
            {
              Map<String, dynamic> chatMessageMap = {
                "sendBy": element.sendBy,
                "message": element.message,
                "time": DateTime.now().millisecondsSinceEpoch,
                "type": Status.TEXT,
                "path": element.path,
                "byte": element.byte
              };
              savedChats.add(chatMessageMap);
            }
            break;
        }
      });
    });*/

  @override
  void initState() {
    getAllChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
             // getMessagesForChat(chats[index].chatId);
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
                    savedChats[savedChats.length-1]["message"],
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
      setState(() {
        chats = value;
      });
    });
    return data;
  }
}
