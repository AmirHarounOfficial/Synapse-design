// Testing-only conveniences.
//
// These default to on in debug builds and off in release builds, so they can
// never ship to production. Override explicitly at build/run time:
//
//   flutter run --dart-define=DEV_BYPASS_OTP=false   # force the real 2FA flow
//   flutter run --dart-define=DEV_BYPASS_OTP=true    # force-enable in release
import 'package:flutter/foundation.dart';

/// When true, the two-factor (OTP) verification step is skipped so testers
/// don't have to type a code. Defaults to [kDebugMode] (on while developing,
/// off in release). The OTP screen is UI-only in this build, so skipping it
/// changes nothing about real authentication.
const bool kDevBypassOtp =
    bool.fromEnvironment('DEV_BYPASS_OTP', defaultValue: kDebugMode);
