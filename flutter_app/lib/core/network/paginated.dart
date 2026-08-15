/// A page of results from a Laravel `paginate()` response
/// (`{ "data": [...], "meta": { current_page, last_page, total, ... } }`).
class Paginated<T> {
  const Paginated({required this.items, this.currentPage = 1, this.lastPage = 1, this.total = 0});

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  factory Paginated.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromItem) {
    final data = (json['data'] as List? ?? const []).cast<Map<String, dynamic>>();
    final meta = json['meta'] as Map<String, dynamic>?;
    return Paginated<T>(
      items: data.map(fromItem).toList(),
      currentPage: (meta?['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta?['last_page'] as num?)?.toInt() ?? 1,
      total: (meta?['total'] as num?)?.toInt() ?? data.length,
    );
  }
}
