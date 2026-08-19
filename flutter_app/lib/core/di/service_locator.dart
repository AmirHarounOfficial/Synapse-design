import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../data/repositories/after_hours_repository.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/bus_repository.dart';
import '../../data/repositories/cafeteria_repository.dart';
import '../../data/repositories/chatbot_repository.dart';
import '../../data/repositories/clinic_repository.dart';
import '../../data/repositories/counselor_repository.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/equipment_repository.dart';
import '../../data/repositories/medication_repository.dart';
import '../../data/repositories/pharmacy_inventory_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/permission_repository.dart';
import '../../data/repositories/pickup_repository.dart';
import '../../data/repositories/sms_wallet_repository.dart';
import '../../data/repositories/staff_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/system_repository.dart';

final GetIt sl = GetIt.instance;

/// Registers app-wide singletons: storage, the API client, and repositories.
/// Repositories are wired in feature-by-feature; screens not yet wired still
/// ship with inline mock data.
Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<ApiClient>(ApiClient(prefs));

  final api = sl<ApiClient>();
  sl.registerSingleton<AuthRepository>(AuthRepository(api));
  sl.registerSingleton<StudentRepository>(StudentRepository(api));
  sl.registerSingleton<MedicationRepository>(MedicationRepository(api));
  sl.registerSingleton<ClinicRepository>(ClinicRepository(api));
  sl.registerSingleton<DocumentRepository>(DocumentRepository(api));
  sl.registerSingleton<PickupRepository>(PickupRepository(api));
  sl.registerSingleton<BusRepository>(BusRepository(api));
  sl.registerSingleton<CafeteriaRepository>(CafeteriaRepository(api));
  sl.registerSingleton<CounselorRepository>(CounselorRepository(api));
  sl.registerSingleton<NotificationRepository>(NotificationRepository(api));
  sl.registerSingleton<SystemRepository>(SystemRepository(api));

  // Newer domains (messaging, chatbot, staff, permissions, analytics,
  // SMS wallet, after-hours requests, equipment checklist).
  sl.registerSingleton<MessageRepository>(MessageRepository(api));
  sl.registerSingleton<ChatbotRepository>(ChatbotRepository(api));
  sl.registerSingleton<StaffRepository>(StaffRepository(api));
  sl.registerSingleton<PermissionRepository>(PermissionRepository(api));
  sl.registerSingleton<AnalyticsRepository>(AnalyticsRepository(api));
  sl.registerSingleton<SmsWalletRepository>(SmsWalletRepository(api));
  sl.registerSingleton<AfterHoursRepository>(AfterHoursRepository(api));
  sl.registerSingleton<EquipmentRepository>(EquipmentRepository(api));
  sl.registerSingleton<PharmacyInventoryRepository>(PharmacyInventoryRepository(api));
}
