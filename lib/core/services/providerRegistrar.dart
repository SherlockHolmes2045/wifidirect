import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siuu_tchat/core/viewmodel/server_vm.dart';

final registerProviders = <SingleChildWidget>[
  ChangeNotifierProvider(create: (_) => ServerViewModel()),
];
