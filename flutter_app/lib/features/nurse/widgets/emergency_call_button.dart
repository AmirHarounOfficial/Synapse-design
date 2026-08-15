import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/uae_tokens.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';

/// Local port of `EmergencyCallButton.tsx`. Full-width 52px red (or outline)
/// button that "dials" the UAE ambulance number. No real telephony — pops a
/// snackbar to mirror the original `alert(...)`.
class EmergencyCallButton extends StatelessWidget {
  const EmergencyCallButton({super.key, this.variant = EmergencyCallVariant.danger});

  final EmergencyCallVariant variant;

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final label = isRTL
        ? 'طوارئ · اتصل بالإسعاف ${UaeTokens.ambulanceNumber}'
        : 'Emergency · Call Ambulance ${UaeTokens.ambulanceNumber}';

    final isDanger = variant == EmergencyCallVariant.danger;
    final bg = isDanger ? SchooKeepColors.error : SchooKeepColors.surface;
    final fg = isDanger ? Colors.white : SchooKeepColors.error;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDanger
              ? BorderSide.none
              : const BorderSide(color: SchooKeepColors.error, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(isRTL
                    ? 'اتصال بالطوارئ: جارٍ الاتصال بالإسعاف على الرقم ${UaeTokens.ambulanceNumber}...'
                    : 'Calling Emergency: Dialing Ambulance at ${UaeTokens.ambulanceNumber}...'),
              ));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.phoneCall, size: 20, color: fg),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum EmergencyCallVariant { danger, outline }
