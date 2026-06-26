import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pinlink/coreFeature/scanner/cubit/scanner_state.dart';
import 'package:pinlink/coreFeature/scanner/models/inspection_item.dart';
import 'package:pinlink/coreFeature/scanner/services/file_service.dart';

class ScannerCubit extends Cubit<ScannerState> {
  final MobileScannerController barcodeController = MobileScannerController();
  CameraController? cameraController;
  final TextRecognizer textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  String? latestBarcode;
  String? _persistedFilePath;

  final Map<String, int> _scanSamples = {};
  Timer? _sampleTimer;

  static const int _minSamples = 5;

  static const int _maxSamples = 10;

  static const double _confidenceThreshold = 1;

  ScannerCubit() : super(ScannerState()) {
    barcodeController.start();
  }

  void showMessage(String msg) {
    emit(
      state.copyWith(
        message: msg,
        messageId: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> toggleMode(bool isOcr) async {
    if (state.isOcrMode == isOcr) return;

    _stopSampling();

    emit(
      state.copyWith(
        isOcrMode: isOcr,
        isScanning: false,
        isSampling: false,
        sampleCount: 0,
        scannedCode: '',
        lastScannedCode: '',
        isFlashOn: false,
      ),
    );
    latestBarcode = null;

    if (isOcr) {
      await barcodeController.stop();
      await _initOcrCamera();
    } else {
      if (cameraController != null) {
        await cameraController!.dispose();
        cameraController = null;
      }
      emit(state.copyWith(isCameraInitialized: false));
      await barcodeController.start();
    }
  }

  Future<void> _initOcrCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        showMessage('No cameras available');
        return;
      }

      cameraController = CameraController(cameras.first, ResolutionPreset.high);
      await cameraController!.initialize();
      emit(state.copyWith(isCameraInitialized: true));
    } catch (e) {
      showMessage('Failed to initialize camera');
    }
  }

