import 'package:go_router/go_router.dart';

import 'view/biometric_prompt_screen.dart';
import 'view/confidentiality_agreement_screen.dart';
import 'view/esignature_screen.dart';
import 'view/login_screen.dart';
import 'view/splash_screen.dart';
import 'view/two_factor_auth_screen.dart';

/// All Auth-flow routes. These are full-screen (no bottom nav). Paths match
/// the Auth section of `src/app/routes.tsx` exactly.
final List<RouteBase> authRoutes = [
  GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
  GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
  GoRoute(path: '/verify', builder: (c, s) => const TwoFactorAuthScreen()),
  GoRoute(path: '/biometric', builder: (c, s) => const BiometricPromptScreen()),
  GoRoute(path: '/agreement', builder: (c, s) => const ConfidentialityAgreementScreen()),
  GoRoute(path: '/signature', builder: (c, s) => const ESignatureScreen()),
];
