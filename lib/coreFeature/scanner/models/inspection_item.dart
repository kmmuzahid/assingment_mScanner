import 'package:flutter/material.dart';

class InspectionItem {
  final String id;
  final String value;
  final int quantity;
  final DateTime timestamp;
  final String type; // 'Barcode', 'QR Code', 'OCR'

  InspectionItem({
    required this.id,
    required this.value,
    required this.quantity,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
