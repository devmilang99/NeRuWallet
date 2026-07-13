import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/providers/kyc_provider.dart';

import '../../../../core/theme/app_theme.dart';
import 'document_scan_screen.dart';
import 'face_verification_screen.dart';

enum EKYCStep {
  instructions,
  documentScan,
  faceVerification,
  processing,
  success,
  failure,
}

class EKYCFlowScreen extends ConsumerStatefulWidget {
  const EKYCFlowScreen({super.key});

  @override
  ConsumerState<EKYCFlowScreen> createState() => _EKYCFlowScreenState();
}

class _EKYCFlowScreenState extends ConsumerState<EKYCFlowScreen> {
  EKYCStep _currentStep = EKYCStep.instructions;
  String? _errorMessage;

  void _nextStep() {
    setState(() {
      switch (_currentStep) {
        case EKYCStep.instructions:
          _currentStep = EKYCStep.documentScan;
          break;
        case EKYCStep.documentScan:
          _currentStep = EKYCStep.faceVerification;
          break;
        case EKYCStep.faceVerification:
          _currentStep = EKYCStep.processing;
          _processEKYC();
          break;
        default:
          break;
      }
    });
  }

  Future<void> _processEKYC() async {
    // Simulate processing
    await Future.delayed(const Duration(seconds: 3));

    // Save verification status to persistent database via provider
    await ref.read(kycStateProvider.notifier).updateVerificationStatus(true);

    if (mounted) {
      _showResultDialog(true);
    }
  }

  void _showResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
            ),
            const SizedBox(width: 10),
            Text(isSuccess ? 'Success' : 'Failed'),
          ],
        ),
        content: Text(
          isSuccess
              ? 'Your eKYC verification has been completed successfully.'
              : _errorMessage ?? 'Verification failed. Please try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (isSuccess) {
                context.go('/dashboard');
              } else {
                setState(() {
                  _currentStep = EKYCStep.instructions;
                });
              }
            },
            child: Text(isSuccess ? 'Go to Dashboard' : 'Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eKYC Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case EKYCStep.instructions:
        return _buildInstructions();
      case EKYCStep.documentScan:
        return DocumentScanScreen(
          onDocumentCaptured: (text) {
            _nextStep();
          },
        );
      case EKYCStep.faceVerification:
        return FaceVerificationScreen(
          onFaceVerified: (success) {
            if (success) {
              _nextStep();
            } else {
              _errorMessage =
                  "Face verification failed. Please ensure your face is clearly visible and try again.";
              _showResultDialog(false);
            }
          },
        );
      case EKYCStep.processing:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Processing your documents...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case EKYCStep.success:
        return _buildResult(true);
      case EKYCStep.failure:
        return _buildResult(false);
    }
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to verify your identity?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          const Text(
            'We need to verify your identity to ensure the security of your account and comply with regulations.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildInstructionItem(
            Icons.badge_outlined,
            'Document Scan',
            'Prepare your ID card or Passport for a clear scan.',
          ),
          _buildInstructionItem(
            Icons.face_retouching_natural,
            'Face Verification',
            'Ensure you are in a well-lit area for a selfie.',
          ),
          _buildInstructionItem(
            Icons.lightbulb_outline,
            'Good Lighting',
            'Make sure there is no glare on your document or face.',
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _nextStep,
            child: const Text('Start Verification'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              size: 100,
              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
            ),
            const SizedBox(height: 24),
            Text(
              isSuccess ? 'Verification Successful!' : 'Verification Failed',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess
                  ? 'Your account has been successfully verified. You can now access all features.'
                  : _errorMessage ??
                        'Something went wrong during the verification process. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (isSuccess) {
                  context.go('/dashboard');
                } else {
                  setState(() {
                    _currentStep = EKYCStep.instructions;
                  });
                }
              },
              child: Text(isSuccess ? 'Go to Dashboard' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
