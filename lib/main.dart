import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joystick/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(App());
  });
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {'/': (context) => Home()},
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:control_pad/control_pad.dart';

// void main() {
//   runApp(ExampleApp());
// }

// class ExampleApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Control Pad Example',
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Control Pad Example'),
//       ),
//       body: Container(
//         child: JoystickView(),
//       ),
//     );
//   }
// }
