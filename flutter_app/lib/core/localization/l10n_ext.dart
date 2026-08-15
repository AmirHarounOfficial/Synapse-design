import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_cubit.dart';

/// Bilingual helpers on [BuildContext] that mirror the React export's inline
/// `isRTL ? 'عربى' : 'English'` pattern. Keeps each ported screen self-contained,
/// exactly like the original components.
extension L10nContext on BuildContext {
  bool get isRTL => watch<LocaleCubit>().state.isRTL;
  String get languageCode => watch<LocaleCubit>().state.languageCode;

  /// Pick the string for the active language: `context.tr(en: 'Home', ar: 'الرئيسية')`.
  String tr({required String en, required String ar}) => isRTL ? ar : en;
}
