// result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/detection_result.dart';
import '../widgets/result_card.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final DetectionResult result;
  final File imageFile;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Results'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Original Image Card
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Analyzed Image',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Results
            ResultCard(result: result),

            // Anomaly Alert Card (if anomaly detected)
            if (result.isAnomaly) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              _buildAnomalyAlertCard(theme),
            ],

            const SizedBox(height: AppConstants.paddingLarge),

            // Recommendations Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getRecommendationIcon(),
                          color: _getRecommendationIconColor(),
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Recommendations',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // List of Recommendations
                    ..._getRecommendations(result).map(
                          (recommendation) => Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getRecommendationIconColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingSmall),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Analyze Another',
                    icon: Icons.refresh,
                    onPressed: () => Navigator.pop(context),
                    type: ButtonType.secondary,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: CustomButton(
                    text: result.isAnomaly ? 'Consult Expert' : 'Share Results',
                    icon: result.isAnomaly ? Icons.medical_services : Icons.share,
                    onPressed: () {
                      if (result.isAnomaly) {
                        _showExpertConsultationDialog(context);
                      } else {
                        // Replace with actual sharing logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share functionality would be implemented here'),
                          ),
                        );
                      }
                    },
                    type: result.isAnomaly ? ButtonType.primary : ButtonType.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyAlertCard(ThemeData theme) {
    Color alertColor;
    IconData alertIcon;
    String alertTitle;
    String alertMessage;

    switch (result.anomalyLevel) {
      case AnomalyLevel.veryHigh:
        alertColor = Colors.red.shade800;
        alertIcon = Icons.error;
        alertTitle = 'Critical Anomaly Detected';
        alertMessage =
        'This image shows highly unusual characteristics that require immediate expert consultation.';
        break;
      case AnomalyLevel.moderate:
        alertColor = Colors.orange.shade700;
        alertIcon = Icons.warning;
        alertTitle = 'Moderate Anomaly Detected';
        alertMessage =
        'This image shows some unusual characteristics that may need professional evaluation.';
        break;
      default:
        alertColor = Colors.blue.shade600;
        alertIcon = Icons.info;
        alertTitle = 'Low Risk Detection';
        alertMessage = 'Detection completed with moderate confidence.';
    }

    return Container(
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        border: Border.all(color: alertColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(alertIcon, color: alertColor, size: 24),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    alertTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: alertColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              alertMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: alertColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }


  IconData _getRecommendationIcon() {
    if (result.isAnomaly) {
      return result.anomalyLevel == AnomalyLevel.veryHigh
          ? Icons.medical_services
          : Icons.warning_amber;
    }
    return result.anomalyLevel == AnomalyLevel.zero
        ? Icons.check_circle
        : Icons.lightbulb_outline;
  }

  Color _getRecommendationIconColor() {
    switch (result.anomalyLevel) {
      case AnomalyLevel.zero:
        return Colors.green;
      case AnomalyLevel.low:
        return Colors.blue;
      case AnomalyLevel.moderate:
        return Colors.orange;
      case AnomalyLevel.high:
        return Colors.red.shade600;
      case AnomalyLevel.veryHigh:
        return Colors.red.shade800;
    }
  }

  void _showExpertConsultationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expert Consultation Recommended'),
        content: const Text(
          'Based on the anomaly detection, we strongly recommend consulting with a medical professional for proper evaluation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logic to navigate to expert consultation feature
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expert consultation feature would be implemented here'),
                ),
              );
            },
            child: const Text('Find Expert'),
          ),
        ],
      ),
    );
  }

  List<String> _getRecommendations(DetectionResult result) {
    final recommendations = <String>[];

    // Handle anomaly cases

      if (result.anomalyLevel == AnomalyLevel.veryHigh) {
        recommendations.addAll([
          '🚨 URGENT: Seek immediate medical attention',
          'This image shows highly unusual characteristics not typical of common skin conditions',
          'Do not delay professional consultation',
          'Document any symptoms or changes you\'ve noticed',
          'Consider visiting an emergency dermatologist or urgent care',
        ]);
        return recommendations;
      } else if (result.anomalyLevel == AnomalyLevel.moderate) {
        recommendations.addAll([
          '⚠️ Recommend professional evaluation within 1-2 weeks',
          'This image shows some unusual characteristics',
          'Monitor the area for any changes',
          'Take photos to track progression',
          'Avoid self-treatment until professional diagnosis',
        ]);
        return recommendations;
      }



    // Handle normal detection cases (zero and low anomaly levels)
    final baseRecommendations = <String>[
      'Consult a dermatologist for professional confirmation',
      'Keep the affected area clean and dry',
      'Monitor for any changes or worsening symptoms',
    ];

    if (result.anomalyLevel == AnomalyLevel.zero) {
      // High confidence detection
      baseRecommendations.insert(0, '✅ High confidence detection - ${result.diseaseName}');
    } else {
      // Low anomaly level - moderate confidence
      baseRecommendations.insert(0, '📋 Moderate confidence detection - ${result.diseaseName}');
      baseRecommendations.add('Consider getting a second opinion if symptoms persist');
    }

    recommendations.addAll(baseRecommendations);

    // Add disease-specific recommendations only for non-anomaly cases
    switch (result.diseaseName.toLowerCase()) {
      case 'acne':
        recommendations.addAll([
          'Use gentle, non-comedogenic skincare products',
          'Avoid touching your face frequently',
          'Consider over-the-counter treatments with salicylic acid or benzoyl peroxide',
        ]);
        break;

      case 'athlete foot':
        recommendations.addAll([
          'Keep feet clean and dry, especially between toes',
          'Wear breathable footwear and change socks regularly',
          'Use antifungal powders or creams as directed',
        ]);
        break;

      case 'nail fungus':
        recommendations.addAll([
          'Trim and thin affected nails regularly',
          'Use antifungal treatments consistently',
          'Avoid walking barefoot in public places like locker rooms and pools',
        ]);
        break;

      case 'ringworm':
        recommendations.addAll([
          'Apply antifungal cream or lotion to the affected area',
          'Do not share towels, clothing, or personal items',
          'Wash bedding and clothes regularly during treatment',
        ]);
        break;



      case 'healthy':
        recommendations.clear();
        recommendations.addAll([
          '🎉 No signs of skin disease detected!',
          'Your skin appears healthy based on our analysis',
          'Maintain a consistent skincare routine',
          'Protect your skin from excessive sun exposure',
          'Stay hydrated and eat a balanced diet',
          'Continue regular self-examinations',
        ]);
        break;

      default:
        recommendations.add('Follow general skin care practices and monitor changes');
    }

    return recommendations;
  }
}