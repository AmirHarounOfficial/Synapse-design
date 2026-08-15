import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/localization/locale_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';

/// Dev index (ported role of `SynapseNavigationMap`): jump to any role/flow.
/// Not a product screen — used to navigate the app while screens are ported.
class NavigationMapScreen extends StatelessWidget {
  const NavigationMapScreen({super.key});

  static const _sections = <({String title, List<({String label, String route})> links})>[
    (title: 'Auth', links: [
      (label: 'Splash', route: '/splash'),
      (label: 'Login', route: '/login'),
      (label: '2FA Verify', route: '/verify'),
      (label: 'Biometric', route: '/biometric'),
      (label: 'Confidentiality', route: '/agreement'),
      (label: 'E-Signature', route: '/signature'),
    ]),
    (title: 'Nurse', links: [(label: 'Nurse Portal', route: '/nurse/dashboard')]),
    (title: 'Parent', links: [
      (label: 'Parent App', route: '/parent/app/home'),
      (label: 'Onboarding', route: '/parent/onboarding/code'),
      (label: 'Legacy Portal', route: '/parent/dashboard'),
    ]),
    (title: 'Teacher', links: [(label: 'Teacher Portal', route: '/teacher/home')]),
    (title: 'Cafeteria', links: [(label: 'Cafeteria Portal', route: '/cafeteria/alerts')]),
    (title: 'Security Guard', links: [(label: 'Security Portal', route: '/security/pickups')]),
    (title: 'Bus Driver', links: [(label: 'Bus Portal', route: '/bus/route')]),
    (title: 'Counselor', links: [(label: 'Counselor Portal', route: '/counselor/home')]),
    (title: 'Secretary', links: [(label: 'Secretary Portal', route: '/secretary/home')]),
    (title: 'Principal', links: [(label: 'Principal Portal', route: '/principal/home')]),
    (title: 'Physician', links: [(label: 'Physician Portal', route: '/physician/dashboard')]),
    (title: 'Vice Principal', links: [(label: 'Vice Principal Portal', route: '/vice-principal/home')]),
    (title: 'System States', links: [
      (label: 'After-hours Lock', route: '/system/after-hours'),
      (label: 'Weather Advisory', route: '/system/weather-advisory'),
      (label: 'Consent Pending', route: '/system/consent-pending'),
      (label: 'Session Expiry', route: '/system/session-expiry'),
      (label: 'State Simulator', route: '/system/simulator'),
      (label: 'Ramadan Mode', route: '/system/ramadan'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state.languageCode;
    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: 'SchooKeep — Navigation',
        actions: [
          InkWell(
            onTap: () => context.read<LocaleCubit>().toggleLanguage(),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Text(lang == 'en' ? 'العربية' : 'English',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in _sections) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Text(section.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SchooKeepColors.textSecondary)),
              ),
              ...section.links.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SchooKeepCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () => context.go(l.route),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(l.label,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                          ),
                          const RtlIcon(LucideIcons.chevronRight, size: 18, color: SchooKeepColors.textSecondary),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
