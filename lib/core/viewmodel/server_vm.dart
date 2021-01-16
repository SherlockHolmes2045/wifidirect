import 'dart:io';
import 'dart:convert' show json, utf8;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_ip/get_ip.dart';
import 'package:siuu_tchat/core/model/message.dart';
import 'package:siuu_tchat/core/model/tcpData.dart';
import 'package:siuu_tchat/screens/roomtalk.dart';

class ServerViewModel extends ChangeNotifier {
  List<Message> _messageList = [];
  List<Message> get messageList => _messageList;
  String errorMessage = '';

  ServerSocket _server;
  ServerSocket get server => _server;

  Socket _socket;
  Socket get socket => _socket;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  final TextEditingController ip = new TextEditingController();
  final TextEditingController port = new TextEditingController();
  final TextEditingController name = new TextEditingController();
  final TextEditingController msg = new TextEditingController();

  set server(ServerSocket val) {
    _server = val;
    notifyListeners();
  }

  set socket(Socket val) {
    _socket = val;
    notifyListeners();
  }

  void initState() async {
    if (!Platform.isMacOS) {
      ip.text = await GetIp.ipAddress;
    } else {
      ip.text = '';
    }

    port.text = "4000";
    errorMessage = '';
  }

  getTCPData() {
    return TCPData(ip: ip.text, port: int.parse(port.text), name: name.text);
  }

  void startServer(context,String ipAdress,String portNumber,String userName) async {

    /*if (ip.text == null || ip.text.isEmpty) {
      errorMessage = "IP Address cant be empty!";
      print("here");
      //notifyListeners();
    } else if (port.text == null || port.text.isEmpty) {
      errorMessage = "Port cant be empty!";
      //notifyListeners();
    } else if (name.text == null || name.text.isEmpty) {
      errorMessage = "Name cant be empty!";
      //notifyListeners();
    } else {*/
      errorMessage = "";
      //notifyListeners();
      try {
        port.text = portNumber;
        ip.text = ipAdress;
        name.text = userName;
        _server = await ServerSocket.bind(ip.text, int.parse(port.text),
            shared: true);
        //notifyListeners();

        if (_server != null) {
          _server.listen((Socket _) {
            _socket = _;
            _.listen((List<int> data) {
              try {
                String result = new String.fromCharCodes(data);

                if (result.contains('name')) {
                  var message = Message.fromJson(json.decode(result));
                  _messageList.insert(
                      0,
                      Message(
                          message: message.message,
                          name: message.name,
                          user: message.ip == getTCPData().ip ? 0 : 1));
                  notifyListeners();
                }
                _.add(data);
              } catch (e) {
                print(e.toString());
              }
              notifyListeners();
            });
          });

          print('Started: ${server.address.toString()}');
          print(ip.text);
          connectToServer(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoomTalk(tcpData: getTCPData(),
              isHost: true,) ),
          );
        }
      } catch (e) {
        print(e.toString());
      }
    //}
  }

  connectToServer(context, {bool isHost = true}) async {
    if (ip.text == null || ip.text.isEmpty) {
      errorMessage = "IP Address cant be empty!";
      notifyListeners();
    } else if (port.text == null || port.text.isEmpty) {
      errorMessage = "Port cant be empty!";
      notifyListeners();
    } else if (name.text == null || name.text.isEmpty) {
      errorMessage = "Name cant be empty!";
      notifyListeners();
    } else {
      try {
        _isLoading = true;
       // notifyListeners();
        _socket = await Socket.connect(ip.text, int.parse(port.text))
            .timeout(Duration(seconds: 1), onTimeout: () {
          throw "TimeOUt";
        });
       // notifyListeners();
        // listen to the received data event stream
        String ipAddress = await GetIp.ipAddress;
        _socket.listen((List<int> data) {
          try {
            String result = new String.fromCharCodes(data);

            if (result.contains('name')) {
              var message = Message.fromJson(json.decode(result));

              _messageList.insert(
                  0,
                  Message(
                      message: message.message,
                      name: message.name,
                      user: ipAddress == message.ip ? 0 : 1));
              notifyListeners();
            }
          } catch (e) {
            print(e.toString());
          }
        });
        print('connected');
        if (!isHost)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoomTalk(tcpData: TCPData(
                ip: ip.text, port: int.parse(port.text), name: name.text),)
          ));
        _isLoading = false;
       // notifyListeners();
      } catch (e) {
        _isLoading = false;
        //notifyListeners();
        //showErrorDialog(context, error: e.toString());
        print(e.toString());
      }
    }
  }

  closeSocket() async {
    await _socket.close();
  }

  void sendMessage(context, TCPData tcpData, {bool isHost}) async{
    /* _messageList.insert(
        0, new Message(message: msg.text, user: 0, userID: null)); */
    print(ip.text + " " + getTCPData().ip);
    messageList.forEach((element) {
      print(element.toJson());
    });
    String senderIp = "";
    if (!Platform.isMacOS) senderIp = await GetIp.ipAddress;
    print(senderIp);
    var message = utf8.encode(json.encode(
        Message(message: msg.text, name: tcpData?.name ?? '',ip: senderIp).toJson()));

    if (isHost) {
      print("host");
      _messageList.insert(
        0,
        Message(message: msg.text, name: tcpData?.name,user: 0),
      );
      notifyListeners();
    }

    try {
      _socket.add(message);

      msg.clear();
    } catch (e) {
      //showErrorDialog(context, error: e.toString());
      print(e.toString());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    closeSocket();
    _server.close();
    super.dispose();
  }

}