  /// Called by the MobileScanner widget on every barcode detection frame.
  /// During sampling, it just records the value into [_scanSamples].
  void onBarcodeDetect(BarcodeCapture capture) {
    if (!state.isScanning) return;
    if (state.isFieldFocused) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;

      latestBarcode = value;

      if (value != state.lastScannedCode && state.lastScannedCode.isNotEmpty) {
        emit(state.copyWith(lastScannedCode: ''));
      }

      // If we are in the sampling phase, just record the sample.
      if (state.isSampling) {
        _scanSamples[value] = (_scanSamples[value] ?? 0) + 1;
        return;
      }
    }
  }

  void scanButtonPressed() {
    if (state.isOcrMode) {
      _performOcrScan();
    } else {
      _startSampling();
    }
  }

  // ─── Multi-sample scanning ───────────────────────────────────────

  void _startSampling() {
    _scanSamples.clear();
    _sampleTimer?.cancel();

    // Enter scanning + sampling mode.
    emit(state.copyWith(isScanning: true, isSampling: true, sampleCount: 0));

    var tickCount = 0;

    _sampleTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      tickCount++;
      final totalSamples = _scanSamples.values.fold<int>(0, (a, b) => a + b);

      emit(state.copyWith(sampleCount: totalSamples));

      // Check for a confident result once we have enough samples.
      if (totalSamples >= _minSamples) {
        final bestEntry = _scanSamples.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );

        final confidence = bestEntry.value / totalSamples;

        if (confidence >= _confidenceThreshold) {
          // We have a confident result (100% match).
          _finishSampling(bestEntry.key);
          return;
        }
      }

      // Safety: reset and retry after _maxSamples ticks.
      if (tickCount >= _maxSamples) {
        if (_scanSamples.isNotEmpty) {
          final bestEntry = _scanSamples.entries.reduce(
            (a, b) => a.value >= b.value ? a : b,
          );
          final confidence = bestEntry.value / totalSamples;
          if (confidence >= _confidenceThreshold) {
            _finishSampling(bestEntry.key);
            return;
          }
        }
        // If we hit the limit without 100% confidence, restart sampling for a clean attempt
        _startSampling();
      }
    });
  }

  void _finishSampling(String value) {
    _stopSampling();

    if (value == state.lastScannedCode) {
      _startSampling();
      return;
    }

    final existingIndex = state.inspectionList.indexWhere(
      (item) => item.value == value,
    );

    if (existingIndex != -1) {
      final existingItem = state.inspectionList[existingIndex];
      emit(
        state.copyWith(
          scannedCode: existingItem.value,
          lastScannedCode: value,
          quantity: existingItem.quantity,
          editingIndex: existingIndex,
          isSampling: false,
          sampleCount: 0,
        ),
      );
    } else {
      emit(
        state.copyWith(
          scannedCode: value,
          lastScannedCode: value,
          editingIndex: -1,
          isSampling: false,
          sampleCount: 0,
        ),
      );
      _addItem(value, 'Barcode', state.quantity);
    }

    // Automatically start scanning for the next barcode.
    _startSampling();
  }

  void _stopSampling() {
    _sampleTimer?.cancel();
    _sampleTimer = null;
    _scanSamples.clear();
  }

  // ─── List management ─────────────────────────────────────────────

  void _addItem(String value, String type, int quantity) {
    final newItem = InspectionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      value: value,
      quantity: quantity,
      timestamp: DateTime.now(),
      type: type,
    );

    final updatedList = List<InspectionItem>.from(state.inspectionList)
      ..insert(0, newItem);

    emit(state.copyWith(inspectionList: updatedList));
  }

  /// Loads an existing list item into the Code/Quantity fields for editing.
  void selectItemForEdit(int index) {
    if (index < 0 || index >= state.inspectionList.length) return;
    final item = state.inspectionList[index];
    emit(
      state.copyWith(
        scannedCode: item.value,
        quantity: item.quantity,
        editingIndex: index,
      ),
    );
  }

  void updateCode(String value) {
    emit(state.copyWith(scannedCode: value));
  }

  void updateQuantity(String value) {
    final parsed = int.tryParse(value);
    emit(state.copyWith(quantity: parsed ?? state.quantity));
  }

  void setFieldsFocus(bool hasFocus) {
    if (hasFocus) {
      _stopSampling();
      emit(state.copyWith(isFieldFocused: true, isSampling: false));
    } else {
      emit(state.copyWith(isFieldFocused: false));
      if (state.isScanning && !state.isOcrMode) {
        _startSampling();
      }
    }
  }

  Future<void> toggleFlash() async {
    final nextFlashState = !state.isFlashOn;
    try {
      if (state.isOcrMode) {
        if (cameraController != null && cameraController!.value.isInitialized) {
          await cameraController!.setFlashMode(
            nextFlashState ? FlashMode.torch : FlashMode.off,
          );
          emit(state.copyWith(isFlashOn: nextFlashState));
        }
      } else {
        await barcodeController.toggleTorch();
        emit(state.copyWith(isFlashOn: nextFlashState));
      }
    } catch (e) {
      // ignore
    }
  }

  String _cleanOcrText(String text) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';
    // Join all non-empty lines with a space, and collapse multiple spaces into a single space
    return lines.join(' ').replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _performOcrScan() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Delete the temporary image file to avoid cluttering storage
      try {
        final file = File(image.path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}

      final cleaned = _cleanOcrText(recognizedText.text);

      if (cleaned.isNotEmpty) {
        final existingIndex = state.inspectionList.indexWhere(
          (item) => item.value == cleaned,
        );

        if (existingIndex != -1) {
          final existing = state.inspectionList[existingIndex];
          emit(
            state.copyWith(
              scannedCode: existing.value,
              lastScannedCode: cleaned,
              quantity: existing.quantity,
              editingIndex: existingIndex,
            ),
          );
        } else {
          emit(
            state.copyWith(
              scannedCode: cleaned,
              lastScannedCode: cleaned,
              editingIndex: -1,
            ),
          );
          _addItem(cleaned, 'OCR', state.quantity);
        }
      } else {
        showMessage('No text recognized');
      }
    } catch (e) {
      showMessage('Error: $e');
    }
  }

  /// Whether the user is currently editing an existing item (via Reset).
  bool get isEditing => state.editingIndex >= 0;

  /// Updates the currently-editing item in the list.
  void updateCurrentItem() {
    final index = state.editingIndex;
    if (index < 0 || index >= state.inspectionList.length) return;

    final code = state.scannedCode.trim();
    if (code.isEmpty) {
      showMessage('Code is empty');
      return;
    }

    final old = state.inspectionList[index];
    final updatedItem = InspectionItem(
      id: old.id,
      value: code,
      quantity: state.quantity,
      timestamp: old.timestamp,
      type: old.type,
    );

    final updatedList = List<InspectionItem>.from(state.inspectionList);
    updatedList[index] = updatedItem;

    emit(
      state.copyWith(
        inspectionList: updatedList,
        scannedCode: '',
        lastScannedCode: '',
        quantity: 1,
        editingIndex: -1,
      ),
    );
    showMessage('Updated');
  }

  /// Saves the full inspection list as CSV. Returns `true` on success so the
  /// UI can pop the screen.
  Future<bool> saveAndExport() async {
    if (state.inspectionList.isEmpty) {
      showMessage('Nothing to save');
      return false;
    }

    _stopSampling();
    emit(state.copyWith(isScanning: false, isSampling: false));

    try {
      await _persist(state.inspectionList);
      showMessage('Saved to CSV');
      return true;
    } catch (e) {
      showMessage('Failed to save');
      return false;
    }
  }

  Future<void> _persist(List<InspectionItem> items) async {
    try {
      _persistedFilePath = await FileService.saveInspectionListToCsv(
        items,
        filePath: _persistedFilePath,
      );
    } catch (e) {
      showMessage('Failed to save');
    }
  }

  @override
  Future<void> close() {
    _stopSampling();
    barcodeController.dispose();
    cameraController?.dispose();
    textRecognizer.close();
    return super.close();
  }
}
