import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/document.dart';
import '../../../data/repositories/document_repository.dart';

/// Loads a single document by id and exposes approve/reject review actions.
class DocumentViewerCubit extends Cubit<DataState<Document>> {
  DocumentViewerCubit(this._repo, this.id) : super(const DataLoading()) {
    load();
  }

  final DocumentRepository _repo;
  final int id;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      emit(DataLoaded(await _repo.show(id)));
    } catch (e) {
      emit(DataError(DocumentRepository.messageFor(e)));
    }
  }

  /// Reviews the document. Returns the error message on failure, or null on
  /// success (the loaded document is updated in place).
  Future<String?> review(String status, {String? notes}) async {
    try {
      final updated = await _repo.review(id, status, notes: notes);
      emit(DataLoaded(updated));
      return null;
    } catch (e) {
      return DocumentRepository.messageFor(e);
    }
  }
}
