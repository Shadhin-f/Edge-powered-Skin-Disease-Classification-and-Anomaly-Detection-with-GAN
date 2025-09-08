import 'package:flutter/material.dart';

class DetectionResult {
  final String diseaseName;
  final double confidence;
  final AnomalyLevel anomalyLevel;
  final double anomalyScore;
  final bool isAnomaly;
  final String? decisionPath;

  DetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.anomalyLevel,
    required this.anomalyScore,
    required this.isAnomaly,
    this.decisionPath,
  });

  /// Used in UI for result title
  String get displayName => diseaseName;

  /// Confidence percentage text
  String get confidenceDescription =>
      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%';

  /// Human-readable anomaly description
  String get anomalyDescription {
    switch (anomalyLevel) {
      case AnomalyLevel.zero:
        return 'No anomaly detected';
      case AnomalyLevel.low:
        return 'Low anomaly level';
      case AnomalyLevel.moderate:
        return 'Moderate anomaly level';
      case AnomalyLevel.high:
        return 'High anomaly level';
      case AnomalyLevel.veryHigh:
        return 'Critical anomaly level';
    }
  }
}

enum AnomalyLevel {
  zero,
  low,
  moderate,
  high, // ✅ Added missing high level
  veryHigh;

  String get displayName {
    switch (this) {
      case AnomalyLevel.zero:
        return 'No Anomaly';
      case AnomalyLevel.low:
        return 'Low';
      case AnomalyLevel.moderate:
        return 'Moderate';
      case AnomalyLevel.high:
        return 'High';
      case AnomalyLevel.veryHigh:
        return 'Very High';
    }
  }

  Color get color {
    switch (this) {
      case AnomalyLevel.zero:
        return Colors.blue;
      case AnomalyLevel.low:
        return Colors.green;
      case AnomalyLevel.moderate:
        return Colors.orange;
      case AnomalyLevel.high:
        return Colors.red.shade600;
      case AnomalyLevel.veryHigh:
        return Colors.red.shade900;
    }
  }

  IconData get icon {
    switch (this) {
      case AnomalyLevel.zero:
        return Icons.check_circle;
      case AnomalyLevel.low:
        return Icons.check_circle_outline;
      case AnomalyLevel.moderate:
        return Icons.warning_amber;
      case AnomalyLevel.high:
        return Icons.error_outline;
      case AnomalyLevel.veryHigh:
        return Icons.dangerous;
    }
  }
}
