import 'package:flutter/material.dart';

import '../controller/otp_controller.dart';
import '../models/otp_field_style.dart';
import '../models/otp_theme.dart';
import '../utils/otp_autofill.dart';

/// Builds a custom OTP field at [index] with the current [digit].
typedef OtpFieldBuilder = Widget Function(
  BuildContext context,
  int index,
  String? digit,
  bool isFocused,
  bool hasError,
);

/// OTP input widget supporting box, underline, and custom field styles.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controller,
    required this.otpLength,
    this.fieldStyle = OtpFieldStyle.box,
    this.theme = const OtpTheme(),
    this.fieldBuilder,
    this.autofocus = true,
    this.enabled = true,
  });

  final OtpController controller;
  final int otpLength;
  final OtpFieldStyle fieldStyle;
  final OtpTheme theme;
  final OtpFieldBuilder? fieldBuilder;
  final bool autofocus;
  final bool enabled;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final FocusNode _focusNode;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textController = TextEditingController(text: widget.controller.otp);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (_textController.text != widget.controller.otp) {
      _textController.value = TextEditingValue(
        text: widget.controller.otp,
        selection: TextSelection.collapsed(
          offset: widget.controller.otp.length,
        ),
      );
    }
    setState(() {});
  }

  void _handleChanged(String value) {
    widget.controller.updateOtp(value);
    if (value.length >= widget.otpLength) {
      OtpAutofillConfig.finishAutofillContext();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = widget.theme.resolve(context);
    final hasError = widget.controller.errorMessage != null;
    final isEnabled = widget.enabled && !widget.controller.isLocked;
    final focusedIndex =
        widget.controller.otp.length.clamp(0, widget.otpLength - 1);

    final fieldsRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.otpLength, (index) {
        final digit = index < widget.controller.otp.length
            ? widget.controller.otp[index]
            : null;
        final isFocused = _focusNode.hasFocus && index == focusedIndex;

        Widget field;
        if (widget.fieldStyle == OtpFieldStyle.custom &&
            widget.fieldBuilder != null) {
          field = widget.fieldBuilder!(
            context,
            index,
            digit,
            isFocused,
            hasError,
          );
        } else if (widget.fieldStyle == OtpFieldStyle.underline) {
          field = _UnderlineField(
            digit: digit,
            isFocused: isFocused,
            hasError: hasError,
            theme: resolvedTheme,
            enabled: isEnabled,
          );
        } else {
          field = _BoxField(
            digit: digit,
            isFocused: isFocused,
            hasError: hasError,
            theme: resolvedTheme,
            enabled: isEnabled,
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            right: index < widget.otpLength - 1 ? resolvedTheme.spacing : 0,
          ),
          child: GestureDetector(
            onTap: isEnabled ? () => _focusNode.requestFocus() : null,
            child: field,
          ),
        );
      }),
    );

    // Full-area invisible field improves iOS QuickType OTP suggestions.
    final autofillField = Semantics(
      label: 'One-time password, ${widget.otpLength} digits',
      textField: true,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: isEnabled,
        keyboardType: OtpAutofillConfig.keyboardType,
        textInputAction: TextInputAction.done,
        maxLength: widget.otpLength,
        autofillHints: OtpAutofillConfig.autofillHints,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
        showCursor: false,
        inputFormatters: OtpAutofillConfig.formatters(widget.otpLength),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        cursorColor: resolvedTheme.cursorColor,
        style: const TextStyle(color: Colors.transparent, fontSize: 1),
        onChanged: _handleChanged,
        onSubmitted: (_) => OtpAutofillConfig.finishAutofillContext(),
      ),
    );

    return OtpAutofillConfig.wrapAutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              fieldsRow,
              Positioned.fill(
                child: Opacity(
                  opacity: 0.01,
                  child: autofillField,
                ),
              ),
            ],
          ),
          if (hasError && widget.controller.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.controller.errorMessage!,
              style: resolvedTheme.errorTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}

class _BoxField extends StatelessWidget {
  const _BoxField({
    required this.digit,
    required this.isFocused,
    required this.hasError,
    required this.theme,
    required this.enabled,
  });

  final String? digit;
  final bool isFocused;
  final bool hasError;
  final OtpTheme theme;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = !enabled
        ? theme.disabledColor!
        : hasError
            ? theme.errorBorderColor!
            : isFocused
                ? theme.focusedBorderColor!
                : theme.unfocusedBorderColor!;

    final borderWidth =
        isFocused && !hasError ? theme.focusedBorderWidth : theme.borderWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: theme.fieldWidth,
      height: theme.fieldHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.filledColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Text(
        digit ?? '',
        style: theme.textStyle?.copyWith(
          color: enabled ? theme.textStyle?.color : theme.disabledColor,
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.digit,
    required this.isFocused,
    required this.hasError,
    required this.theme,
    required this.enabled,
  });

  final String? digit;
  final bool isFocused;
  final bool hasError;
  final OtpTheme theme;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = !enabled
        ? theme.disabledColor!
        : hasError
            ? theme.errorBorderColor!
            : isFocused
                ? theme.focusedBorderColor!
                : theme.unfocusedBorderColor!;

    final borderWidth =
        isFocused && !hasError ? theme.focusedBorderWidth : theme.borderWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: theme.fieldWidth,
      height: theme.fieldHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
      child: Text(
        digit ?? '',
        style: theme.textStyle?.copyWith(
          color: enabled ? theme.textStyle?.color : theme.disabledColor,
        ),
      ),
    );
  }
}
