import 'package:flutter/material.dart';
import 'package:siuu_tchat/playground.dart';
import 'package:siuu_tchat/screens/Messages/Message.dart';
import 'package:siuu_tchat/screens/Messages/chat.dart';
import 'package:siuu_tchat/screens/splashScreen.dart';
import 'BNB.dart';
import 'screens/Messages/loader.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/messages':
        return MaterialPageRoute(builder: (_) => Message());
      case '/chat':
        final Chat argss = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => Chat(
            name: argss.name,
            isRoomTalk: argss.isRoomTalk,
          ),
        );
      case '/loader':
        final Loader argss = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => Loader(
            name: argss.name,
            isRoomTalk: argss.isRoomTalk,
          ),
        );
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
