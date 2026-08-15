import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App locale state. Mirrors `src/context/LanguageContext.tsx`:
/// `language` ('ar' | 'en'), `isRTL`, `toggleLanguage` with a simulated
/// device-reboot overlay, persisted to storage (was `localStorage`).
class LocaleState extends Equatable {
  const LocaleState({required this.languageCode, this.isRebooting = false});

  final String languageCode; // 'ar' | 'en'
  final bool isRebooting;

  bool get isRTL => languageCode == 'ar';
  Locale get locale => Locale(languageCode);

  LocaleState copyWith({String? languageCode, bool? isRebooting}) => LocaleState(
        languageCode: languageCode ?? this.languageCode,
        isRebooting: isRebooting ?? this.isRebooting,
      );

  @override
  List<Object?> get props => [languageCode, isRebooting];
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._prefs)
      : super(LocaleState(languageCode: _prefs.getString(_key) ?? 'en'));

  static const String _key = 'synapse_lang';
  final SharedPreferences _prefs;

  Future<void> toggleLanguage() async {
    final next = state.languageCode == 'en' ? 'ar' : 'en';
    // Simulated mobile-app restart delay (900ms in the original).
    emit(state.copyWith(isRebooting: true));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await _prefs.setString(_key, next);
    emit(LocaleState(languageCode: next, isRebooting: false));
  }
}
