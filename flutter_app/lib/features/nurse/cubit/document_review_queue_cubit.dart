import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/document.dart';
import '../../../data/repositories/document_repository.dart';

/// Loads the document review queue from the API (`GET /documents`).
class DocumentReviewQueueCubit extends Cubit<DataState<List<Document>>> {
  DocumentReviewQueueCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final DocumentRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.list();
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(DocumentRepository.messageFor(e)));
    }
  }
}
