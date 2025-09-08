import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/detection_result.dart';
import '../utils/constants.dart';
import 'package:image/image.dart' as img;

class MLService extends ChangeNotifier {
  Interpreter? _diseaseInterpreter;
  Interpreter? _ganDiscriminatorInterpreter;
  Interpreter? _ganFeatureExtractorInterpreter;
  bool _isLoading = false;
  String? _error;

  // GAN threshold (35th percentile from your training)
  //double _ganThreshold = 0.107734;
  double _ganThreshold = 0.65;


  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadModels() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load disease detection model (CNN)
      _diseaseInterpreter = await Interpreter.fromAsset(
        'assets/models/model_int8_v2.tflite',
        options: InterpreterOptions()..threads = 2,
      );
      print("✅ Disease model loaded");

      // Load GAN Discriminator model
      try {
        _ganDiscriminatorInterpreter = await Interpreter.fromAsset(
          'assets/models/discriminator_int8.tflite',
          options: InterpreterOptions()..threads = 2,
        );
        print("✅ GAN Discriminator model loaded");
      } catch (e) {
        print("⚠️ GAN Discriminator model failed to load: $e");
      }

      // Load GAN Feature Extractor model
      try {
        _ganFeatureExtractorInterpreter = await Interpreter.fromAsset(
          'assets/models/feature_extractor_int8.tflite',
          options: InterpreterOptions()..threads = 2,
        );
        print("✅ GAN Feature Extractor model loaded");
      } catch (e) {
        print("⚠️ GAN Feature Extractor model failed to load: $e");
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load models: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DetectionResult?> detectDisease(File imageFile) async {
    if (_diseaseInterpreter == null) {
      await loadModels();
    }

    if (_diseaseInterpreter == null) {
      _error = 'CNN model not loaded properly';
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Preprocess image for both CNN and GAN
      final cnnInput = await _preprocessImageForCNN(imageFile);
      final ganInput = await _preprocessImageForGAN(imageFile);

      // 1. CNN PREDICTION FIRST
      final diseaseOutputShape = _diseaseInterpreter!.getOutputTensor(0).shape;
      final diseaseOutput = List.generate(
          diseaseOutputShape[0],
              (_) => List.filled(diseaseOutputShape[1], 0)
      );

      _diseaseInterpreter!.run(cnnInput, diseaseOutput);
      final diseaseScores = _dequantizeOutput(diseaseOutput[0]);
      final maxIndex = diseaseScores.indexOf(diseaseScores.reduce((a, b) => a > b ? a : b));

      final cnnConfidence = diseaseScores[maxIndex];
      final diseaseName = AppConstants.diseaseLabels[maxIndex];

      // 2. GAN ANOMALY DETECTION
      double anomalyScore = 0.0;
      bool isAnomalyByGAN = false;
      String decisionPath = 'CNN_ONLY';

      if (_ganDiscriminatorInterpreter != null || _ganFeatureExtractorInterpreter != null) {
        anomalyScore = await _calculateGANAnomalyScore(ganInput);
        isAnomalyByGAN = anomalyScore > _ganThreshold;
        decisionPath = 'CNN_WITH_GAN';
      }

      // 3. APPLY YOUR SPECIFIC CONDITIONS
      bool finalIsAnomaly = isAnomalyByGAN || (cnnConfidence < 0.70);
      AnomalyLevel anomalyLevel;
      String finalDiseaseName = diseaseName;

      if (cnnConfidence > 0.7) {
        // Definitely not anomaly - anomaly zero
        anomalyLevel = AnomalyLevel.zero;
        // Show class name (keep finalDiseaseName as is)
      } else {
        if (finalIsAnomaly) {
          if (anomalyScore > 0.65) {
            // 100% anomaly - very high
            anomalyLevel = AnomalyLevel.veryHigh;
            finalDiseaseName = 'ANOMALY'; // Don't show class name
          } else {
            // Moderate anomaly
            anomalyLevel = AnomalyLevel.moderate;
            //finalDiseaseName = 'ANOMALY';
          }
        } else {
            // Show class name - anomaly low
            anomalyLevel = AnomalyLevel.low;
            // Show class name (keep finalDiseaseName as is)
        }
      }



      _isLoading = false;
      notifyListeners();

      return DetectionResult(
        diseaseName: finalDiseaseName,
        confidence: cnnConfidence,
        anomalyLevel: anomalyLevel,
        anomalyScore: anomalyScore,
        isAnomaly: finalIsAnomaly,
        decisionPath: decisionPath,
      );
    } catch (e) {
      _error = 'Detection failed: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<double> _calculateGANAnomalyScore(List<List<List<List<int>>>> ganInput) async {
    double discriminatorScore = 0.0;
    double featureScore = 0.0;

    // Method 1: Discriminator Score (how "real" the image looks)
    if (_ganDiscriminatorInterpreter != null) {
      discriminatorScore = await _getDiscriminatorScore(ganInput);
    }

    // Method 2: Feature-based reconstruction error (if available)
    if (_ganFeatureExtractorInterpreter != null) {
      featureScore = await _getFeatureReconstructionScore(ganInput);
    }

    // Combined score as mentioned in your code
    double combinedScore;
    if (_ganDiscriminatorInterpreter != null && _ganFeatureExtractorInterpreter != null) {
      // Both models available - use combined approach
      combinedScore = 0.6 * discriminatorScore + 0.4 * featureScore;
    } else if (_ganDiscriminatorInterpreter != null) {
      // Only discriminator available
      combinedScore = discriminatorScore;
    } else if (_ganFeatureExtractorInterpreter != null) {
      // Only feature extractor available
      combinedScore = featureScore;
    } else {
      // No GAN models available - fallback
      combinedScore = 0.0;
    }

    return combinedScore;
  }

  Future<double> _getDiscriminatorScore(List<List<List<List<int>>>> input) async {
    try {
      final outputShape = _ganDiscriminatorInterpreter!.getOutputTensor(0).shape;
      final output = List.generate(
          outputShape[0],
              (_) => List.filled(outputShape[1], 0)
      );

      _ganDiscriminatorInterpreter!.run(input, output);
      final dequantizedOutput = _dequantizeOutput(output[0]);

      // Convert discriminator output to probability (sigmoid)
      double discScore = dequantizedOutput[0];
      double discProb = 1.0 / (1.0 + math.exp(-discScore)); // Sigmoid

      // Convert to anomaly score (1 - probability of being real)
      double anomalyScore = 1.0 - discProb;

      return anomalyScore;
    } catch (e) {
      print('Discriminator score calculation failed: $e');
      return 0.0;
    }
  }

  Future<double> _getFeatureReconstructionScore(List<List<List<List<int>>>> input) async {
    try {
      final outputShape = _ganFeatureExtractorInterpreter!.getOutputTensor(0).shape;
      final output = List.generate(
          outputShape[0],
              (_) => List.filled(outputShape[1], 0)
      );

      _ganFeatureExtractorInterpreter!.run(input, output);
      final features = _dequantizeOutput(output[0]);

      // Calculate feature-based anomaly score
      // This is a simplified approach - you might want to implement
      // more sophisticated feature comparison with training data
      double featureMagnitude = 0.0;
      for (double feature in features) {
        featureMagnitude += feature * feature;
      }
      featureMagnitude = math.sqrt(featureMagnitude / features.length);

      // Normalize to [0, 1] range (you may need to adjust these thresholds)
      double normalizedScore = (featureMagnitude).clamp(0.0, 1.0);

      return normalizedScore;
    } catch (e) {
      print('Feature reconstruction score calculation failed: $e');
      return 0.0;
    }
  }

  Future<List<List<List<List<int>>>>> _preprocessImageForCNN(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception("Failed to decode image");

    final resized = img.copyResize(image, width: 224, height: 224);

    // Convert image to int8 pixel values for quantized model
    return [
      List.generate(224, (y) =>
          List.generate(224, (x) {
            final pixel = resized.getPixel(x, y);
            // Convert to int8 range [-128, 127]
            final r = (pixel.r.toInt() - 128).clamp(-128, 127);
            final g = (pixel.g.toInt() - 128).clamp(-128, 127);
            final b = (pixel.b.toInt() - 128).clamp(-128, 127);
            return [r, g, b];
          })
      )
    ];
  }

  Future<List<List<List<List<int>>>>> _preprocessImageForGAN(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception("Failed to decode image");

    // Resize to 128x128 for GAN (as per your GAN training)
    final resized = img.copyResize(image, width: 128, height: 128);

    // Convert image to int8 pixel values for GAN (normalized to [-1, 1] then quantized)
    return [
      List.generate(128, (y) =>
          List.generate(128, (x) {
            final pixel = resized.getPixel(x, y);
            // Normalize to [-1, 1] then quantize to int8
            final r = ((pixel.r.toDouble() / 255.0 * 2.0 - 1.0) * 127).round().clamp(-128, 127);
            final g = ((pixel.g.toDouble() / 255.0 * 2.0 - 1.0) * 127).round().clamp(-128, 127);
            final b = ((pixel.b.toDouble() / 255.0 * 2.0 - 1.0) * 127).round().clamp(-128, 127);
            return [r, g, b];
          })
      )
    ];
  }

  List<double> _dequantizeOutput(List<int> intOutput) {
    // Dequantize int8 output to float
    // Adjust these values based on your model's quantization parameters
    const double scale = 1.0 / 127.0; // Changed from 128 to 127 for proper int8 range
    const int zeroPoint = 0;

    return intOutput.map((x) => (x - zeroPoint) * scale).toList();
  }

  // Update the anomaly level enumeration to include your new levels
  AnomalyLevel _getAnomalyLevel(double score, bool isAnomaly, double cnnConfidence) {
    if (isAnomaly) {
      if (score > 0.3) {
        return AnomalyLevel.veryHigh; // 100% anomaly
      } else {
        return AnomalyLevel.moderate; // Moderate anomaly
      }
    } else {
      if (cnnConfidence > 0.9) {
        return AnomalyLevel.zero; // Definitely not anomaly
      } else {
        return AnomalyLevel.low; // Low anomaly risk
      }
    }
  }



  @override
  void dispose() {
    _diseaseInterpreter?.close();
    _ganDiscriminatorInterpreter?.close();
    _ganFeatureExtractorInterpreter?.close();
    super.dispose();
  }
}