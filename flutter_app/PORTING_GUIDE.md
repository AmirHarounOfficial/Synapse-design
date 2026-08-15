# SchooKeep — Flutter Porting Guide (for per-role porting)

You are porting React+TypeScript screens (Figma Make export) to **Flutter**, **pixel-faithful**.
React source: `D:\work\Synapse Health App\src\app\components\*.tsx`.
Flutter app: `D:\work\Synapse Health App\flutter_app\`. App brand name is **SchooKeep** (the export
says "Synapse" — render "SchooKeep" wherever the wordmark/brand appears).

## Hard rules
1. **Do NOT add dependencies** and **do NOT edit** files outside your assigned `lib/features/<role>/`
   folder (and you may create that folder's files). Do NOT edit `lib/core/**`, `lib/app.dart`,
   `lib/main.dart`, `pubspec.yaml`, or other roles. The central router import is handled separately —
   you only produce your role's `*_routes.dart` (see below).
2. **Reuse the shared design system** — never hard-code hex colors when a token exists.
3. Code must pass `flutter analyze` with **no issues**. Use `const` where possible.
4. Keep each screen self-contained with **inline mock data** mirroring the original component's arrays.
5. Match layout/spacing/colors faithfully: phone-width column, `#F8FAFC` page bg, white cards with
   `1px #E2E8F0` border + 12px radius, 44px status bar, 56px app bar, 83px bottom nav, 44px tap targets.

## Imports you will use
```dart
import '../../../core/theme/app_colors.dart';        // SchooKeepColors.primary, .textPrimary, .border, ...
import '../../../core/theme/app_theme.dart';          // SchooKeepTheme.radiusXl (12), heights
import '../../../core/constants/uae_tokens.dart';     // UaeTokens.emirates, ambulanceNumber, ...
import '../../../core/utils/date_formatter.dart';     // DateFormatter.formatGregorian/toHijri/...
import '../../../core/utils/validators.dart';         // Validators.formatUaePhone/isValidEid/...
import '../../../core/localization/l10n_ext.dart';    // context.isRTL, context.languageCode, context.tr(en:,ar:)
import '../../../core/localization/locale_cubit.dart';// context.read<LocaleCubit>().toggleLanguage()
import '../../../core/widgets/widgets.dart';          // all shared widgets (barrel)
import 'package:lucide_icons/lucide_icons.dart';      // LucideIcons.* (matches lucide-react names, camelCase)
import 'package:go_router/go_router.dart';            // context.go('/path'), context.pop()
import 'package:flutter_bloc/flutter_bloc.dart';      // if needed
```

## Shared widgets (API)
- `SchooKeepScaffold({body, appBar?, title?, onBack?, actions?, scrollable=true, reserveBottomNav=false, bottomBar?, padding})`
  — page shell: status-bar spacer + (optional) app bar + body. Set `reserveBottomNav: true` for screens
  inside a role's bottom-nav shell. Provide a custom `SchooKeepAppBar` via `appBar:` when you need actions.
- `SchooKeepAppBar({title?, titleWidget?, onBack?, actions=[], centerTitle=false})` — 56px white top bar.
- `SchooKeepCard({child, padding=16, margin?, onTap?, radius=12, borderColor, color})` — white bordered card.
- `SchooKeepButton({label, onPressed, variant: primary|secondary|danger|outline, icon?, fullWidth=true, height=52})`.
- `SchooKeepBadge({label, background, foreground, icon?, fontSize=12})` — rounded pill/chip.
- `SchooKeepBottomNav` / `RoleShell({child, tabs, activeColor})` — used by your routes file, not inside screens.
- `RtlIcon(IconData, {size, color})` — icon that mirrors in RTL (use for chevrons/back arrows).
- `StatusBarSpacer()` — 44px white spacer (already inside SchooKeepScaffold).

## RTL & i18n
- The export uses inline `isRTL ? 'arabic' : 'english'`. Mirror it with `context.tr(en: '...', ar: '...')`.
  For non-widget code (e.g. building a list in a method), read `final isRTL = context.isRTL;` once.
- Flutter handles direction automatically via the app-level `Directionality`. Use `EdgeInsetsDirectional`,
  `AlignmentDirectional`, `BorderDirectional`, `start/end` — NOT left/right — so RTL mirrors for free.
- For chevrons/back arrows that visually flip, use `RtlIcon`.
- Language toggle pill (when a screen has one): `context.read<LocaleCubit>().toggleLanguage()`.

## Mock data / behavior
- Recreate the component's hardcoded arrays as inline Dart records or simple classes.
- Navigation: replace `useNavigate()('/x')` with `context.go('/x')`; back buttons → `context.pop()`.
- Local UI state (toggles, form fields, steps) → `StatefulWidget` + `setState`. (Bloc/Cubit optional;
  for view-only screens setState is fine and matches the source's `useState`.)
- Toasts (`sonner`) → `ScaffoldMessenger.of(context).showSnackBar(...)`.
- Canvas signature → `signature` package (`SignatureController` + `Signature`). QR → `mobile_scanner`.
  Photo upload → `image_picker`. Charts → `fl_chart`. Hijri dates → `DateFormatter`.

## Deliverables per role
1. `lib/features/<role>/view/<screen>_screen.dart` for every screen in that role.
2. `lib/features/<role>/<role>_tabs.dart` — if the role has a bottom-nav layout, a `const <role>Tabs`
   `List<SchooKeepTab>` (read the role's `*Layout.tsx` for exact tab labels/icons/routes; English labels).
3. `lib/features/<role>/<role>_routes.dart` exposing `final List<RouteBase> <role>Routes` — wrap bottom-nav
   screens in a `ShellRoute(builder: (c,s,child)=>RoleShell(tabs: <role>Tabs, child: child, activeColor: ...))`
   and put full-screen flows (wizards, full QR, previews) as top-level `GoRoute`s. Use the EXACT paths from
   `src/app/routes.tsx`. Physician uses `activeColor: SchooKeepColors.physicianTeal`.

Use `NurseDashboardScreen` (`lib/features/nurse/view/nurse_dashboard_screen.dart`), `nurse_tabs.dart`,
and `nurse_routes.dart` as the reference implementation for structure and style.
