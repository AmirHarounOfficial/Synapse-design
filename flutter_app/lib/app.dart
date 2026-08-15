import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/service_locator.dart';
import 'core/localization/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_formatter.dart';
import 'features/system/widgets/ramadan_banner.dart';

class SchooKeepApp extends StatelessWidget {
  const SchooKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocaleCubit(sl<SharedPreferences>()),
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'SchooKeep',
            debugShowCheckedModeBanner: false,
            theme: SchooKeepTheme.light(),
            routerConfig: appRouter,
            locale: state.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              // Constrain to the iPhone-class 393px frame from the export, force
              // the locale's text direction, and overlay the reboot transition.
              return Directionality(
                textDirection: state.isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: ColoredBox(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 393),
                      // Transparent Material ancestor so screens that use InkWell
                      // / TextField / ink effects work even when they don't sit
                      // inside a Scaffold (full-screen routes use SchooKeepScaffold,
                      // which is a plain ColoredBox). Scaffold-based shells nest
                      // their own Material below this, which is fine.
                      child: Material(
                        type: MaterialType.transparency,
                        child: Stack(
                          children: [
                            ColoredBox(color: SchooKeepColors.background, child: child ?? const SizedBox.shrink()),
                            // Global Ramadan banner (mirrors App.tsx). Self-hides
                            // outside Ramadan; the /system/ramadan screen demos it.
                            RamadanBanner(active: DateFormatter.isRamadanActive(DateTime.now())),
                            if (state.isRebooting) const _RebootOverlay(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Simulated device-reboot overlay shown while the language toggles
/// (mirrors the overlay in `LanguageContext.tsx`).
class _RebootOverlay extends StatelessWidget {
  const _RebootOverlay();

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LocaleCubit>().state.languageCode;
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xFF0F172A),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SchooKeepColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('S', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text(
              lang == 'en' ? 'Changing language to العربية...' : 'جاري تغيير اللغة إلى الإنجليزية...',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: SchooKeepColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
