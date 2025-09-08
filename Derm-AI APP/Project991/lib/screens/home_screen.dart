// home_screen.dart placeholder
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/ml_service.dart';
import '../services/image_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_preview.dart';
import '../utils/constants.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MLService>().loadModels();
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await ImageService.pickFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _captureImageFromCamera() async {
    try {
      final image = await ImageService.captureFromCamera();
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: $e');
    }
  }

  Future<void> _detectDisease() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    final mlService = context.read<MLService>();
    final result = await mlService.detectDisease(_selectedImage!);

    if (result != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            result: result,
            imageFile: _selectedImage!,
          ),
        ),
      );
    } else if (mlService.error != null) {
      _showErrorSnackBar(mlService.error!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImageFromCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor ?? AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About DermAI'),
                  content: const Text(
                    'This app uses AI to detect potential skin conditions. '
                        'Results are for informational purposes only and should not '
                        'replace professional medical advice.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MLService>(
        builder: (context, mlService, child) {
          if (mlService.isLoading && _selectedImage == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(
                    color: AppConstants.primaryColor,
                    size: 50.0,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    mlService.error ?? 'Loading AI models...',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instructions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Select or capture an image of the skin area you want to analyze',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Image Preview
                Expanded(
                  flex: 3,
                  child: ImagePreview(
                    imageFile: _selectedImage,
                    onTap: _showImageSourceDialog,
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Action Buttons
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Image Source Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Gallery',
                              icon: Icons.photo_library,
                              onPressed: _pickImageFromGallery,
                              type: ButtonType.secondary,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: CustomButton(
                              text: 'Camera',
                              icon: Icons.camera_alt,
                              onPressed: _captureImageFromCamera,
                              type: ButtonType.secondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Detect Button
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Detect Disease',
                          icon: Icons.search,
                          onPressed: _selectedImage != null ? _detectDisease : null,
                          isLoading: mlService.isLoading && _selectedImage != null,
                          type: ButtonType.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
