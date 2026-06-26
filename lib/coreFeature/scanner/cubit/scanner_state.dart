import '../models/inspection_item.dart';

class ScannerState {
  final bool isOcrMode;
  final bool isCameraInitialized;
  final bool isScanning;

  /// True while the cubit is actively collecting barcode samples.
  final bool isSampling;

  /// Number of samples collected so far during the current scan cycle.
  final int sampleCount;

  final List<InspectionItem> inspectionList;
  final String scannedCode;
  final String lastScannedCode;
  final int quantity;

  /// Index of the list item currently being edited via the Code/Quantity
  /// fields, or -1 when the fields represent a brand-new entry.
  final int editingIndex;
  final String? message;
  final int? messageId;
  final bool isFieldFocused;
  final bool isFlashOn;

  ScannerState({
    this.isOcrMode = false,
    this.isCameraInitialized = false,
    this.isScanning = false,
    this.isSampling = false,
    this.sampleCount = 0,
    this.inspectionList = const [],
    this.scannedCode = '',
    this.lastScannedCode = '',
    this.quantity = 1,
    this.editingIndex = -1,
    this.message,
    this.messageId,
    this.isFieldFocused = false,
    this.isFlashOn = false,
  });

  ScannerState copyWith({
    bool? isOcrMode,
    bool? isCameraInitialized,
    bool? isScanning,
    bool? isSampling,
    int? sampleCount,
    List<InspectionItem>? inspectionList,
    String? scannedCode,
    String? lastScannedCode,
    int? quantity,
    int? editingIndex,
    String? message,
    int? messageId,
    bool? isFieldFocused,
    bool? isFlashOn,
  }) {
    return ScannerState(
      isOcrMode: isOcrMode ?? this.isOcrMode,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      isScanning: isScanning ?? this.isScanning,
      isSampling: isSampling ?? this.isSampling,
      sampleCount: sampleCount ?? this.sampleCount,
      inspectionList: inspectionList ?? this.inspectionList,
      scannedCode: scannedCode ?? this.scannedCode,
      lastScannedCode: lastScannedCode ?? this.lastScannedCode,
      quantity: quantity ?? this.quantity,
      editingIndex: editingIndex ?? this.editingIndex,
      message: message,
      messageId: messageId,
      isFieldFocused: isFieldFocused ?? this.isFieldFocused,
      isFlashOn: isFlashOn ?? this.isFlashOn,
    );
  }
}

