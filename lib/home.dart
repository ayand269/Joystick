import 'dart:convert';
import 'dart:io';
import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:control_pad/control_pad.dart';
import 'package:joystick/utils.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<WebSocket>? connection;
  int _initSpeed = 1060;
  WebSocket? socket;
  bool _socketConnected = false;
  bool _videoBtnLoading = false;
  bool _startVideo = false;

  void _connectToSocket() async {
    connection = WebSocket.connect('ws://192.168.4.1:81');
    connection!.then((value) {
      socket = value;
      setState(() {
        _socketConnected = true;
      });

      socket!.listen((event) {
        // print(event.toString());
        _processSocketData(event);
      });

      // socket!.add("Connected new");
    });
  }

  void _processSocketData(dynamic data) {
    try {
      // print(data.toString());
      Map<String, dynamic> message = jsonDecode(data);
      String _type = message['type'];
      switch (_type) {
        case "video":
          {
            setState(() {
              _videoBtnLoading = false;
              _startVideo = message['status'];
            });
          }
          break;
        default:
          {}
          break;
      }
    } catch (e) {}
  }

  void _controlSpeed(int index) {
    if (socket != null) {
      if (index == 3 && _initSpeed < 2000) {
        SpeedHandler data = SpeedHandler(_initSpeed + 10, 'SpeedControl');
        String message = jsonEncode(data);
        socket!.add(message);
        setState(() {
          _initSpeed = _initSpeed + 10;
        });
      } else if (index == 1 && _initSpeed > 1060) {
        SpeedHandler data = SpeedHandler(_initSpeed - 10, 'SpeedControl');
        String message = jsonEncode(data);
        socket!.add(message);
        setState(() {
          _initSpeed = _initSpeed - 10;
        });
      }
    }
  }

  void _disconnectSocket() {
    if (socket != null) {
      SpeedHandler data = SpeedHandler(1000, 'SpeedControl');
      String message = jsonEncode(data);
      socket!.add(message);

      AudioVideoHandler message1 = AudioVideoHandler('videoStop');
      String data1 = jsonEncode(message1);
      socket!.add(data1);

      socket!.close();
      socket = null;
      connection = null;
      setState(() {
        _socketConnected = false;
        _initSpeed = 1060;
        _startVideo = false;
        _videoBtnLoading = false;
      });
    }
  }

  void _stopMotor() {
    if (socket != null) {
      SpeedHandler data = SpeedHandler(1000, 'SpeedControl');
      String message = jsonEncode(data);
      socket!.add(message);

      setState(() {
        _initSpeed = 1060;
      });
    }
  }

  void _calibrateMotor() {
    if (socket != null) {
      Calibration calibration = Calibration("Calibrate");
      String message = jsonEncode(calibration);

      socket!.add(message);
    }
  }

  void _startStopVideo() {
    if (!_videoBtnLoading && socket != null) {
      setState(() {
        _videoBtnLoading = true;
      });
      if (_startVideo) {
        AudioVideoHandler message = AudioVideoHandler('videoStop');
        String data = jsonEncode(message);

        socket!.add(data);
      } else {
        AudioVideoHandler message = AudioVideoHandler('videoStart');
        String data = jsonEncode(message);

        socket!.add(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark
            .copyWith(statusBarColor: const Color.fromARGB(255, 228, 236, 250)),
        child: Container(
          color: const Color.fromARGB(255, 228, 236, 250),
          child: SafeArea(
              bottom: false,
              child: Column(children: [
                //Upper row
                Expanded(
                    flex: 2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                // Stop button
                                InkWell(
                                  onTap: () {
                                    _stopMotor();
                                  },
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        // border: Border.all(width: 0.1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(-4, -4),
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.75),
                                              blurRadius: 11),
                                          BoxShadow(
                                              offset: Offset(5, 5),
                                              color: Color.fromRGBO(
                                                  79, 109, 216, 0.25),
                                              blurRadius: 11)
                                        ]),
                                    child: const Text(
                                      'Stop',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                // Calibrate Button
                                InkWell(
                                  onTap: () {
                                    _calibrateMotor();
                                  },
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 228, 236, 250),
                                        // border: Border.all(width: 0.1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(-4, -4),
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.75),
                                              blurRadius: 11),
                                          BoxShadow(
                                              offset: Offset(5, 5),
                                              color: Color.fromRGBO(
                                                  79, 109, 216, 0.25),
                                              blurRadius: 11)
                                        ]),
                                    child: const Text(
                                      'Calibrate Motor',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                // Video Start Stop Button
                                InkWell(
                                  onTap: () {
                                    _startStopVideo();
                                  },
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: _startVideo
                                            ? Colors.red
                                            : const Color.fromARGB(
                                                255, 228, 236, 250),
                                        // border: Border.all(width: 0.1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5)),
                                        boxShadow: const [
                                          BoxShadow(
                                              offset: Offset(-4, -4),
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.75),
                                              blurRadius: 11),
                                          BoxShadow(
                                              offset: Offset(5, 5),
                                              color: Color.fromRGBO(
                                                  79, 109, 216, 0.25),
                                              blurRadius: 11)
                                        ]),
                                    child: _videoBtnLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ))
                                        : Icon(
                                            _startVideo
                                                ? Icons.stop_rounded
                                                : Icons.videocam,
                                            color: _startVideo
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                  ),
                                ),
                                // Click Picture button
                                InkWell(
                                  onTap: () {
                                    // _calibrateMotor();
                                  },
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 228, 236, 250),
                                        // border: Border.all(width: 0.1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(-4, -4),
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.75),
                                              blurRadius: 11),
                                          BoxShadow(
                                              offset: Offset(5, 5),
                                              color: Color.fromRGBO(
                                                  79, 109, 216, 0.25),
                                              blurRadius: 11)
                                        ]),
                                    child: Icon(Icons.camera_alt),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Expanded(flex: 1, child: Container()),

                        // Socket connection disconnection button
                        InkWell(
                          onTap: () {
                            if (_socketConnected) {
                              _disconnectSocket();
                            } else {
                              _connectToSocket();
                            }
                          },
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                                color: _socketConnected
                                    ? Colors.red
                                    : const Color.fromARGB(255, 228, 236, 250),
                                // border: Border.all(width: 0.1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                boxShadow: const [
                                  BoxShadow(
                                      offset: Offset(-4, -4),
                                      color:
                                          Color.fromRGBO(255, 255, 255, 0.75),
                                      blurRadius: 11),
                                  BoxShadow(
                                      offset: Offset(5, 5),
                                      color: Color.fromRGBO(79, 109, 216, 0.25),
                                      blurRadius: 11)
                                ]),
                            child: Text(
                              _socketConnected
                                  ? 'Disconnect'
                                  : 'Connect to Socket',
                              style: TextStyle(
                                  color: _socketConnected
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        )
                      ],
                    )),

                // Lower Row
                Expanded(
                    flex: 3,
                    child: Row(
                      children: <Widget>[
                        // Button Pad
                        Expanded(
                          flex: 1,
                          child: PadButtonsView(
                            size: 180,
                            buttons: const [
                              PadButtonItem(
                                  index: 0,
                                  buttonIcon: Icon(Icons.chevron_right_rounded),
                                  supportedGestures: [
                                    Gestures.TAP,
                                    Gestures.LONGPRESS
                                  ]),
                              PadButtonItem(
                                  index: 1,
                                  buttonIcon:
                                      Icon(Icons.keyboard_arrow_down_rounded),
                                  supportedGestures: [
                                    Gestures.TAP,
                                    Gestures.LONGPRESS
                                  ]),
                              PadButtonItem(
                                  index: 2,
                                  buttonIcon: Icon(Icons.chevron_left_rounded),
                                  supportedGestures: [
                                    Gestures.TAP,
                                    Gestures.LONGPRESS
                                  ]),
                              PadButtonItem(
                                  index: 3,
                                  buttonIcon:
                                      Icon(Icons.keyboard_arrow_up_rounded),
                                  supportedGestures: [
                                    Gestures.TAP,
                                    Gestures.LONGPRESS
                                  ])
                            ],
                            padButtonPressedCallback: (buttonIndex, gesture) {
                              _controlSpeed(buttonIndex);
                            },
                          ),
                        ),

                        // Speedometer
                        Container(
                          height: 150,
                          width: 200,
                          // color: Colors.red,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                  minimum: 1000,
                                  maximum: 2000,
                                  labelOffset: 15,
                                  axisLineStyle: const AxisLineStyle(
                                      thicknessUnit: GaugeSizeUnit.factor,
                                      thickness: 0.03),
                                  majorTickStyle: const MajorTickStyle(
                                      length: 6,
                                      thickness: 4,
                                      color: Colors.black54),
                                  minorTickStyle: const MinorTickStyle(
                                      length: 3,
                                      thickness: 3,
                                      color: Colors.black54),
                                  axisLabelStyle: const GaugeTextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8),
                                  ranges: <GaugeRange>[
                                    GaugeRange(
                                        startValue: 1000,
                                        endValue: 2000,
                                        sizeUnit: GaugeSizeUnit.factor,
                                        startWidth: 0.03,
                                        endWidth: 0.03,
                                        gradient: const SweepGradient(
                                            colors: <Color>[
                                              Colors.green,
                                              Colors.yellow,
                                              Colors.red
                                            ],
                                            stops: <double>[
                                              0.0,
                                              0.5,
                                              1
                                            ]))
                                  ],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(
                                        value: _initSpeed.toDouble(),
                                        needleLength: 0.95,
                                        enableAnimation: true,
                                        animationType: AnimationType.ease,
                                        needleStartWidth: 1.5,
                                        needleEndWidth: 6,
                                        needleColor: Colors.red,
                                        knobStyle: const KnobStyle(
                                            knobRadius: 0.09,
                                            color: Colors.black87))
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Column(children: <Widget>[
                                          Text(_initSpeed.toString(),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold)),
                                          // SizedBox(height: 20),
                                          const Text('µ Second',
                                              style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                        angle: 90,
                                        positionFactor: 1.63)
                                  ]),
                            ],
                          ),
                        ),

                        //Joystick Pad
                        Expanded(
                            flex: 1,
                            child: JoystickView(
                              size: 180,
                              onDirectionChanged: (degrees, distance) {
                                print("degrees1 =>>>>>" + degrees.toString());
                                print("distance1 =>>>>>" + distance.toString());
                              },
                              // size: 100,
                            )),
                      ],
                    )),
              ])),
        ),
      ),
    );
  }
}
