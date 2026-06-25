import 'package:flutter/material.dart';
import 'package:otp_forge/otp_forge.dart';

void main() {
  runApp(const OtpForgeExampleApp());
}

class OtpForgeExampleApp extends StatelessWidget {
  const OtpForgeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP Forge Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern indigo
        ),
        useMaterial3: true,
      ),
      home: const VerificationScreen(),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // We can toggle styles to showcase the package's flexibility
  OtpFieldStyle _currentStyle = OtpFieldStyle.box;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('OTP Forge Showcase'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.style),
            tooltip: 'Toggle Field Style',
            onPressed: () {
              setState(() {
                _currentStyle = _currentStyle == OtpFieldStyle.box
                    ? OtpFieldStyle.underline
                    : OtpFieldStyle.box;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Image or Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.message_rounded,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verify your phone',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'We\'ve sent a 6-digit verification code to your device.\n(Enter "123456" to succeed)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // The core component: OtpAuthFlow
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    OtpAuthFlow(
                      otpLength: 6,
                      autoReadOtp:
                          true, // Automatically listens for SMS on Android
                      fieldStyle: _currentStyle,
                      resendDuration: const Duration(seconds: 30),

                      // Customize the UI theme of the OTP fields
                      theme: OtpTheme(
                        borderRadius: 12,
                        fieldWidth: 50,
                        fieldHeight: 60,
                        spacing: 8,
                        focusedBorderColor: colorScheme.primary,
                        unfocusedBorderColor: Colors.grey.shade300,
                        errorBorderColor: colorScheme.error,
                      ),

                      // Triggered when user completes typing 6 digits
                      verifyOtp: (otp) async {
                        // Simulate network request
                        await Future.delayed(const Duration(seconds: 2));

                        if (otp != '123456') {
                          throw Exception('Invalid OTP. Please try again.');
                        }
                        return true;
                      },

                      // Triggered when the user clicks 'Resend Code'
                      onResend: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification code resent!'),
                          ),
                        );
                        // Simulate network request for resend
                        await Future.delayed(const Duration(seconds: 1));
                      },

                      // Triggered upon successful verification
                      onSuccess: (otp) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green.shade600,
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text('Success! Code $otp verified.'),
                              ],
                            ),
                          ),
                        );
                      },

                      // Triggered if verifyOtp throws an exception
                      onError: (message) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: colorScheme.error,
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(message),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Feature highlights
              const Text(
                'Features demonstrated above:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(Icons.timer, 'Built-in Resend Timer'),
              _buildFeatureRow(Icons.message, 'Auto-SMS Retriever (Android)'),
              _buildFeatureRow(
                Icons.color_lens,
                'Customizable Themes & Styles',
              ),
              _buildFeatureRow(Icons.check_circle, 'Validation & Error States'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
