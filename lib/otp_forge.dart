/// Production-ready OTP authentication for Flutter.
///
/// Features SMS Retriever integration, OTP autofill, validation, resend
/// timers, verification states, and fully customizable UI components.
library;

export 'src/controller/otp_controller.dart';
export 'src/models/otp_field_style.dart';
export 'src/models/otp_state.dart';
export 'src/models/otp_theme.dart';
export 'src/services/sms_retriever.dart';
export 'src/utils/otp_autofill.dart';
export 'src/utils/otp_parser.dart';
export 'src/widgets/otp_auth_flow.dart';
export 'src/widgets/otp_input.dart';
