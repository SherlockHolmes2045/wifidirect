import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Device.dart';
import 'events.dart';
import 'package:gson/gson.dart';

class Playground extends StatefulWidget {
  Playground({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  static const platform = const MethodChannel('samples.flutter.dev/battery');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission(Permission.location);
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Press button to run playground"),
              Text("-"),
              Text(logs),
              FlatButton(
                  onPressed: ()async{
                    await platform.invokeMethod('discover');
                  },
                  child: Text(
                    "discover"
                  )
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: runPlayground,
          tooltip: 'Run Playground',
          child: Icon(Icons.play_arrow),
        )
    );
  }

  /////////////// Playground ///////////////////////////////////////////////////
  String logs = " ";

  // Call inside a setState({ }) block to be able to reflect changes on screen
  void log(String logString) {
    logs += logString.toString() + "\n";
  }

  // Main function called when playground is run
  bool running = false;
  void runPlayground() async {
    if (running) return;
    running = true;

    var cancel = startListening((msg) async{
      if(msg != null){
        Map<dynamic,dynamic> result = await  platform.invokeMethod('getDevices');

        List<Device> devices = result.entries.map((element) => Device(element.key['name'],element.value["address"])).toList();
        print("from flutter" + devices.toString());
      }

      setState(() {
        //log(msg);
      });
    });

    await Future.delayed(Duration(seconds: 4));

    cancel();

    running = false;
  }
  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
  }
}