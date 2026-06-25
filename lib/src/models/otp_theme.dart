import 'package:flutter/material.dart';

/// Customizable visual theme for OTP input fields.
class OtpTheme {
  const OtpTheme({
    this.borderRadius = 12,
    this.fieldWidth = 50,
    this.fieldHeight = 56,
    this.spacing = 8,
    this.borderWidth = 1.5,
    this.focusedBorderWidth = 2,
    this.focusedBorderColor,
    this.unfocusedBorderColor,
    this.errorBorderColor,
    this.filledColor,
    this.textStyle,
    this.errorTextStyle,
    this.cursorColor,
    this.disabledColor,
  });

  /// Corner radius for box-style fields.
  final double borderRadius;

  /// Width of each OTP field.
  final double fieldWidth;

  /// Height of each OTP field.
  final double fieldHeight;

  /// Horizontal spacing between fields.
  final double spacing;

  /// Border width when unfocused.
  final double borderWidth;

  /// Border width when focused.
  final double focusedBorderWidth;

  /// Border color when a field is focused.
  final Color? focusedBorderColor;

  /// Border color when a field is unfocused.
  final Color? unfocusedBorderColor;

  /// Border color when validation fails.
  final Color? errorBorderColor;

  /// Background fill color for fields.
  final Color? filledColor;

  /// Text style for digit display.
  final TextStyle? textStyle;

  /// Text style for error messages.
  final TextStyle? errorTextStyle;

  /// Cursor color for the hidden input field.
  final Color? cursorColor;

  /// Color applied when fields are disabled (e.g. during verification).
  final Color? disabledColor;

  /// Resolves theme colors from the ambient [ThemeData] when not explicitly set.
  OtpTheme resolve(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OtpTheme(
      borderRadius: borderRadius,
      fieldWidth: fieldWidth,
      fieldHeight: fieldHeight,
      spacing: spacing,
      borderWidth: borderWidth,
      focusedBorderWidth: focusedBorderWidth,
      focusedBorderColor: focusedBorderColor ?? colorScheme.primary,
      unfocusedBorderColor:
          unfocusedBorderColor ?? colorScheme.outline.withValues(alpha: 0.5),
      errorBorderColor: errorBorderColor ?? colorScheme.error,
      filledColor: filledColor ?? colorScheme.surfaceContainerHighest,
      textStyle: textStyle ??
          Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
      errorTextStyle: errorTextStyle ??
          Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
      cursorColor: cursorColor ?? colorScheme.primary,
      disabledColor: disabledColor ?? colorScheme.onSurface.withValues(alpha: 0.38),
    );
  }

  OtpTheme copyWith({
    double? borderRadius,
    double? fieldWidth,
    double? fieldHeight,
    double? spacing,
    double? borderWidth,
    double? focusedBorderWidth,
    Color? focusedBorderColor,
    Color? unfocusedBorderColor,
    Color? errorBorderColor,
    Color? filledColor,
    TextStyle? textStyle,
    TextStyle? errorTextStyle,
    Color? cursorColor,
    Color? disabledColor,
  }) {
    return OtpTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      fieldWidth: fieldWidth ?? this.fieldWidth,
      fieldHeight: fieldHeight ?? this.fieldHeight,
      spacing: spacing ?? this.spacing,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      unfocusedBorderColor: unfocusedBorderColor ?? this.unfocusedBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      filledColor: filledColor ?? this.filledColor,
      textStyle: textStyle ?? this.textStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      cursorColor: cursorColor ?? this.cursorColor,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }
}
