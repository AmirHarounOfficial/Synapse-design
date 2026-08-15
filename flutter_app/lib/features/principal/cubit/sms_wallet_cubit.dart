import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/sms_transaction.dart';
import '../../../data/repositories/sms_wallet_repository.dart';

typedef SmsWalletData = ({int balanceCredits, List<SmsTransaction> transactions});

/// Loads the SMS credit wallet (`GET /sms-wallet`) and processes top-ups
/// (`POST /sms-wallet/topup`).
class SmsWalletCubit extends Cubit<DataState<SmsWalletData>> {
  SmsWalletCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final SmsWalletRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final data = await _repo.get();
      emit(DataLoaded(data));
    } catch (e) {
      emit(DataError(SmsWalletRepository.messageFor(e)));
    }
  }

  /// Tops up the wallet and emits the refreshed balance/ledger. Returns true on
  /// success.
  Future<bool> topup(int credits) async {
    try {
      final data = await _repo.topup(credits);
      emit(DataLoaded(data));
      return true;
    } catch (e) {
      emit(DataError(SmsWalletRepository.messageFor(e)));
      return false;
    }
  }
}
