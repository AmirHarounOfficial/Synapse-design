import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/cafeteria_alert.dart';
import '../../../data/repositories/cafeteria_repository.dart';
import '../cubit/cafeteria_alert_detail_cubit.dart';
import '../widgets/halal_badge.dart';
import '../widgets/non_halal_badge.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `CafeteriaAllergenDetail.tsx`, now wired to the API. Loads one
/// alert (`GET /cafeteria-alerts/{id}`) and confirms it via the acknowledge
/// endpoint (`POST /cafeteria-alerts/{id}/acknowledge`).
class CafeteriaAllergenDetailScreen extends StatelessWidget {
  const CafeteriaAllergenDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final alertId = int.tryParse(id) ?? 0;
    return BlocProvider(
      create: (_) => CafeteriaAlertDetailCubit(sl<CafeteriaRepository>(), alertId),
      child: const _CafeteriaAllergenDetailView(),
    );
  }
}

class _CafeteriaAllergenDetailView extends StatefulWidget {
  const _CafeteriaAllergenDetailView();

  @override
  State<_CafeteriaAllergenDetailView> createState() => _CafeteriaAllergenDetailViewState();
}

class _CafeteriaAllergenDetailViewState extends State<_CafeteriaAllergenDetailView> {
  bool _submitting = false;

  Future<void> _handleConfirmDelivery() async {
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<CafeteriaAlertDetailCubit>().acknowledge();
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(context.tr(en: 'Meal delivery confirmed successfully!', ar: 'تم تأكيد تسليم الوجبة بنجاح'))),
    );
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/cafeteria/alerts');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return BlocBuilder<CafeteriaAlertDetailCubit, DataState<CafeteriaAlert>>(
      builder: (context, state) {
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            onBack: () => context.canPop() ? context.safeBack() : context.go('/cafeteria/alerts'),
            centerTitle: true,
            title: isRTL ? 'تفاصيل قيود الوجبة' : 'Meal Restriction Detail',
          ),
          bottomBar: state is DataLoaded<CafeteriaAlert> ? _confirmBar(isRTL, state.data) : null,
          body: switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _errorView(message),
            DataLoaded(:final data) => _content(isRTL, data),
          },
        );
      },
    );
  }

  Widget _errorView(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: 'Retry',
              fullWidth: false,
              onPressed: () => context.read<CafeteriaAlertDetailCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(bool isRTL, CafeteriaAlert alert) {
    final hasHalalRestriction = alert.isHalalIssue;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                if (alert.studentId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    isRTL ? 'رقم الطالب: ${alert.studentId}' : 'Student ID: ${alert.studentId}',
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          hasHalalRestriction ? _nonHalalCard(isRTL) : _halalCard(isRTL),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'مسببات الحساسية الممنوعة' : 'Allergen Restrictions',
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          _restrictionsCard(isRTL, alert.message),
          const SizedBox(height: 16),
          _privacyNotice(isRTL),
          if (alert.acknowledged) ...[
            const SizedBox(height: 16),
            _successCard(isRTL),
          ],
        ],
      ),
    );
  }

  Widget _nonHalalCard(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? '⚠️ تنبيه قيود الحلال نشط' : '⚠️ Non-Halal Restriction Active',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
                    const SizedBox(height: 2),
                    Text(
                      isRTL ? 'يجب تقديم وجبات معتمدة وحلال فقط لهذا الطالب.' : 'This student requires Halal-certified meals only.',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const NonHalalBadge(),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFFCA5A5)),
          const SizedBox(height: 6),
          Text(isRTL ? 'تم تأكيده بواسطة ولي الأمر: نعم' : 'Parent-confirmed restriction: Yes',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _halalCard(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'حالة الوجبة: حلال معتمد ✓' : 'Halal Status: Certified ✓',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.halalGreen)),
                    const SizedBox(height: 2),
                    Text(
                      isRTL ? 'الوجبة اليومية المخصصة للطالب حلال معتمدة.' : 'Standard meal for this student is Halal-certified.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const HalalBadge(),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFA7F3D0)),
          const SizedBox(height: 6),
          Text(isRTL ? 'تم تأكيده بواسطة ولي الأمر: نعم' : 'Parent-confirmed restriction: Yes',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _restrictionsCard(bool isRTL, String message) {
    return AccentCard(
      background: const Color(0xFFFEF2F2),
      accentColor: SchooKeepColors.error,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'يُمنع منعاً باتاً تقديم أطعمة تحتوي على:' : 'DO NOT serve items containing:',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(message.isEmpty ? (isRTL ? 'قيود غذائية' : 'Dietary restriction') : message,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyNotice(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
          children: [
            TextSpan(
              text: isRTL ? 'إشعار خصوصية البيانات: ' : 'Privacy Notice: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: isRTL
                  ? 'أنت تستعرض قيود الوجبات الخاصة بالطالب فقط لدواعي السلامة. تعتبر السجلات الطبية الكاملة سرية للغاية ومحمية بموجب قانون حماية البيانات (PDPL).'
                  : 'You are viewing meal restrictions only for student safety. Comprehensive medical records are strictly confidential and protected under UAE PDPL.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _successCard(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.greenChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.accent),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.check, size: 20, color: SchooKeepColors.accent),
          const SizedBox(width: 8),
          Text(isRTL ? 'تم تأكيد تسليم الوجبة' : 'Meal delivery confirmed',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.greenChipText)),
        ],
      ),
    );
  }

  Widget _confirmBar(bool isRTL, CafeteriaAlert alert) {
    final done = alert.acknowledged;
    final disabled = done || _submitting;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: SchooKeepColors.physicianTeal,
            disabledBackgroundColor: SchooKeepColors.border,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: disabled ? null : _handleConfirmDelivery,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.check, size: 20, color: done ? const Color(0xFF94A3B8) : Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      done
                          ? (isRTL ? 'تم تأكيد التسليم' : 'Confirmed')
                          : (isRTL ? 'تأكيد تسليم الوجبة للطالب' : 'Confirm Meal Delivered'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: done ? const Color(0xFF94A3B8) : Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
