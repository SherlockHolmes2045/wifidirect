import 'package:flutter/material.dart';
import 'package:siuu_tchat/model/Device.dart';
import 'package:siuu_tchat/database/chat_dao.dart';
import 'package:siuu_tchat/model/chat.dart' as chatModel;
import 'package:flutter/services.dart';
import 'package:siuu_tchat/screens/Messages/chat_custom.dart';

class RadarGroup extends StatefulWidget {
  List<String> groups = new List<String>();
  Widget buttonSearch;
  bool isSearching;
  var provider;
  String userIp;
  RadarGroup(this.groups,this.buttonSearch,this.isSearching,this.provider,this.userIp);
  @override
  _RadarGroupState createState() => _RadarGroupState();
}

class _RadarGroupState extends State<RadarGroup> {
  String img = "assets/images/person1.png";
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  List<Widget> peers = new List<Widget>();
  int start = 2;

  List<Widget> buildPeers(double size) {
    peers = [];
    start = 2;
    setState(() {
      peers.add(
        Container(
          height: size,
        ),
      );
      peers.add(
        RadarCircle(1.0),
      );
      peers.add(
        RadarCircle(0.8),
      );
      peers.add(
        RadarCircle(0.6),
      );
      peers.add(
        RadarCircle(0.25),
      );
      peers.add(
        Positioned(
          top: size / 2,
          child: Container(
            width: size,
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      );
      peers.add(
        Positioned(
          left: (size - 16) / 2,
          top: 8,
          child: Container(
            height: size - 16,
            width: 1,
            color: Colors.grey[200],
          ),
        ),
      );
      peers.add(
        Positioned(
          top: size / 2 - 20,
          left: (size - 16) / 2 - 20,
          child: widget.isSearching ?
          CircularProgressIndicator() : widget.buttonSearch,
        ),
      );
    });
    if (widget.groups != null)
      widget.groups.forEach((element) {
        setState(() {
          peers.add(
               Positioned(
                  top: size / start,
                  left: size / 4,
                  child: InkWell(
                    onTap: (){
                      widget.provider.ip.text = element;
                      widget.provider.port.text = "4000";
                      widget.provider.name.text = "test";
                      widget.provider.connectToServer(context, isHost: false);
                    },
                    child: Pic(
                      image: img,
                      color: Colors.orange,
                    ),
                  ),
               ),
          );
        });
        start += 4;
      });
    return peers;
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width - 16;
    double height = MediaQuery.of(context).size.height - 32;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Stack(
              children: buildPeers(size),
            ),
          ),
        ),
      ),
    );
  }
}

class Pic extends StatelessWidget {
  final String image;
  final Color color;

  Pic({this.image, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        child: Image.asset(image),
      ),
    );
  }
}

class RadarCircle extends StatelessWidget {
  final double factor;

  RadarCircle(this.factor);

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width - 16;
    return Positioned(
      top: size * (1 - factor) / 2,
      left: size * (1 - factor) / 2,
      bottom: size * (1 - factor) / 2,
      right: size * (1 - factor) / 2,
      child: Container(
        width: size * factor,
        height: size * factor,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}
