import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rtena_app/camera_prev_page.dart';

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> cameraValue;
  late File image;

  int camDirection = 0;

  bool _isFlashOn = false;
  bool _isFlipped = false;

  void toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void flipCamera() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  void initState() {
    startCamera(camDirection);
    super.initState();
  }

  void startCamera(int camDirection) async {
    _cameraController = CameraController(
      cameras[camDirection],
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
    _cameraController.initialize().then((_) {
      setState(() {});
      if (!mounted) {
        return;
      }
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: [
          Transform.scale(
            scale: 1.5,
            child: GestureDetector(
              onDoubleTap: () async {
                camDirection = _isFlipped ? 0 : 1;
                flipCamera();
                startCamera(camDirection);
              },
              child: AspectRatio(
                aspectRatio: 1 / _cameraController.value.aspectRatio,
                child: CameraPreview(_cameraController),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 40.0),
                //Button selection row
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: _isFlashOn
                          ? Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 30,
                            )
                          : Icon(
                              Icons.flash_off,
                              color: Colors.white,
                              size: 30,
                            ),
                      onPressed: () async {
                        toggleFlash();
                        _isFlashOn
                            ? _cameraController.setFlashMode(FlashMode.torch)
                            : _cameraController.setFlashMode(FlashMode.off);
                        ;
                      },
                    ),
                    InkWell(
                      child: Icon(
                        Icons.panorama_fish_eye,
                        color: Colors.white,
                        size: 70,
                      ),
                      onTap: () async {
                        if (!_cameraController.value.isInitialized) {
                          return null;
                        }
                        if (_cameraController.value.isTakingPicture) {
                          return null;
                        }
                        _isFlashOn
                            ? _cameraController.setFlashMode(FlashMode.torch)
                            : _cameraController.setFlashMode(FlashMode.off);
                        ;
                        XFile image = await _cameraController.takePicture();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImagePreview(image)));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.landscape,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
