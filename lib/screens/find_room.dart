import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FindRoom extends StatefulWidget {
  @override
  _FindRoomState createState() => _FindRoomState();
}

class _FindRoomState extends State<FindRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(
              Icons.add
            ),
            heroTag: null,
          ),
          FloatingActionButton(
            child: Icon(
              Icons.arrow_forward
            ),
            heroTag: null,
          )
        ],
      ),
    );
  }
}
