// widgets/result_card.dart
import 'package:flutter/material.dart';
import '../models/detection_result.dart';
import '../utils/constants.dart';

class ResultCard extends StatelessWidget {
  final DetectionResult result;

  const ResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                _buildResultIcon(),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detection Result',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Main Result Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: _getResultBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getResultBorderColor(),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Disease/Anomaly Name
                  Text(
                    result.displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getResultTextColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Confidence/Anomaly Description
                  Text(
                    result.confidenceDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _getResultTextColor().withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppConstants.paddingSmall),

                  // Anomaly Level Description
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: _getAnomalyLevelColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getAnomalyLevelColor().withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      result.anomalyDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getAnomalyLevelColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Technical Details (Debug info)
            if (result.decisionPath != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              ExpansionTile(
                title: Text(
                  'Technical Details',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('CNN Confidence', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                        _buildDetailRow('Anomaly Score', '${(result.anomalyScore * 100).toStringAsFixed(1)}%'),
                        _buildDetailRow('Decision Path', result.decisionPath!),
                        _buildDetailRow('Is Anomaly', result.isAnomaly ? 'Yes' : 'No'),
                        _buildDetailRow('Anomaly Level', result.anomalyLevel.toString().split('.').last),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    IconData iconData;
    Color iconColor;

    if (result.isAnomaly) {
      switch (result.anomalyLevel) {
        case AnomalyLevel.veryHigh:
          iconData = Icons.error;
          iconColor = Colors.red.shade800;
          break;
        case AnomalyLevel.moderate:
          iconData = Icons.warning;
          iconColor = Colors.orange.shade700;
          break;
        default:
          iconData = Icons.info;
          iconColor = Colors.blue.shade600;
      }
    } else {
      switch (result.anomalyLevel) {
        case AnomalyLevel.zero:
          iconData = Icons.check_circle;
          iconColor = Colors.green.shade600;
          break;
        default:
          iconData = Icons.medical_services;
          iconColor = Colors.blue.shade600;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withOpacity(0.3),
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 32,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (result.isAnomaly) {
      switch (result.anomalyLevel) {
        case AnomalyLevel.veryHigh:
          return 'CRITICAL ANOMALY';
        case AnomalyLevel.moderate:
          return 'MODERATE ANOMALY';
        default:
          return 'CONFIDENT';
      }
    } else {
      switch (result.anomalyLevel) {
        case AnomalyLevel.zero:
          return 'HIGH CONFIDENCE DETECTION';
        case AnomalyLevel.low:
          return 'MODERATE CONFIDENCE DETECTION';
        default:
          return 'DETECTION COMPLETE';
      }
    }
  }

  Color _getStatusColor() {
    return _getAnomalyLevelColor();
  }

  Color _getResultBackgroundColor() {
    return _getAnomalyLevelColor().withOpacity(0.05);
  }

  Color _getResultBorderColor() {
    return _getAnomalyLevelColor().withOpacity(0.3);
  }

  Color _getResultTextColor() {
    return _getAnomalyLevelColor();
  }

  Color _getAnomalyLevelColor() {
    switch (result.anomalyLevel) {
      case AnomalyLevel.zero:
        return Colors.green.shade700;
      case AnomalyLevel.low:
        return Colors.blue.shade700;
      case AnomalyLevel.moderate:
        return Colors.orange.shade700;
      case AnomalyLevel.high:
        return Colors.red.shade600;
      case AnomalyLevel.veryHigh:
        return Colors.red.shade800;
    }
  }
}