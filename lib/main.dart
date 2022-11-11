import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_data/flutter_camera_data.dart';
import 'dart:math' as math;

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController controller;
  late CameraImagePainter _livePicture;

  @override
  void initState() {
    super.initState();
    _livePicture = CameraImagePainter();
    controller = CameraController(_cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) {
        setState(() {
          _livePicture.setImage(image).whenComplete(() {});
        });
      });
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: const Text("This is a title")),
            body: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Transform.rotate(angle: math.pi/2, child: CustomPaint(painter: _livePicture)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Grabbed: ${_livePicture.frameCount()} (${_livePicture.width()} x ${_livePicture.height()}) FPS: ${_livePicture.fps().toStringAsFixed(2)}"),
                        ],
                      ),
                    ]
                )
            )
        )
    );
  }
}
