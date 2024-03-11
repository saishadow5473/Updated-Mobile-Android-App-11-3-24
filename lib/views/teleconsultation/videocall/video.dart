/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ihl/widgets/teleconsulation/exports.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool loading;
  bool muted = true;
  bool frontCam = true;
  bool camOff = false;
  bool chat = false;
  CameraController _controller;
  List<CameraDescription> cameras;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _initCamFuture;
  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    onJoining();
  }

  Future<void> onJoining() async {
    await _handleCameraAndMic();
    _initApp();
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  _initApp() async {
    cameras = await availableCameras();
    final firstCam = cameras[1];
    print(cameras);
    _controller = CameraController(
      firstCam,
      ResolutionPreset.medium,
    );
    _initCamFuture = _controller.initialize();
    new Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

//200:130
  Widget _livecam() {
    var ht = MediaQuery.of(context).size.height;
    var wt = MediaQuery.of(context).size.width;
    return NativeDeviceOrientationReader(
        useSensor: true,
        builder: (context) {
          final orientation =
              NativeDeviceOrientationReader.orientation(context);
          return Visibility(
            visible: camOff == false,
            maintainState: true,
            child: Stack(children: <Widget>[
              ClippedVideo(
                height:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? ht / 2.8
                        : ht / 3.2,
                width:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? wt / 3.8
                        : wt / 2.8,
                child: Container(
                  color: Colors.white,
                  child: loading == false
                      ? RotatedBox(
                          quarterTurns: orientation ==
                                  NativeDeviceOrientation.landscapeLeft
                              ? 3
                              : orientation ==
                                      NativeDeviceOrientation.landscapeRight
                                  ? 1
                                  : 0,
                          child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: CameraPreview(_controller)))
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ),
              /*MediaQuery.of(context).orientation == Orientation.landscape
            ? Container(
                margin: const EdgeInsets.only(top: 80, left: 130),
                child: RawMaterialButton(
                  onPressed: () {
                    _onCameraSwitch();
                  },
                  child: Icon(
                    frontCam
                        ? Icons.camera_front_rounded
                        : Icons.camera_rear_rounded,
                    color: frontCam ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: frontCam ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(top: 150, left: 60),
                child: RawMaterialButton(
                  onPressed: () {
                    _onCameraSwitch();
                  },
                  child: Icon(
                    frontCam
                        ? Icons.camera_front_rounded
                        : Icons.camera_rear_rounded,
                    color: frontCam ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: frontCam ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              ),*/
            ]),
          );
        });
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: 40, minHeight: 45),
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 15.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: 40, minHeight: 45),
            onPressed: () {
              _onCameraSwitch();
            },
            child: Icon(
              frontCam ? Icons.camera_front : Icons.camera_rear,
              color: Colors.blueAccent,
              size: 15.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: 60, minHeight: 60),
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: 40, minHeight: 45),
            onPressed: () {
              setState(() {
                chat = !chat;
              });
              chatbox();
            },
            child: Icon(
              Icons.message,
              color: chat ? Colors.white : Colors.blueAccent,
              size: 15.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: chat ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
          ),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: 40, minHeight: 45),
            onPressed: _onexitCamera,
            child: Icon(
              camOff ? Icons.videocam_off : Icons.videocam,
              color: camOff ? Colors.white : Colors.blueAccent,
              size: 15,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: camOff ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
          ),
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onCameraSwitch() async {
    setState(() {
      frontCam = !frontCam;
    });
    final CameraDescription cameraDescription =
        (_controller.description == cameras[1]) ? cameras[0] : cameras[1];
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onToggleMute() async {
    setState(() {
      muted = !muted;
    });
    final enableaudio = (muted == true) ? false : true;
    if (_controller != null) {
      await _controller.dispose();
    }
    final CameraDescription cameraDescription =
        (_controller.description == cameras[1]) ? cameras[1] : cameras[0];
    _controller = CameraController(cameraDescription, ResolutionPreset.medium,
        enableAudio: enableaudio);
    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  void _onexitCamera() {
    setState(() {
      camOff = !camOff;
    });
  }

  void chatbox() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.face),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Hello, This Doctor!',
                        ),
                        Spacer(),
                        IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Hi, Doctor!',
                          suffix: IconButton(
                              icon: Icon(Icons.send), onPressed: () {}),
                          suffixIcon: Padding(
                            padding:
                                const EdgeInsetsDirectional.only(end: 12.0),
                            child: Icon(Icons.attach_file),
                          )),
                      autofocus: true,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    var ht = MediaQuery.of(context).size.height;
    var wt = MediaQuery.of(context).size.width;
    return new WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                content: Text('Are you sure you want to exit the call?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Yes, exit'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });
        return value == true;
      },
      child: SafeArea(
        top: true,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.black,
          body: FutureBuilder<void>(
            future: _initCamFuture,
            builder: (context, snapshot) {
              //if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Stack(
                  children: <Widget>[
                    Container(
                        color: Colors.grey,
                        child: Center(child: Icon(Icons.video_call))),
                    Positioned(
                      top: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? ht / 2
                          : ht / 2.13,
                      left: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? wt / 1.4
                          : wt / 1.7,
                      child: _livecam(),
                    ),
                    _toolbar(),
                  ],
                ),
              );
              /* } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
                Positioned(
                      top: 300,
                      left: 215,
                      child: _livecam(),
                    ),
              } */
            },
          ),
        ),
      ),
    );
  }
}*/
