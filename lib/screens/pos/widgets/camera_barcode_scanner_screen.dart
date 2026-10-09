import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraBarcodeScannerScreen extends StatefulWidget {
  final bool continuous; // true para escanear múltiples artículos seguidos en POS
  final ValueChanged<String>? onBarcodeScanned;
  final String title;

  const CameraBarcodeScannerScreen({
    super.key,
    this.continuous = false,
    this.onBarcodeScanned,
    this.title = 'Lector de Códigos de Barra',
  });

  @override
  State<CameraBarcodeScannerScreen> createState() => _CameraBarcodeScannerScreenState();
}

class _CameraBarcodeScannerScreenState extends State<CameraBarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  late bool _continuous;
  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime? _lastScannedTime;
  int _scannedCount = 0;

  @override
  void initState() {
    super.initState();
    _continuous = widget.continuous;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) return;

    final now = DateTime.now();
    // Evitar lecturas duplicadas en menos de 1.5s del mismo código
    if (_lastScannedCode == code &&
        _lastScannedTime != null &&
        now.difference(_lastScannedTime!).inMilliseconds < 1500) {
      return;
    }

    _lastScannedCode = code;
    _lastScannedTime = now;
    _isProcessing = true;

    HapticFeedback.heavyImpact();

    // Notificar al callback si existe
    widget.onBarcodeScanned?.call(code);

    if (!_continuous) {
      Navigator.pop(context, code);
    } else {
      setState(() {
        _scannedCount++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Escaneado #$_scannedCount: $code',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1400),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Esperar brevemente antes de aceptar el siguiente escaneo
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
              _continuous ? 'Modo continuo: escanea varios productos' : 'Apunta al código para registrarlo',
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          // Toggle Linterna / Flash
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              if (!state.isInitialized || !state.isRunning) {
                return const SizedBox.shrink();
              }
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                tooltip: isOn ? 'Apagar Linterna' : 'Encender Linterna',
                icon: Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                  color: isOn ? Colors.amber : Colors.white,
                ),
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
          // Cambiar Cámara (frontal / trasera)
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              if (!state.isInitialized || !state.isRunning) {
                return const SizedBox.shrink();
              }
              final int? cameras = state.availableCameras;
              if (cameras != null && cameras < 2) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Cambiar Cámara',
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                onPressed: () => _controller.switchCamera(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Vista previa de cámara
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_off_outlined, color: Colors.white70, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'No se pudo inicializar la cámara:\n${error.errorDetails?.message ?? error.errorCode}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard, size: 18),
                        label: const Text('Ingresar manualmente / Pistola USB'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Retícula láser de enfoque
          Center(
            child: Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF22C55E), width: 2.5),
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 2,
                      width: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.85),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra superior de modo (Continuo vs 1 producto)
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _continuous = !_continuous),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _continuous ? const Color(0xFF4F46E5) : const Color(0x99000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _continuous ? Icons.repeat : Icons.looks_one,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _continuous ? 'Modo continuo activo' : 'Modo 1 escaneo',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra inferior informativa y botón de salir
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner, color: Color(0xFF22C55E), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _continuous
                              ? 'Escanea códigos continuamente sin salir. Total agregados: $_scannedCount'
                              : 'Coloca el código de barras en el recuadro verde.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_continuous) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check, color: Colors.white, size: 20),
                      label: Text(
                        'Listo / Volver a la cuenta ($_scannedCount escaneados)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
