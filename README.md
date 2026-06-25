# otp_forge

A production-ready OTP authentication package for Flutter featuring **SMS Retriever integration**, **OTP autofill**, **validation**, **resend timers**, **verification states**, and fully customizable UI components.

## Why `otp_forge`?

Most OTP packages force you to stitch together 3 different libraries to build a complete flow (one for UI, one for SMS listening, and custom boilerplate for timers). `otp_forge` handles the entire authentication lifecycle out-of-the-box:

- **All-in-One Widget**: Combine UI, SMS Retriever auto-read, validation, state management, and resend countdown logic into one unified widget (`OtpAuthFlow`).
- **Zero-Config Autofill**: Built-in Android SMS Retriever API support and proper iOS QuickType autofill configuration out of the box.
- **Built-in Resend Countdown Timer**: Stop writing `Timer.periodic` boilerplate.
- **Headless Controller**: Use the core logic (timer, autofill, validation) with your own completely custom UI using the `OtpController`.

## Features

- **OTP Input UI** — Box, underline, and custom builder styles
- **SMS Retriever** — Android SMS Retriever API integration (`autoReadOtp: true`)
- **Auto Fill** — Parses OTP from messages like `Your OTP is 123456`
- **Countdown Timer** — Built-in resend countdown with configurable duration
- **Validation** — Client-side validator before backend verification
- **Resend Logic** — `onResend` callback with automatic timer restart
- **State Management** — `idle`, `typing`, `verifying`, `success`, `failed`
- **Headless Controller** — Logic-only API without forcing a UI
- **Backend Agnostic** — Bring your own verification API

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  otp_forge: ^0.0.1
```

## Usage

### The Complete Flow (Recommended)

The easiest way to get started is by using the `OtpAuthFlow` widget. It automatically manages the UI, focus, timer, and SMS reading.

```dart
import 'package:otp_forge/otp_forge.dart';

OtpAuthFlow(
  otpLength: 6,
  autoReadOtp: true, // Automatically listens for SMS on Android
  resendDuration: const Duration(seconds: 30), // Built-in resend timer
  
  // Called when the user completes typing the OTP
  verifyOtp: (otp) async {
    return await authApi.verifyOtp(otp); 
  },
  
  // Called when the user clicks 'Resend Code'
  onResend: () async {
    await authApi.resendOtp();
  },
  
  // Triggered if verifyOtp completes successfully
  onSuccess: (otp) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeView()));
  },
  
  // Triggered if verifyOtp throws an error or fails
  onError: (message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  },
)
```

### Styling

You can easily customize the look of the OTP fields.

#### Basic Custom Theme
```dart
OtpAuthFlow(
  otpLength: 6,
  theme: const OtpTheme(
    borderRadius: 12,
    fieldWidth: 50,
    spacing: 8,
  ),
)
```

#### Underline Style
```dart
OtpAuthFlow(
  otpLength: 6,
  fieldStyle: OtpFieldStyle.underline,
)
```

#### Fully Custom Field Builder
Never be constrained by default designs. Return literally any widget you want for each digit while retaining all autofill and focus management logic.

```dart
OtpAuthFlow(
  otpLength: 6,
  fieldStyle: OtpFieldStyle.custom,
  fieldBuilder: (context, index, digit, isFocused, hasError) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFocused ? Colors.blue.shade50 : Colors.grey.shade100,
        border: Border.all(
          color: hasError ? Colors.red : (isFocused ? Colors.blue : Colors.transparent),
        ),
      ),
      child: Text(digit ?? '', style: const TextStyle(fontSize: 20)),
    );
  },
)
```

### Headless Controller (Logic without UI)

If you have a radically different design requirement and don't want to use `OtpAuthFlow`, you can use `OtpController` directly to get all the logic (autofill, timers, verification) while building your own UI from scratch.

```dart
final controller = OtpController(
  otpLength: 6,
  autoReadOtp: true,
  verifyOtp: (otp) => api.verifyOtp(otp),
  onResend: () => api.resendOtp(),
);

// Manually update the OTP
controller.updateOtp('123456');

// Trigger verification
await controller.verifyOtp();

// Trigger resend
await controller.resendOtp();
```

## Platform Specifics

### iOS Autofill

On iOS, OTP codes from Messages appear as QuickType suggestions above the keyboard. **This package handles this automatically — no extra setup required.**

For iOS autofill to work, your SMS should contain the OTP as a standalone numeric code. Example: `Your code is 123456`.

### Android SMS Retriever

For automatic background SMS reading on Android without asking the user for SMS permissions, your OTP SMS must:

1. Be no longer than 140 bytes.
2. Contain a numeric OTP.
3. Include your app's **11-character hash string** at the very end of the message.

Example SMS format:
```text
Your OTP is 123456

FA+9qCX9VSu
```
The plugin starts the SMS Retriever listener automatically when `autoReadOtp: true`.

## Example App

Run the included demo to see all features in action:

```bash
cd example
flutter run
```
Use OTP `123456` (or `1234` in the headless demo) to simulate a successful verification.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
