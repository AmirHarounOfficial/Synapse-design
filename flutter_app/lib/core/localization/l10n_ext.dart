import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_cubit.dart';

/// Bilingual helpers on [BuildContext] that mirror the React export's inline
/// `isRTL ? 'عربى' : 'English'` pattern. Automatically uses `watch` during build
/// and `read` inside event handlers to prevent Provider assertion errors.
extension L10nContext on BuildContext {
  bool get _isBuilding => owner?.debugBuilding ?? false;

  bool get isRTL {
    if (_isBuilding) {
      return watch<LocaleCubit>().state.isRTL;
    }
    return read<LocaleCubit>().state.isRTL;
  }

  bool get isRTLRead => read<LocaleCubit>().state.isRTL;

  String get languageCode {
    if (_isBuilding) {
      return watch<LocaleCubit>().state.languageCode;
    }
    return read<LocaleCubit>().state.languageCode;
  }

  /// Pick the string for the active language: `context.tr(en: 'Home', ar: 'الرئيسية')`.
  String tr({required String en, required String ar}) => isRTL ? ar : en;

  /// Read-only translation lookup for async callbacks & event handlers.
  String trRead({required String en, required String ar}) => isRTLRead ? ar : en;
}
