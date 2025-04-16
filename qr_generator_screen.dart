import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String _qrData = 'Enter text to generate QR';
  Color _qrColor = Colors.black;
  Color _backgroundColor = Colors.white;
  int _qrVersion = QrVersions.auto;
  double _qrSize = 200;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Enter text or URL',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.edit),
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _qrData = value.isEmpty ? 'Enter text to generate QR' : value;
                _hasError = false;
              });
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: RepaintBoundary(
              key: _qrKey,
              child: QrImageView(
                data: _qrData,
                version: _qrVersion,
                size: _qrSize,
                gapless: true,
                backgroundColor: _backgroundColor,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _qrColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: _qrColor,
                ),
                errorStateBuilder: (cxt, err) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _hasError = true;
                      });
                    }
                  });
                  return const Center(
                    child: Text(
                      'Error generating QR',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          if (_hasError)
            const Text(
              'Error: Content too large for QR version',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),
          _buildAdvancedControls(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveQrCode,
            child: const Text('Save QR Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Generator Options',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('QR Color:'),
                const SizedBox(width: 10),
                _ColorPickerButton(
                  initialColor: _qrColor,
                  onColorChanged: (color) {
                    setState(() {
                      _qrColor = color;
                    });
                  },
                ),
                const SizedBox(width: 20),
                const Text('Background:'),
                const SizedBox(width: 10),
                _ColorPickerButton(
                  initialColor: _backgroundColor,
                  onColorChanged: (color) {
                    setState(() {
                      _backgroundColor = color;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('QR Version:'),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _qrVersion,
                  items: [
                    for (int i = 1; i <= 40; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text('$i'),
                      ),
                    const DropdownMenuItem(
                      value: QrVersions.auto,
                      child: Text('Auto'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _qrVersion = value ?? QrVersions.auto;
                      _hasError = false;
                    });
                  },
                ),
                const SizedBox(width: 20),
                const Text('Size:'),
                const SizedBox(width: 10),
                Slider(
                  value: _qrSize,
                  min: 100,
                  max: 300,
                  divisions: 4,
                  label: _qrSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _qrSize = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQrCode() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !mounted) return;

      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code ready to save')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save QR: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class _ColorPickerButton extends StatelessWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerButton({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final color = await showDialog<Color>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: initialColor,
                onColorChanged: onColorChanged,
                availableColors: const [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                  Colors.black,
                  Colors.white,
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, initialColor),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (color != null) {
          onColorChanged(color);
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: initialColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
