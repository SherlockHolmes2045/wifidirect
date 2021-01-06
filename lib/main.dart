import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siuu_tchat/route_generator.dart';
import 'package:provider/provider.dart';
import 'core/services/providerRegistrar.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      runApp(
        MyApp(),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            return MultiProvider(
              providers: registerProviders,
              child:  MaterialApp(
                initialRoute: '/',
                onGenerateRoute: RouteGenerator.generateRoute,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.purple,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
              )
            );
          },
        );
      },
    );
  }
}
