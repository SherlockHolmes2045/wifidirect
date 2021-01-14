import 'package:flutter/material.dart';

class Message {
  //Message content
  String message;
  //User who sent message, 0-current user, 1-other user
  int user;
  String name;
  bool isBold;
  String ip;

  Message({
    @required this.message,
    this.user,
    this.name,
    this.isBold = false,
    this.ip
  });

  Message.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    name = json['name'];
    ip = json['ip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['name'] = this.name;
    data['ip'] = this.ip;
    return data;
  }
}
