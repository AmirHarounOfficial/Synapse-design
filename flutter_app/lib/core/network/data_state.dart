/// Minimal async-state union for Cubits that load from the API.
/// Pattern: `Cubit<DataState<T>>` emitting Loading → Loaded/Error.
sealed class DataState<T> {
  const DataState();
}

class DataLoading<T> extends DataState<T> {
  const DataLoading();
}

class DataLoaded<T> extends DataState<T> {
  const DataLoaded(this.data);
  final T data;
}

class DataError<T> extends DataState<T> {
  const DataError(this.message);
  final String message;
}
