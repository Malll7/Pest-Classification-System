// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'navigatepestname.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final picker = ImagePicker();
  String _result = 'No image selected';
  late Interpreter _interpreter;
  List<String>? _classNames;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadClassNames();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/pest_model.tflite');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> _loadClassNames() async {
    _classNames = [
      'aphid',
      'armyworm',
      'beetle',
      'mite',
      'sawfly',
      'stem borer',
      'stemfly'
    ];
  }

  Future<void> _takeImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = 'Processing image...';
        _predictImage();
      });
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = 'Processing image...';
        _predictImage();
      });
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _result = 'No image selected';
    });
  }

  Future<void> _predictImage() async {
    if (_image == null) {
      setState(() {
        _result = 'Model not loaded or no image selected';
      });
      return;
    }

    final image = img.decodeImage(_image!.readAsBytesSync())!;
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    final input = imageToByteListFloat32(resizedImage, [1, 224, 224, 3], 127.5, 1.0);

    final outputShape = _interpreter.getOutputTensor(0).shape;
    final output = List.filled(outputShape[1], 0.0).reshape([1, outputShape[1]]);

    _interpreter.run(input, output);

    final outputList = output[0] as List<double>;
    final maxValue = outputList.reduce((a, b) => a > b ? a : b);
    final predictedIndex = outputList.indexOf(maxValue);

    if (predictedIndex < _classNames!.length) {
      setState(() {
        _result = 'Prediction: ${_classNames![predictedIndex]}';
      });
    } else {
      setState(() {
        _result = 'Prediction: Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if (_image != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          final pestName = _result.split('Prediction: ')[1];
                          final navigatePest = navigatepestname(context);
                          navigatePest.handlePestClick(pestName);
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Prediction: ',
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: _result.split('Prediction: ')[1],
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30.0)),
            ),
            child: Column(
              children: [
                _buildModernButton('Take Image', Icons.camera_alt, _takeImage),
                const SizedBox(height: 16.0),
                _buildModernButton('Upload Image', Icons.upload, _uploadImage),
                const SizedBox(height: 16.0),
                _buildModernButton('Clear Image', Icons.clear, _clearImage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(
      String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24.0, color: Colors.black),
        label: Text(text,
            style: const TextStyle(fontSize: 16.0, color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 6,
        ),
      ),
    );
  }

  Uint8List imageToByteListFloat32(
      img.Image image, List<int> inputShape, double mean, double std) {
    final byteData = ByteData(inputShape.reduce((a, b) => a * b) * 4);
    int offset = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = img.getRed(pixel) / mean - std;
        final g = img.getGreen(pixel) / mean - std;
        final b = img.getBlue(pixel) / mean - std;

        byteData.setFloat32(offset, r, Endian.little);
        byteData.setFloat32(offset + 4, g, Endian.little);
        byteData.setFloat32(offset + 8, b, Endian.little);

        offset += 12;
      }
    }
    return byteData.buffer.asUint8List();
  }
}