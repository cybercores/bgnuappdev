import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  Barcode? _lastScanned;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    setState(() {
                      _lastScanned = barcodes.last;
                    });
                    _showScannedContent(barcodes.last);
                  }
                },
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isTorchOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isTorchOn = !_isTorchOn;
                        });
                        cameraController.toggleTorch();
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.cameraswitch,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFrontCamera = !_isFrontCamera;
                        });
                        cameraController.switchCamera();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Text(
            _lastScanned?.rawValue ?? 'No QR code scanned yet',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildAdvancedControls(),
      ],
    );
  }

  Widget _buildAdvancedControls() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text(
              'Advanced Scanner Controls',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await cameraController.stop();
                  },
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await cameraController.start();
                  },
                  child: const Text('Resume'),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                  },
                  child: const Text('Analyze'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScannedContent(Barcode barcode) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scanned Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              barcode.rawValue ?? 'No content',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Format: ${barcode.format.name}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: barcode.rawValue ?? ''));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
